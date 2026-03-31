function fig = fig_summaryEncodingPSigBySession(sessions, population, panelSpec, params);

setup_figprops('placeholder'); %Customize for performance plots
colors = setPlotColors('mjs_tactile2visual');

%% Plot Proportion Significant from Encoding Model, Overlayed with Behavioral Correlate

P = panelSpec;

%FUTURE: one fig with all cells and another with only cells included in min nSessions
% params.minNumSessions; %Restrict to cells with min number of sessions

%Encoding variable
encVar = P.encVar(2);

%Truncate psyTrack variable name
behVarName = P.behVar;
if regexp(P.behVar,'(psyTrack)')
    idx = regexp(P.behVar,'(_)');
    behVarName = ['psy', upper(P.behVar{1}(idx(1)+1)), P.behVar{1}(idx(1)+2:idx(end)-1)]; %truncate prefix 'psyTrack' and lose suffix 'meanCoef'
end

    fig = figure('Name',strjoin(...
        [encVar, 'pSig-vs', behVarName], '-'));

    %Imaging variable, eg, encoding model coefficient or scalar kernel summary
    imgVar = [population.pSignificant.(encVar)];

    %Domain, session date or session number
    X = 1:numel(population.sessionDates);

    %Set color order
    colororder([P.color{1}; P.color{2}]);

    %Left (behavioral) axis
    yyaxis left; hold on
    ax=gca;
    
    %Behavioral variable, eg, PsyTrack weight or %correct
    behVar = [sessions.(P.behVar)];
    if ~isempty(P.behVarSE)
        behVarSE = [sessions.(P.behVarSE)];
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
    ylim([0,1]);
    ylabel(['Proportion of cells with p<' num2str(population.alpha)]);
    box off;

    %Mark Rule Switch
    ruleOrder = unique([sessions.taskRule], 'stable');
    switchX = find([sessions.taskRule]==ruleOrder(2),1,'first')-0.5;
    plot([switchX,switchX],[min(ylim),max(ylim)],':','Color',colors.gray);
    txtY = min(ylim)+0.05*range(ylim);
    text(switchX,txtY,strjoin(ruleOrder,'->'),'HorizontalAlignment','center','Color',colors.gray);

    %Title
    title(P.title);
