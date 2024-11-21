function fig = fig_meanProj( figData, params )

% Initialize figure
fig = figure('Visible','on');
ax = gca;
img = imagesc(ax,figData.meanProj); hold on;

%B&W levels as lower and upper percentiles
p = prctile(img.CData,[params.blackLevel params.whiteLevel],'all'); 

%Overlay ROIs, if specified
if params.overlay_ROIs
    
    cellIDs = params.cellIDs{expIdx}; %Cell IDs specified in params for each session, or [] for all.
    roi_dir = figData.roi_dir; %Full path to ROI directory
    if ~isempty(cellIDs)
        for i = 1:numel(cellIDs)
            flist = dir(fullfile(roi_dir,['*' cellIDs{i} '*']));
            roiPath{i,:} = fullfile(flist.folder,flist.name);
        end
          
        for i = 1:numel(roiPath)
            S(i) = load(roiPath{i},'bw','subtractmask');
            cellMasks(:,:,i) = S(i).bw;
        end
        roiObjs = plot_ROIs(ax,cellMasks,'r');
    end
    
    % ***WIP, good up to here...
    if params.overlay_npMasks
        for i = 1:numel(roiPath)
            npMasks(:,:,i) = S.subtractmask;
        end
        npObjs = plot_npMasks(ax,npMasks,'c');
    end
end

%Square unenumerated axes 
set(ax,'XTick',[],'YTick',[],'CLim',p); %Set properties
colormap(params.colormap);
raxis square;