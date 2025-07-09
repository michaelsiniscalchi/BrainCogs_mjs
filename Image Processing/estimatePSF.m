function [ psf, img ] = estimatePSF( data_dir, img_width, crop_margins, perctile_thresh, um_per_pixel )

tic;
%Get mean projection of each slice (1 TIFF/slice)
fileList = dir(fullfile(data_dir,'*.tif'));
fname = string({fileList(:).name}');

%Load all tiffs, get z-projection, and determine margins for cropping
%eg, smooth and use max +/-  

if numel(fileList)>1 %One file per slice
    nX = img_width; % Assume square
    nY = img_width;
    nZ = numel(fileList);
    slices = NaN(nX,nY,nZ); %Pre-allocate memory with hard-coded XY dimensions
    parfor i = 1:nZ
        %[ stack, tags, ImageDescription ] = loadtiffseq( full_path, channel, method )
        if i==1
            [stack, tags(i)] = loadtiffseq(fullfile(data_dir,fname(i)));
            slices(:,:,i) = mean(stack,3,"omitnan"); %Obtain mean projection across frames
        else
            stack = loadtiffseq(fullfile(data_dir,fname(i)));
            slices(:,:,i) = mean(stack,3,"omitnan"); %Obtain mean projection across frames
        end
    end
     %Crop to box of spec width around max pixel in smoothed z-projection
     zProj = imgaussfilt(mean(slices,3),2);
     [y,x] = find(zProj==max(zProj,[],"all"));
     crop_margins = [y-0.5*crop_margins, x-0.5*crop_margins, crop_margins];
     slices = cropStack(slices, crop_margins);
     [nY,nX,nZ] = size(slices);
else %One image per slice
    [stack, tags] = loadtiffseq(fullfile(data_dir,fname));
    if isscalar(crop_margins) %Only box-width specified
        %Crop to box of spec width around max pixel in smoothed z-projection
        zProj = imgaussfilt(mean(stack,3),2); 
        [y,x] = find(zProj==max(zProj,[],"all"));
        crop_margins = [y-0.5*crop_margins, x-0.5*crop_margins, crop_margins];
    end
    slices = cropStack(stack,crop_margins); %Obtain mean projection across frames
    [nY,nX,nZ] = size(slices);
end
%Adjust tags
tags.ImageLength = nY;
tags.ImageWidth = nX;

%Calculate X, Y, and Z mean projection and profile
dim = [1,2,3];
fields = ["y","x","z"];
for i = 1:numel(dim)
    %Convert pixels to microns and store 
    X = double(0:size(slices,i)-1); %**for Z: Assumes 1-um step size for z-stack**
    if ismember(fields(i),["x","y"])
        X = X * um_per_pixel; %X-Y Position
        meanProj.(fields(i)).X = X; 
        meanProj.(fields(i)).Y = 0:nZ-1; %Depth
    else %Z
        meanProj.z.X = (0:nX-1)*um_per_pixel;  %X-Y Position
        meanProj.z.Y = (0:nY-1)*um_per_pixel;  %X-Y Position
    end
    profile.(fields(i)).X = X; %X-Y Position

    %Take mean over the relevant spatial dimension(s)
    meanProj.(fields(i)).data = squeeze(mean(slices,i))';
    data(:,1) = squeeze(mean(slices,dim(dim~=i))); %Axis profile
    profile.(fields(i)).data = (data-min(data))./range(data); %Peak normalize
    clearvars data
end


% Estimate zPSF based on smoothed and thresholded z-projection
%Smooth and threshold
smoothedZProj = imgaussfilt(meanProj.z.data, 1);
bw = smoothedZProj >= prctile(smoothedZProj,perctile_thresh,'all');
%Get largest region (which should represent the 1-um bead)
regions = bwconncomp(bw,4); %Find regions with 4-connectivity
nPix = cellfun(@numel,regions.PixelIdxList); %Number of pixels in each region
largestRegion = nPix==max(nPix); %Largest region
%Index all voxels belonging to bead
xyMask = false(size(bw)); 
xyMask(regions.PixelIdxList{largestRegion})=true;
beadVoxels = slices(repmat(xyMask,1,1,nZ)); %xyMask across all slices
%Extract voxels as 2D matrix and take mean
psf.z.data = mean(reshape(beadVoxels,sum(xyMask,'all'),nZ)); %reshaped as masked pixels x slice

% Select slice for X,Y PSF based on max of zPSF
smoothedPSF = smooth(psf.z.data, 5);
sliceIdx = find(smoothedPSF==max(smoothedPSF)); %Slice where zPSF is maximized
stats = regionprops(xyMask); 
centroid = [stats.Centroid, sliceIdx]; %Centroid of smoothed, thresholded z-projection
%Average across rows adjacent to centroid
idxX = round(centroid(1))-1:round(centroid(1))+1;
idxY = round(centroid(2))-1:round(centroid(2))+1;
psf.x.data = squeeze(mean(slices(idxY,:,sliceIdx),1));
psf.y.data = squeeze(mean(slices(:,idxX,sliceIdx),2));

%Generate smooth PSF and get FWHM
for i = 1:numel(fields)
    %Recenter values so lowPercentile(X)=0
    data = psf.(fields(i)).data(:); %Make column vector
    data = (data-min(data))./range(data);

    %Smooth/fit
    X = profile.(fields(i)).X;
    smoothed = smooth(data, 5); %Smoothed data
    gaussian = fit(X(:), data, 'gauss1'); %Fit with 3rd-order Gaussian; keep cfit object for feval() in figures

    %Calculate PSF
    fittedData = feval(gaussian, X);
    [peak, loc, fwhm,~] = findpeaks(...
        fittedData, X, 'WidthReference', 'halfheight', 'NPeaks', 1, 'SortStr', 'descend');
    psf.(fields(i)) = struct(...
        "data",data,"X",X,"smoothed",smoothed,"gaussian",gaussian,"peak",peak,"loc",loc,"fwhm",fwhm);
end

img = struct("slices", slices, "meanProj", meanProj, "profile", profile, "xyMask", xyMask, "centroid" ,centroid,"tags",tags);