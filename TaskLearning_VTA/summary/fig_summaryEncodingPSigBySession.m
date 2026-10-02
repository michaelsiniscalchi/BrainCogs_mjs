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

    %Mark Rule Switch with break in lineseries
    ruleOrder = unique([sessions.taskRule], 'stable');
    switchX = find([sessions.taskRule]==ruleOrder(2),1,'first')-0.5;
       
    %Behavioral variable, eg, PsyTrack weight or %correct
    behVar = [sessions.(P.behVar)];    
    % idx = {X<switchX, X>switchX};
    if ~isempty(P.behVarSE)
        behVarSE = [sessions.(P.behVarSE)];
        errorshade(X, behVarSE(2,:), behVarSE(1,:), P.color{1}, 0.3); hold on;
        % errorshade(X(idx{1}), behVarSE(2,idx{1}), behVarSE(1,idx{1}), P.color{1}, 0.3); 
        % errorshade(X(idx{2}), behVarSE(2,idx{2}), behVarSE(1,idx{2}), P.color{1}, 0.3); 
    end
    % plot(X(idx{1}), behVar(idx{1}),'LineStyle','-');
    % plot(X(idx{2}), behVar(idx{2}),'LineStyle','-');
    plot(X, behVar,'LineStyle','-');


    xlabel(P.xLabel);
    ylabel(P.yLabel(1));

    %Right (neural) axis
    yyaxis right;
    % plot(X(idx{1}), imgVar(idx{1}),'LineStyle','-');
    % plot(X(idx{2}), imgVar(idx{2}),'LineStyle','-'); 
    plot(X, imgVar,'LineStyle','-');
    set(gca,'XTick',X);
    xlim([0.5,max(X)+0.5]);
    %Shade below the significance interval
    a = population.alpha;
    fill([min(xlim),min(xlim),max(xlim),max(xlim)],...
        [0,a,a,0],'k','FaceAlpha',0.05,'LineStyle','none');
    ylabel(['Proportion of cells with p<' num2str(population.alpha)]);
    %Prevent shading of whole plot if pSignificant==0
     if all(imgVar==0)
        ylim([0,1]);
    end
    box off;

    %Annotate Rule Switch
    plot([switchX, switchX], ylim, 'LineStyle',':','Color',colors.gray);
    txtY = min(ylim)+0.05*range(ylim);
    text(switchX,txtY,strjoin(ruleOrder,'->'),'HorizontalAlignment','center','Color',colors.gray);

    %Title
    title(P.title);
