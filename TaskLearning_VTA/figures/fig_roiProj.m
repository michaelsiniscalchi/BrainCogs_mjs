function [fig,ax] = fig_roiProj(mat_path,roi_dir)

% Aggregate all frames from imaging data stored in MAT files
frames = cell([numel(mat_path),1]); 
for i = 1:numel(mat_path)
    disp(['Loading ' mat_path{i} '...']);
    S = load(mat_path{i});
    frames{i} = shiftdim(S.stack,2); 
end
%Concatenate trials
M = cell2mat(frames);
M = squeeze(mean(M,1));

%Generate figure
fig = figure;
ax = gca;
img = imagesc(ax,M);

%B&W levels as lower and upper percentiles
p = prctile(img.CData,[20 99.7],'all'); 

%Square unenumerated axes 
set(ax,'XTick',[],'YTick',[],'CLim',p); %Set properties
colormap('pink');
axis square;