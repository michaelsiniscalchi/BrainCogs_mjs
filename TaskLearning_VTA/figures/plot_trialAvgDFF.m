%%% plotTrialAvgDFF()
%
% PURPOSE:  To plot flexible summary of cellular fluorescence data from two-choice sensory
%               discrimination tasks.
%
% AUTHORS: MJ Siniscalchi 190912
%
% INPUT ARGS:
%
%--------------------------------------------------------------------------

function figs = plot_trialAvgDFF( bootAvg, cellIDs, expID, panels )

% Set up figure properties and restrict number of cells, if desired
setup_figprops('timeseries')  %set up default figure plotting parameters
% setup_figprops('placeholder'); %Customize for performance plots
% event = fieldnames(bootAvg);
% event = event{~ismember(event,{'t','position'})};
% trialTypes = fieldnames(bootAvg.(event));
% cellIdx = 1:numel(bootAvg.(event).(trialTypes{1}).cells);

trialTypes = fieldnames(bootAvg);
trialTypes = trialTypes(~ismember(trialTypes,{'t','position'}));
cellIdx = 1:numel(bootAvg.(trialTypes{1}).cells);

% Initialize figures
figs = gobjects(numel(cellIdx),1); %Initialize
fig_pos = [100,400,450,300]; %LBWH
legend_loc = 'bestoutside';
if numel(panels)>1
    fig_pos = [100,400,300*(numel(panels)),300]; %LBWH
    legend_loc = 'best';
end



%% Plot event-aligned dF/F for each cell

for i = 1:numel(cellIdx)

    % Assign specified signals to each structure in the array 'panels'
    idx = cellIdx(i); %Index in 'cells' structure for cell with corresponding cell ID
    disp(['Plotting trial-averaged dF/F for cell ' num2str(i) '/' num2str(numel(cellIdx)) '...']);
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
            panels(j).signal{k} = bootAvg.(trialSpec).cells(idx).signal(wIndex);
            panels(j).CI{k} = bootAvg.(trialSpec).cells(idx).CI(:,wIndex);
        end

        %Labels
        xLabel = panels(j).xLabel;
        yLabel = panels(j).yLabel;
    end

    ax_titles = {panels(:).title}'; %Specified in params.panels

    figs(i) = plot_trialAvgTimeseries(panels, ax_titles, xLabel, yLabel, legend_loc);

    figName = join([panels(j).comparison,'_', expID, '_cell', cellIDs{idx}],''); %Figure name
    figs(i).Name = figName;
    figs(i).Position = fig_pos; %LBWH
    figs(i).Visible = 'off';

end