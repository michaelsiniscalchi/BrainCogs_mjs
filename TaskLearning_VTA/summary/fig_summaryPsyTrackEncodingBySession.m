function figs = fig_summaryPsyTrackEncodingBySession(sessions, cells, panelSpec, params)

setup_figprops('placeholder'); %Customize for performance plots
colors = setPlotColors('mjs_tactile2visual');

%% Plot psytrack coef and summary metric from encoding


%Filter cell struct
P = panelSpec;
cells = cells(cellfun(@numel,{cells.session_date})>=params.minNumSessions); %Restrict to cells with min number of sessions

for i=1:numel(cells)

    figs(i) = figure('Name',strjoin(...
        ['beh-encoding', P.title, ['cell',cells(i).cellID]], '-'));

    %Behavioral variable, eg, PsyTrack weight or %correct
    idx = ismember([sessions.session_date], cells(i).session_date); %session dates for cell(i)
    behVar = [sessions(idx).(P.behVar)];
    behVarSE = [sessions(idx).(P.behVarSE)];

    %Imaging variable, eg, encoding model coefficient or scalar kernel summary
    imgVar = cells(i).(P.encVar(1)).(P.encVar(2)).(P.encVar(3));

    %Domain, session date or session number
    X = 1:numel(sessions(idx));
    % xticklabels = string([sessions(idx).session_date]);

    %Set color order
    colororder([P.color{1}; P.color{2}]);

    %Left (behavioral) axis
    yyaxis left; hold on
    ax=gca;
    plot(X, behVar);
    
    xlabel(P.xLabel);
    ylabel(P.yLabel(1));

    %Right (neural) axis
    yyaxis right;
    plot(X, imgVar);
    set(gca,'XTick',X);
    xlim([0.5,max(X)+0.5]);
    ylabel(P.yLabel(2));
    box off;

    %Mark Rule Switch
    ruleOrder = unique([sessions.taskRule], 'stable');
    switchX = find([sessions.taskRule]==ruleOrder(2),1,'first')-0.5;
    plot([switchX,switchX],[0,max(ylim)],':','Color',colors.gray);
    txtY = min(ylim)+0.05*range(ylim);
    text(switchX,txtY,strjoin(ruleOrder,'->'),'HorizontalAlignment','center','Color',colors.gray);

    %Title
    title(P.title);


end