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

function figs = plot_eventKernel( glm, panels )

% Set up figure properties and restrict number of cells, if desired
setup_figprops('timeseries')  %set up default figure plotting parameters

cellIdx = 1:numel(glm.cellID);

% Initialize figures
figs = gobjects(numel(cellIdx),1); %Initialize
fig_pos = [100,400,600,400]; %LBWH
legend_loc = 'bestoutside';
if numel(panels)>1
    fig_pos = [100,400,300*(numel(panels)),300]; %LBWH
    legend_loc = 'best';
end



%% Plot event-aligned dF/F for each cell

for i = 1:numel(cellIdx)

    % Assign specified signals to each structure in the array 'panels'
    idx = cellIdx(i); %Index in 'cells' structure for cell with corresponding cell ID
    disp(['Plotting event kernels for ' num2str(i) '/' num2str(numel(cellIdx)) '...']);
    for j = 1:numel(panels)
               
        varName = panels(j).varName;
        if ~isfield(glm.kernel,varName)
            continue
        end

        for k = 1:numel(varName)
            
            %Truncate domain as specified in params
            wIndex = glm.kernel(i).(varName(k)).x >= panels(j).window(1) &...
                glm.kernel(i).(varName(k)).x <= panels(j).window(2); %Domain from specBootAvgPanels()
            %Initialize panel fields for time series
            if ~isfield(glm.kernel, varName(k)) || isempty(varName(k))
                panels(j).signal{k} = NaN(size(wIndex));
                panels(j).CI{k} = NaN(2,size(wIndex,2));
                continue;
            end

            %Legend entries
            panels(j).legend_names{k} =...
                strjoin([varName(k), "response"]); %Leading trial specifier, all others should generally be fixed

            %Signal and confidence bounds
            panels(j).x = glm.kernel(i).(varName(k)).x(wIndex);
            panels(j).signal{k} = glm.kernel(i).(varName(k)).estimate(wIndex);
            panels(j).CI{k} = glm.kernel(i).(varName(k)).se(:, wIndex);
        
            % panels(j).color = panels(j).color(end);
        end
        
        %Labels
        xLabel = panels.xLabel;
        yLabel = panels.yLabel;

    end

    ax_titles = {panels(:).title}'; %Specified in params.panels

    figs(i) = plot_trialAvgTimeseries(panels, ax_titles, xLabel, yLabel, legend_loc);

    figName = join([panels.title,'_', glm.sessionID, '_cell', glm.cellID{idx}],''); %Figure name
    figs(i).Name = figName;
    figs(i).Position = fig_pos; %LBWH
    figs(i).Visible = 'off';

end