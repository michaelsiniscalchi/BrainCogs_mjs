%%% fig_trialAvgDFF_summaryBySession()
%
% PURPOSE:  To plot flexible summary of cellular fluorescence data from two-choice sensory
%               discrimination tasks.
%
% AUTHORS: MJ Siniscalchi 190912
%
% INPUT ARGS:
%
%--------------------------------------------------------------------------

function figs = fig_trialAvgDFF_summaryBySession( bootAvg, expIdx, expID, cellIDs, panels, params )

% Set up figure properties and restrict number of cells, if desired
setup_figprops('GoogleSlides');  %set up default figure plotting parameters

% Initialize figures
%Filter cells to include only those with signal in current session
for i=1:numel(cellIDs)
    cellIdx(i,:) = ~isnan(sum(bootAvg.(panels(1).trialType(1)).cells(i).sessions(expIdx).signal));
end
singleCellIdx = ~ismember(cellIDs,["fov","allCells"]); %restrict to actual cells (not aggregates)
cellIDs = cellIDs(cellIdx & singleCellIdx);
cellIdx = find(cellIdx(singleCellIdx)); %Convert to int for sequential indexing below

gridSize = [panels(1).gridSize]; %Should be same for all panels specified; one grid per cell in this case, in grid could consist of multiple panels
nCellsPerFig = gridSize(1)*gridSize(2)-1; %one grid unit per cell; save last space for legend

nFigures = floor(numel(cellIDs)/nCellsPerFig)...
    + (mod(numel(cellIDs), (gridSize(1)*gridSize(2)))>0);
figs = gobjects(nFigures,1); %Initialize

%% Plot event-aligned dF/F for each cell
for i = 1:numel(cellIDs)
   
    %Make new figure if grid fully populated
    if mod(i,nCellsPerFig)==1
        %Initialize figure
        f_idx = ceil(i/nCellsPerFig); %figure Index        
        if numel(cellIDs)>nCellsPerFig
            figName = join([expID, panels(1).comparison, f_idx],'-'); %Figure name
        else
            figName = join([expID, panels(1).comparison],'-'); %Figure name
        end
        figs(f_idx) = figure('Name', figName);
        %Setup tiled layout
        if gridSize(2)==1 && numel(panels)>1
            %Size to fit half of a Google Slide, ~4.75x4.75
            figs(f_idx).Position = [100,100,456,456]; %1 {pixel,point} = {1/96,1/72} inches; 456 pix = 4.75 in
            %If only one cell per row with multiple panels per cell, leave space for legends in the last row
            T = tiledlayout(gridSize(1), gridSize(2)*numel(panels),'TileSpacing','tight','Padding','tight');
        else  %Full Google Slide, 5 x 10
            figs(f_idx).Position = [100,100, 960, 480];
            T = tiledlayout(gridSize(1), gridSize(2)*numel(panels),...
                'TileIndexing','columnmajor','TileSpacing','tight','Padding','tight');
        end
    end
    %Row and Column Indices
    tileIdx = mod(i,nCellsPerFig);
    tileIdx(tileIdx==0) = nCellsPerFig; %Correct last cell tileIdx 0->nCellsPerFig

    rowIdx = mod(tileIdx,gridSize(1)); %Row position
    rowIdx(rowIdx==0)=gridSize(1); %Correct last row idx: goes back to zero with mod() approach
    
    colIdx = mod(ceil(tileIdx/gridSize(1)), gridSize(2)); %Column position; 0 if only one column
    colIdx(colIdx==0)=gridSize(2); %Correct last col idx: goes back to zero with mod() approach

    % Assign specified signals to each structure in the array 'panels'
    disp(['Plotting trial-averaged dF/F for ' expID '...']);
    for j = 1:numel(panels)

        %Time/position axis
        fields = ["t","position"];
        fIndex = [isfield(bootAvg,'t'), isfield(bootAvg,'position')]; %If/elseif logic
        wIndex = bootAvg.(fields(fIndex)) >= panels(j).window(1) &...
            bootAvg.(fields(fIndex)) <= panels(j).window(2); %Domain from specBootAvgPanels()
        panels(j).x = bootAvg.(fields(fIndex))(wIndex);

        for k = 1:numel(panels(j).trialType)

            trialSpec = panels(j).trialType(k); %Trial specifier, eg {'left','hit','sound'}
            if ~isfield(bootAvg, trialSpec)
                panels(j).signal{k} = NaN(size(panels(j).x));
                panels(j).CI{k} = NaN(2,size(panels(j).x,2));
                continue;
            end

            %Legend entries
            leg_name =  split(char(trialSpec),'_');
            panels(j).legend_names{k} =  string([upper(leg_name{1}(1)), leg_name{1}(2:end)]); %Leading trial specifier, all others should generally be fixed

            if panels(j).verboseLegend
                %Remaining (fixed) trial conditions, if desired
                for kk = 2:numel(leg_name) %
                    panels(j).legend_names{k} = join([panels(j).legend_names{k}, leg_name{kk}]);
                end
            end

            %Signal and confidence bounds
            panels(j).signal{k} = bootAvg.(trialSpec).cells(cellIdx(i)).sessions(expIdx).signal(wIndex);
            panels(j).CI{k} = bootAvg.(trialSpec).cells(cellIdx(i)).sessions(expIdx).CI(:,wIndex);
        end
    end

    %Add title
    titleStr = [];
    if rowIdx==1
        titleStr = {panels(:).title}'; %Specified in params.panels
    end
    %Add xlabel only to bottom row
    xLabel = [];
    if rowIdx==gridSize(1)
        xLabel = panels(1).xLabel; %Specified in params.panels
    end
    %Add yLabel only to leftmost column
    yLabel = {cellIDs(i)};
    if colIdx==1 || gridSize(2)==1
        yLabel = {cellIDs(i); panels(j).yLabel};
    end
    %Add only one legend to each figure
    legend_loc = 'none';
    if mod(i,nCellsPerFig)==0 || i==numel(cellIDs)
        legend_loc = 'layout';
    end

    %Plot
    [~, leg] = layout_trialAvgTimeseries( T, panels, titleStr, xLabel, yLabel, legend_loc, params );

    %Final fig modifications
    if i/f_idx==nCellsPerFig || i==numel(cellIDs)
        %Figure legend
        if numel(leg)>1
            for j = 1:numel(leg)
                leg(j).Layout.Tile = rowIdx*T.GridSize(2) + j; %Axes horizontally stacked for each cell
                leg(j).IconColumnWidth = 5; %Shrink along x-dimension
            end
        else
            % leg(j).Layout.Tile = mod(i,nCellsPerFig)+1;
            leg(j).Layout.Tile = tileIdx + 1;
            leg(j).IconColumnWidth = 5; %Shrink along x-dimension
        end
        % end
        clearvars leg
    end
end
%Hide figure prior to save outside this function
fontsize(figs(:), params.fontSize, "points");
[figs(:).Visible] = deal('off');




