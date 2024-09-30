%%% calcCellF
%
%PURPOSE: To adjust cellF based on two spatial exclusions:
%       1.) Overlapping regions of multiple ROIs are excluded.
%       2.) An n-pixel width boundary is excluded at the edge of each frame.
%
%AUTHOR: MJ Siniscalchi, 190222
%           -190619mjs Edited to accommodate trial-by-trial movement corrected data...
%
%INPUT ARGS:    struct 'cells', containing these fields:
%                   'roimask', a cell array of logical masks,
%                       each indexing a ROI within the field of view.
%                   'subtractmask', same for the neuropil masks.
%               double 'stack' OR
%               cell   'stack', containing full path to each stack as .MAT
%               double 'borderWidth'
%
%OUTPUTS:
%               struct roiData, with fields:
%                   cellf:      1d cell array containing final cellular fluorescence for each ROI, post processing
%                   neuropilf:  (same for neuropil fluorescence)
%                   roi:        (same for cell masks)
%                   npMask:     (same for neuropil masks)
%
%               struct mask, with fields:
%                   include, exclude: binary arrays containing included/excluded regions
%
%--------------------------------------------------------------------------

function [cells, masks] = calc_cellF( cells, expData, borderWidth )

%Get image info for the series of stacks
nX = expData.img_beh.imageWidth;
nY = expData.img_beh.imageHeight;
nStacks = numel(expData.reg_path);
nFrames = expData.img_beh.nFrames;

%Convert from cell arrays to 3d matrices to project common masks across rois
cellMasks = reshape(cell2mat(cells.cellMask),[nY,nX,numel(cells.cellMask)]); %dim:nY,nX,nROIs
npMasks = reshape(cell2mat(cells.npMask),[nY,nX,numel(cells.npMask)]);

%Generate inclusion/exclusion masks
masks.include = false(nX,nY); %Initialize
masks.exclude = false(nX,nY);
if nargin > 2
    masks.exclude([(1:borderWidth) (nY-borderWidth+1:nY)],:) = true; %Frame around image: Top and bottom
    masks.exclude(:,[(1:borderWidth) (nX-borderWidth+1:nX)]) = true; %Left and right
end
masks.exclude(sum(cellMasks,3)>1) = true;     %Overlapping Regions of multiple cells
masks.include(sum(cellMasks,3)==1 & ~masks.exclude) = true; %Logical idx for all ROIs after exclusion

%% Get cellular and neuropil fluorescence, excluding Frame and Overlapping regions

disp(['Getting cellular and neuropil fluorescence, excluding '...
    num2str(borderWidth) '-pixel frame and overlapping regions...']);

% Remove entries for cells excluded in cellROI.m
cellMasks = cellMasks(:,:,~cells.exclude); %Exclude exclusion masks
npMasks = npMasks(:,:,~cells.exclude); 
cells.cellID = cells.cellID(~cells.exclude);
cells = rmfield(cells,'exclude');

% Pre-allocate memory and define spatial masks
[roi, npMask] = deal(cell([size(cellMasks,3),1]));
for j = 1:numel(roi)
    roi{j} = logical(cellMasks(:,:,j) & ~masks.exclude); %Cell mask from cellROI, excluding specified regions
    npMask{j} = logical(npMasks(:,:,j) & ~masks.exclude); %Neuropil mask from cellROI, excluding specified regions
end

%Load and Process Stacks in Parallel
[cellF, npF] = deal(cell(1,nStacks)); %Cells for collecting mean F (nROI x nFrames) for each image stack
regPath = expData.reg_path(:); %Unpack for parallelization
parfor i = 1:nStacks
    disp(join(['Getting cellular fluorescence traces from ' regPath(i) '...']));
    stack = loadtiffseq(regPath(i)); %Load registered stack
    [fi, npfi] = deal(nan(numel(roi),nFrames(i))); %Cellular fluorescence, neuropil fluorescence in stack(i)
    %For each ROI, index pixels x time, reshape, take mean across pixels
    for k = 1:numel(roi)
        fi(k,:) = getTrace(stack, roi{k}); %Fluorescence trace from roi{k} across frames in stack
        npfi(k,:) = getTrace(stack, npMask{k}); %#ok<PFBNS> %Same for neuropil mask
    end
    cellF{i} = fi;
    npF{i} = npfi;
end

%Concatenate data cells from individual stacks
% cells.cellF = mat2cell(cell2mat(cellF), ones(1,numel(roi)), sum(nFrames));
% cells.npF = mat2cell(cell2mat(npF), ones(1,numel(roi)), sum(nFrames));
cellF = cell2mat(cellF); %nNeurons x nFrames
npF  = cell2mat(npF);
%Truncate to match image time vector, t 
t = expData.img_beh.t;
cellF = cellF(:, 1:numel(t));
npF = npF(:, 1:numel(t));
%Store in structure
cells.t = t; %time vector 
cells.cellF = mat2cell(cellF, ones(1,numel(roi)), numel(t)); %cellular fluorescence, 1 x nTimepoints, one cell per neuron
cells.npF = mat2cell(npF, ones(1,numel(roi)), numel(t)); %neuropil fluorescence, same format
cells.cellMask = roi;
cells.npMask = npMask;

function F = getTrace( stack, pixMask )
nPix = sum(pixMask,"all");
nFrames = size(stack,3);
pixMask = repmat(pixMask,1,1,nFrames); %3D mask of pixels across frames
pixF = reshape(stack(pixMask),[nPix,nFrames]); %Extract values indexed by pixMask
F = mean(pixF,1);