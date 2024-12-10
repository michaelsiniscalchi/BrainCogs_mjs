function fig = fig_meanProj( figData, params )

% Initialize figure
fig = figure('Visible','on');
ax = gca;
img = imagesc(ax, figData.meanProj); hold on;

%B&W levels as lower and upper percentiles
p = prctile(img.CData,[params.blackLevel params.whiteLevel],'all'); 

%Overlay ROIs, if specified
if params.overlay_ROIs
      roi_dir = figData.roi_dir; %Full path to ROI directory
      flist = dir(fullfile(roi_dir,'*cell*'));
        for i = 1:numel(flist)
            roiPath{i,:} = fullfile(flist(i).folder,flist(i).name);
        end
          
        S(numel(roiPath)) = struct('bw',[],'subtractmask',[]);
        for i = 1:numel(roiPath)
            temp = load(roiPath{i},'bw','subtractmask');
            if isfield(temp,'subtractmask')
                S(i) = temp;     
            else, S(i).bw = zeros(size(temp.bw));
            end
            cellMasks(:,:,i) = S(i).bw;
            cellIDs(i) = string(roiPath{i}(end-6:end-4));
        end
        roiObjs = plot_ROIs(cellMasks,cellIDs,'r');
    
    % ***WIP, good up to here...
    if params.overlay_npMasks
        for i = 1:numel(roiPath)
            npMasks(:,:,i) = S.subtractmask;
        end
        npObjs = plot_npMasks(npMasks,'c');
    end
end

%Square unenumerated axes 
set(ax,'XTick',[],'YTick',[],'CLim',p); %Set properties
colormap(params.colormap);
axis square;

function h = plot_ROIs(cellMasks, cellIDs, color)        

%Plot all ROIs from a stack of cellMasks
h = gobjects(size(cellMasks,3),1);
for i = 1:numel(h)
    bounds = bwboundaries(cellMasks(:,:,i)); %Boundaries of logical mask for current ROI
    if ~isempty(bounds)
        roi = [bounds{1}(:,2) bounds{1}(:,1)]; %Boundary coordinates in xy
        h(i) = plot(roi(:,1),roi(:,2),color,'LineWidth',1);
        pos = [mean(roi(:,1)), max(roi(:,2))];
        text(pos(1),pos(2),cellIDs(i),"HorizontalAlignment","left","Color",'c');
    end
end

function npPolys = plot_npMasks(npMasks, color)        

% Plot all ROIs from a stack of cellMasks

npPoly = gobjects(size(npMasks,3),1); %Inititialize graphics array
for i = 1:numel(npPoly)
    npPoly = polyshape(size(npMasks,3),1); %Polygon vertices for the neuropil 'subtractmask' for each ROI polyshape
    bounds = bwboundaries(cellMasks(:,:,i)); %Boundaries of logical mask for current ROI
    roi = [bounds{1}(:,2) bounds{1}(:,1)]; %Boundary coordinates in xy
    plot(roi(:,1),roi(:,2),color,'LineWidth',1);
end
npPoly(i) = getNpPoly(S.subtractmask); %Generate polygon representation (graphics object)