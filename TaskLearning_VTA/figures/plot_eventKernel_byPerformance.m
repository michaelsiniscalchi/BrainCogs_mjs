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

function figs = plot_eventKernel_byPerformance( cellStruct, sessions, varName )

% Set up figure properties and restrict number of cells, if desired
setup_figprops('timeseries')  %set up default figure plotting parameters

% Initialize figures
fig_pos = [100,400,1200,600]; %LBWH
legend_loc = 'layout'; %'bestoutside';
cbrew = struct('visual','GnBu','tactile','RdPu','pooled','Greys'); % cbrewer settings

% Fixed params (some DEVO)
ruleNames = ["tactile","visual","pooled"];
sortBy = 'pCorrect';

%% Overlay specified temporal kernels for each cell

for i = 1:numel(cellStruct) %Loop through cells

    %Restrict to PsyTracked sessions where cell is present
    S = sessions(ismember([sessions.session_date], cellStruct(i).session_date));

    %Sort sessions ascending, by specified behavioral variable (eg, %correct)
    [~, idx] = sort([S.(sortBy)]);
    S = S(idx);
    kernels = cellStruct(i).kernel.(varName).estimate(idx,:);
    X = cellStruct(i).kernel.(varName).x;

    %Initialize panel struct
    for j = 1:numel(ruleNames)
        panel(j).x = X;
        panel(j).signal = {NaN(size(X))};
        panel(j).color = {[0,0,0]};
        panel(j).lineStyle = {'-'};
        panel(j).legend_names = {''};
        panel(j).title = [upper(ruleNames{j}(1)), ruleNames{j}(2:end)];
    end

    %Index distinct rule blocks
    for j = 1:numel(ruleNames)

        %Index sessions by specified rule(s)
        if ruleNames(j)=="pooled"
            ruleIdx = true(size([S.taskRule]));
        else
            ruleIdx = [S.taskRule]==ruleNames(j);
        end

        if sum(ruleIdx)<1
            continue
        end

        %Plot ordered data separated by rule
        signal = kernels(ruleIdx,:);
      
        %Colors and legend entries
        if sum(ruleIdx)>2
            colors.(ruleNames(j)) = cbrewer('seq', cbrew.(ruleNames(j)), sum(ruleIdx));
        else %Only 2 sessions
            C = getFigColors();
            colors.(ruleNames(j)) = [C.([char(ruleNames(j)),'2']); C.(ruleNames(j))]; %{darker; lighter}
        end

        sessionDates = [S(ruleIdx).session_date];
        sessionDates.Format = 'yyMMdd';
        sessionDates = string(sessionDates);
        sortMetric = [S(ruleIdx).(sortBy)]; %pCorrect, etc.

        nTimeseries = size(signal,1);
        for k = 1:nTimeseries
            panel(j).signal{k} = signal(k,:);
            panel(j).lineStyle{k} = '-';
            panel(j).color{k} = colors.(ruleNames(j))(k,:);
            panel(j).legend_names{k} =...
                strjoin([sessionDates(k), ' (', num2str(sortMetric(k),2), ')'],'');
        end
    end

    %Labels
    ax_titles = ruleNames;
    if ismember(varName,["position","towerSide_position","puffSide_position"])
        xLabel = 'Distance from start (cm)'; %Labels
    else
        xLabel = 'Time from event (s)'; %Labels
    end
    yLabel = 'Regression coef. (dF/F)';

    figs(i) = plot_trialAvgTimeseries(panel, {panel.title}, xLabel, yLabel, legend_loc);

    figName = join([varName, '-', sortBy, '-cell', cellStruct(i).cellID],''); %Figure name
    figs(i).Name = figName;
    figs(i).Position = fig_pos; %LBWH
    figs(i).Visible = 'off';

end