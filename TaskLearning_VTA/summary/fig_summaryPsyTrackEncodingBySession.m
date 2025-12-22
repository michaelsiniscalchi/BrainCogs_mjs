function figs = fig_summaryPsyTrackEncodingBySession(sessions, cells, panelSpec, params)

setup_figprops('placeholder'); %Customize for performance plots
colors = setPlotColors('mjs_tactile2visual');

%% Plot psytrack coef and summary metric from encoding


%Filter cell struct
P = panelSpec;
cells = cells(cellfun(@numel,{cells.session_date})>=params.minNumSessions); %Restrict to cells with min number of sessions

%Truncate psyTrack variable name
behVarName = P.behVar;
if regexp(P.behVar,'(psyTrack)')
    idx = regexp(P.behVar,'(_)');
    behVarName = ['psy', upper(P.behVar{1}(idx(1)+1)), P.behVar{1}(idx(1)+2:idx(end)-1)]; %truncate prefix 'psyTrack' and lose suffix 'meanCoef'
end

for i=1:numel(cells)

    figs(i) = figure('Name',strjoin(...
        [P.encVar(2:3), behVarName, ['cell', cells(i).cellID]], '-'));

    %Imaging variable, eg, encoding model coefficient or scalar kernel summary
    imgVar = cells(i).(P.encVar(1)).(P.encVar(2)).(P.encVar(3));

    %Domain, session date or session number
    idx = ismember([sessions.session_date], cells(i).session_date); %session dates for cell(i)
    X = 1:numel(sessions(idx));

    %Set color order
    colororder([P.color{1}; P.color{2}]);

    %Left (behavioral) axis
    yyaxis left; hold on
    ax=gca;
    
    %Behavioral variable, eg, PsyTrack weight or %correct
    behVar = [sessions(idx).(P.behVar)];
    if ~isempty(P.behVarSE)
        behVarSE = [sessions(idx).(P.behVarSE)];
        errorshade(X, behVarSE(2,:), behVarSE(1,:), P.color{1}, 0.3); hold on;
    end
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
    plot([switchX,switchX],[min(ylim),max(ylim)],':','Color',colors.gray);
    txtY = min(ylim)+0.05*range(ylim);
    text(switchX,txtY,strjoin(ruleOrder,'->'),'HorizontalAlignment','center','Color',colors.gray);

    %Title
    title(P.title);


end