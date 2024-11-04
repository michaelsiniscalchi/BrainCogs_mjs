%%% fig_observedVsPredictedDFF()
%
% PURPOSE:  Plot overlay predicted dF/F from encoding model on observed dF/F
%
% AUTHORS: MJ Siniscalchi 241021
%
% INPUT ARGS:
%
%--------------------------------------------------------------------------

function figs = fig_observedVsPredictedDFF( bootAvg_img, bootAvg_encoding, cellIDs, expID, panels )

% Set up figure properties and restrict number of cells, if desired
setup_figprops('timeseries')  %set up default figure plotting parameters
% setup_figprops('placeholder'); %Customize for performance plots
% event = fieldnames(bootAvg);
% event = event{~ismember(event,{'t','position'})};
% trialTypes = fieldnames(bootAvg.(event));
% cellIdx = 1:numel(bootAvg.(event).(trialTypes{1}).cells);

trialTypes = fieldnames(bootAvg_encoding);
trialTypes = trialTypes(~ismember(trialTypes,{'t','position'}));
cellIdx = 1:numel(bootAvg_encoding.(trialTypes{1}).cells);

% Initialize figures
figs = gobjects(numel(cellIdx),1); %Initialize
fig_pos = [100,400,450,300]; %LBWH
legend_loc = 'bestoutside';
if numel(panels)>1
    fig_pos = [100,400,450*(numel(panels)),300]; %LBWH
end

%% Plot event-aligned dF/F for each cell
for i = 1:numel(cellIdx)

    % Assign specified signals to each structure in the array 'panels'
    idx = cellIdx(i); %Index in 'cells' structure for cell with corresponding cell ID
    disp(['Plotting trial-averaged dF/F for cell ' num2str(i) '/' num2str(numel(cellIdx)) '...']);
    for j = 1:numel(panels)

        %Time/position axis  
        fields = ["t","position"];
        fIndex = [isfield(bootAvg_encoding,'t'), isfield(bootAvg_encoding,'position')]; %If/elseif logic
        wIndex = bootAvg_encoding.(fields(fIndex)) >= panels(j).window(1) &...
            bootAvg_encoding.(fields(fIndex)) <= panels(j).window(2); %Domain from specBootAvgPanels()
        panels(j).x = bootAvg_encoding.(fields(fIndex))(wIndex);

        for k = 1:numel(panels(j).trialType)

            trialSpec = panels(j).trialType(k); %Trial specifier, eg {'left','hit','sound'}
            if ~isfield(bootAvg_encoding, trialSpec)
                panels(j).signal{k} = NaN(size(panels(j).x));
                panels(j).CI{k} = NaN(2,size(panels(j).x,2));
                continue;
            end

%             %Signal for observed fluorescence
%             panels(j).signal{k} = bootAvg_img.(trialSpec).cells(idx).signal(wIndex);
%             panels(j).CI{k} = NaN(2,sum(wIndex)); %Omit CI for mean signal
%             
%             %Mean signal and confidence bounds from encoding model
%             predictedIdx = k + numel(panels(j).trialType);
%             panels(j).signal{predictedIdx} =...
%                 bootAvg_encoding.(trialSpec).cells(idx).signal(wIndex);
%             panels(j).CI{predictedIdx} = bootAvg_encoding.(trialSpec).cells(idx).CI(:,wIndex);
 
            %Mean signal and confidence bounds from encoding model
            panels(j).signal{k} = bootAvg_encoding.(trialSpec).cells(idx).signal(wIndex);
            panels(j).CI{k} = bootAvg_encoding.(trialSpec).cells(idx).CI(:,wIndex);
            %Mean observed signal
            observedIdx = k + numel(panels(j).trialType);
            panels(j).signal{observedIdx} =...
                bootAvg_img.(trialSpec).cells(idx).signal(wIndex);
            %             panels(j).CI{observedIdx} = NaN(2,sum(wIndex)); %Omit CI for mean signal
            panels(j).CI{observedIdx} = bootAvg_img.(trialSpec).cells(idx).CI(:,wIndex);


            panels(j).legend_names{k} = "predicted";
            panels(j).legend_names{observedIdx}  = "observed";
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