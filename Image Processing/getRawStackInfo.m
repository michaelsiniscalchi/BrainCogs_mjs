function stackInfo = getRawStackInfo( sessionPath, options, saveMat )

%Batch convert all TIF stacks to MAT and get info
disp('Extracting metadata (stackInfo) from TIFFs...');
tic; %For command window output

% Handle Options
if nargin<2 || isempty(options)
    options.chan_number     = []; %For interleaved 2-color imaging; channel to convert.
    options.extract_I2C     = true; %Flag to extract I2C data from TIFF header
    options.read_method     = 'TiffLib';
end

if nargin<3
    saveMat = false;
end

%% Convert each TIF File and Extract Specified Header Info

%Paths to raw TIFFs and output matfile
% Setup Subdirectories and File Paths
tree = split(sessionPath, filesep);
rootDir = strjoin(tree(1:end-1),filesep);
dataDir = tree{end};
[~, paths] = iCorreFilePaths(rootDir, dataDir, 'raw');
tif_paths = paths.source;

%Extract metadata from TIFFs
ImageDescription = cell(numel(tif_paths),1); %Initialize cell array of image descriptions
parfor i = 1:numel(tif_paths)

    %Store name of source file
    [~,filename,ext] = fileparts(tif_paths{i});
    source = [filename ext];
    disp(['Extracting stackInfo [parallel] from ' source '...']);

    % Load Stack and Extract TIFF tags
    if i==1 %Bring stack and tags into workspace only once
        [stack{i}, tags{i}, ImageDescription{i}] = loadtiffseq(...
            tif_paths{i}, options.chan_number, options.read_method); % load raw stack (.tif)
    else
        [~, ~, ImageDescription{i}] = loadtiffseq(...
            tif_paths{i}, options.chan_number, options.read_method); % load raw stack (.tif)
    end

    %Store additional info
    %***Try to obtain from ImageDescription, etc. because we don't need this array
    % nFrames(i,1) = size(stack,3); %Store number of frames
    nFrames(i,1) = numel(ImageDescription{i}); %Store number of frames
end

%Copy tags to stackInfo structure
%Basic image info
stackInfo.class         = class(stack{1});
stackInfo.imageHeight   = tags{1}.ImageLength; %Editing tags may be necessary after cropping
stackInfo.imageWidth    = tags{1}.ImageWidth;
stackInfo.nFrames       = nFrames(:); %Store number of frames
stackInfo.tags          = tags{1}; %Frame-invariant tags

%Append session start-time
if ~isempty(ImageDescription{end}{1}) %Tag removed before saving processed TIFFs
    stackInfo.tags.ImageDescription = ImageDescription; %Frame-specific
    D = textscan(ImageDescription{1}{1},'%s%s','Delimiter',{'='});
    stackInfo.startTime = str2num(D{2}{strcmp(D{1},'epoch ')});
end

%Extract I2C Data if specified
if options.extract_I2C
    %Concatenate cell arrays for each TIFF stack
    stackInfo.I2C = getI2CData(vertcat(ImageDescription{:}));
end

%Console display
disp(['Time needed to extract stackInfo from TIFFs: ' num2str(toc) ' seconds.']);

%Append filenames for raw and registered tiffs
[~,fnames,ext] = fileparts(paths.raw);
stackInfo.rawFileNames = join([fnames,ext],'',2);

%Save stackInfo in matfile if specified
if saveMat
    %Save stackInfo structure
    if ~exist(paths.stackInfo,"file")
        save(paths.stackInfo,'-STRUCT','stackInfo','-v7.3');
    else
        save(paths.stackInfo,'-STRUCT','stackInfo','-append');
    end
end