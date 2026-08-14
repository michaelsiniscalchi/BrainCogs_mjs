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

function figs = fig_trialAvgDFF_summaryByCell( bootAvg, cellIdx, cellID, sessionStruct, panel, params )

% Set up figure properties and restrict number of cells, if desired
setup_figprops('GoogleSlides');  %set up default figure plotting parameters

%Get behavioral refs for each session
sessionNum = find([sessionStruct.isImgSession]);
sessionRule = [sessionStruct(sessionNum).taskRule];
sessionIDs = [sessionStruct(sessionNum).session_date];

%Filter sessions to include only those with signal from current cell
for i = 1:numel(sessionIDs)
    sessionIdx(i) = ~isnan(sum(bootAvg.(panel.trialType(1)).cells(cellIdx).sessions(i).signal));
end
sessionIdx = find(sessionIdx); %Convert to int for sequential indexing below
sessionNum = sessionNum(sessionIdx);
sessionRule = sessionRule(sessionIdx);
sessionIDs = sessionIDs(sessionIdx);

%Figure Layout
gridSize = [panel.gridSize]; %Should be same for all panels specified; one grid per session
nSessionsPerFig = gridSize(1)*gridSize(2)-1; %one grid unit per cell; save last space for legend

if numel(sessionIDs)>params.minNumSessions
nFigures = ceil(numel(sessionIdx)/nSessionsPerFig);
figs = gobjects(nFigures,1); %Initialize
else
    figs = gobjects();
    return
end

%% Plot event-aligned dF/F for each cell
for i = 1:numel(sessionIdx)

    %Make new figure if grid fully populated
    if mod(i,nSessionsPerFig)==1
        %Initialize figure
        f_idx = ceil(i/nSessionsPerFig); %figure Index
        if numel(sessionIDs)>nSessionsPerFig
            figName = join([join(["cell",cellID],''), panel.comparison, f_idx],'-'); %Figure name
        else
            figName = join([join(["cell",cellID],''), panel.comparison, panel.trialType],'-'); %Figure name
        end
        figs(f_idx) = figure('Name', figName);
        %Setup tiled layout
        figs(f_idx).Position = [100,100, 960, 480]; %Full Google Slide, 5 x 10
        T = tiledlayout(gridSize(1), gridSize(2),...
            'TileIndexing','rowmajor','TileSpacing','tight','Padding','tight');
    end
    %Row and Column Indices
    tileIdx = mod(i, nSessionsPerFig);
    tileIdx(tileIdx==0) = nSessionsPerFig; %Correct last cell tileIdx 0->nSessionsPerFig

    colIdx = mod(tileIdx, gridSize(2)); %Row position; ROW & COL idx reversed because this figure uses a rowmajor tiled layout
    colIdx(colIdx==0) = gridSize(2); %Correct last row idx: goes back to zero with mod() approach

    rowIdx = mod(ceil(tileIdx/gridSize(1)), gridSize(2)); %Row position; 0 if only one row
    rowIdx(rowIdx==0)=gridSize(1); %Correct last row idx: goes back to zero with mod() approach

    % rowIdx = mod(tileIdx, gridSize(1)); %Row position; ROW & COL idx reversed because this figure uses a rowmajor tiled layout
    % rowIdx(rowIdx==0)=gridSize(1); %Correct last row idx: goes back to zero with mod() approach
    % 
    % colIdx = mod(ceil(tileIdx/gridSize(1)), gridSize(2)); %Column position; 0 if only one column
    % colIdx(colIdx==0)=gridSize(2); %Correct last col idx: goes back to zero with mod() approach

    % Assign specified signals to each structure in the array 'panels'
    disp(['Plotting trial-averaged dF/F for ' cellID '...']);
    %Time/position axis
    fields = ["t","position"];
    fIndex = [isfield(bootAvg,'t'), isfield(bootAvg,'position')]; %If/elseif logic
    wIndex = bootAvg.(fields(fIndex)) >= panel.window(1) &...
        bootAvg.(fields(fIndex)) <= panel.window(2); %Domain from specBootAvgPanels()
    panel.x = bootAvg.(fields(fIndex))(wIndex);

    for k = 1:numel(panel.trialType)

        trialSpec = panel.trialType(k); %Trial specifier, eg {'left','hit','sound'}
        if ~isfield(bootAvg, trialSpec)
            panel.signal{k} = NaN(size(panel.x));
            panel.CI{k} = NaN(2,size(panel.x,2));
            continue;
        end

        %Legend entries
        leg_name =  split(char(trialSpec),'_');
        panel.legend_names{k} =  string([upper(leg_name{1}(1)), leg_name{1}(2:end)]); %Leading trial specifier, all others should generally be fixed

        if panel.verboseLegend
            %Remaining (fixed) trial conditions, if desired
            for kk = 2:numel(leg_name) %
                panel.legend_names{k} = join([panel.legend_names{k}, leg_name{kk}]);
            end
        end

        %Signal and confidence bounds
        panel.signal{k} = bootAvg.(trialSpec).cells(cellIdx).sessions(sessionIdx(i)).signal(wIndex);
        panel.CI{k} = bootAvg.(trialSpec).cells(cellIdx).sessions(sessionIdx(i)).CI(:,wIndex);
    end

    %Add title
    ruleStr = string([upper(sessionRule{i}(1)), sessionRule{i}(2:end)]);

    sessionStr = join(["Session", sessionNum(i)]); %Specified in params.panels
    titleCell = {[sessionStr; ruleStr]}; %Specified in params.panels
  
    %Add xlabel only to bottom row
    xLabel = [];
    if rowIdx==gridSize(1)
        xLabel = panel.xLabel; %Specified in params.panels
    end
    %Add yLabel only to leftmost column
    yLabel = [];
    if colIdx==1
        yLabel = {cellID; panel.yLabel};
    end
    %Add only one legend to each figure
    legend_loc = 'none';
    if tileIdx==nSessionsPerFig || i==numel(sessionIDs)
        legend_loc = 'layout';
    end

    %Plot
    [~, leg] = layout_trialAvgTimeseries( T, panel, titleCell, xLabel, yLabel, legend_loc, params );

    %Final fig modifications
    if tileIdx==nSessionsPerFig || i==numel(sessionIDs)
        %Figure legend
            leg.Layout.Tile = tileIdx + 1;
            leg.IconColumnWidth = 5; %Shrink along x-dimension
        clearvars leg
    end
end
%Hide figure prior to save outside this function
fontsize(figs(:), params.fontSize, "points");
[figs(:).Visible] = deal('off');




