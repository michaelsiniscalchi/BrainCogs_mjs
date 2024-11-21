function meanProj = calc_meanProj( reg_path )

%Typically one matfile per trial, derived from motion-corrected TIFFs using 'tiff2mat.m'

% Aggregate all frames from imaging data stored in MAT files
frames = cell(numel(reg_path),1); 
parfor i = 1:numel(reg_path)
    % Load Stack
    disp(['Loading [parallel] ' char(reg_path(i)) '...']);
    stack =  loadtiffseq(reg_path{i}); % load raw stack (.tif)
    %Shift dims for cat operation
    frames{i} = shiftdim(stack,2);
end

%Concatenate trials
M = cell2mat(frames);
meanProj = squeeze(mean(M,1));