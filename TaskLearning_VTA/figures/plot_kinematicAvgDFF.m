%%% plot_kinematicAvgDFF()
%
% PURPOSE:  To plot flexible summary of cellular fluorescence data from two-choice sensory
%               discrimination tasks.
%
% AUTHORS: MJ Siniscalchi 190912
%
% INPUT ARGS:
%
%--------------------------------------------------------------------------

function figs = plot_kinematicAvgDFF( kinematicAvg, cellIDs, expID, params )

% Set up figure properties and restrict number of cells, if desired
setup_figprops('timeseries')  %set up default figure plotting parameters

% Initialize figures
figs = gobjects(numel(cellIDs),1); %Initialize
fig_pos = [200, 200, 1000, 400]; %LBWH
legend_loc = 'best';

%% Plot dF/F for each cell as function of running speed and heading
for i = 1:numel(cellIDs)

    % Assign specified signals to each structure in the array 'panels'
    disp(['Plotting speed/heading-averaged dF/F for cell ' num2str(i) '/' num2str(numel(cellIDs)) '...']);
    
    %Running Speed & Heading
    fields = ["speed","acceleration","heading"];
    for j = 1:numel(fields)
        %Domain: speed or heading
        panels(j).x = kinematicAvg.(fields(j)).x;
        %Signal and confidence bounds
        panels(j).signal{1} = kinematicAvg.(fields(j)).mean(i,:); %Cell array required to allow for multiple overlayed data series
        panels(j).CI{1}        = kinematicAvg.(fields(j)).CI{i};
        %Lineseries formatting
        panels(j).color{1}  = params.colors.(fields(j));
        panels(j).lineStyle{1} = '-';
        %Legend entries
        panels(j).legend_names{1} = fields(j);
        %Labels
        ax_titles(j) = "";
        xLabels(j) = params.xLabel.(fields(j));
    end
    yLabel = "Cellular fluorescence (dF/F)";

    figs(i) = plot_trialAvgTimeseries(panels, ax_titles, xLabels, yLabel, params.tickLabelFormat, legend_loc);

    %Resize x-axes (standardized by default)
    ax = findobj(figs(i).Children,'Type', 'Axes'); %Get axes
    ax = (flipud(ax)); %Stacked opposite order of creation
    for j = 1:numel(ax)
        ax(j).XLim = [min(panels(j).x), max(panels(j).x)];
    end

    %Add some whitespace to tiled layout
    T = findobj(figs(i).Children,'Type', 'TiledLayout'); %Get axes
    T.Padding = 'tight';
    T.TileSpacing = 'compact';

    %Set remaining Figure Properties
    figName = join(['kinematicAvg-', expID, '-cell', cellIDs{i}],''); %Figure name
    figs(i).Name = figName;
    figs(i).Position = fig_pos; %LBWH
    figs(i).Visible = 'off';

end