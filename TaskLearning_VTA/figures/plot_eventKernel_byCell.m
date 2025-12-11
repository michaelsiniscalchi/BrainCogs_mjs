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

function figs = plot_eventKernels_byPerformance( cellStruct, sessions, panel )

% Set up figure properties and restrict number of cells, if desired
setup_figprops('timeseries')  %set up default figure plotting parameters

% Initialize figures
fig_pos = [100,400,600,400]; %LBWH
legend_loc = 'bestoutside';
if numel(panel)>1
    fig_pos = [100,400,300*(numel(panel)),300]; %LBWH
    legend_loc = 'best';
end



%% Plot event-aligned dF/F for each cell
    
for i = 1:numel(panel)
               
        varName = panel(i).varName;
        if ~isfield(cellStruct.kernel,varName)
            continue
        end

        for j = 1:numel(varName)
            
            %Truncate domain as specified in params
            wIndex = cellStruct.kernel.(varName(j)).x >= panel(i).window(1) &...
                cellStruct.kernel.(varName(j)).x <= panel(i).window(2); %Domain from specBootAvgPanels()
            %Initialize panel fields for time series
            if ~isfield(cellStruct.kernel, varName(j)) || isempty(varName(j))
                panel(i).signal{j} = NaN(size(wIndex));
                panel(i).CI{j} = NaN(2,size(wIndex,2));
                continue;
            end
            
            signal = cellStruct.kernel.(varName).estimate;
             for k = 1:size(signal,1)
                %Legend entries
                panel(i).legend_names{j} =...
                    strjoin([varName(j), "response"]); %Leading trial specifier, all others should generally be fixed

                %Signal and confidence bounds
                panel(i).x = cellStruct.kernel.(varName(j)).x(wIndex);
                panel(i).signal{j} = cellStruct.kernel.(varName(j)).estimate(:, wIndex);
                panel(i).CI{j} = cellStruct.kernel.(varName(j)).se(:, wIndex);

                nTimeseries = size(panel(i).signal{j},1);
                if size(panel(i).signal{j},1)>1
                    panel(i).color = panel(i).color{1}*linspace(0.1,1,nTimeseries);
                end
            end
        end

        %Labels
        if varName=="position"
            xLabel = 'Distance from start (cm)'; %Labels
        else
            xLabel = 'Time from event (s)'; %Labels
        end
        yLabel = 'Response (dF/F)';
    end

    ax_titles = {panel(:).title}'; %Specified in params.panels

    figs(i) = plot_trialAvgTimeseries(panel, ax_titles, xLabel, yLabel, legend_loc);

    figName = join([panel.title,'_', cellStruct.sessionID, '_cell', cellStruct.cellID{idx}],''); %Figure name
    figs(i).Name = figName;
    figs(i).Position = fig_pos; %LBWH
    figs(i).Visible = 'off';

end