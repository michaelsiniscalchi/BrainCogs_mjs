function figs = fig_session_summary(subject, glmName, colors)

figs = gobjects(numel(subject.sessions),1);
S = subject.sessions;
for i = 1:numel(subject.sessions)
    if S(i).taskRule=="forcedChoice" || S(i).nTrials<100
        continue
    end

    figs(i) = ...
        figure('Name', strjoin([subject.ID, datestr(S(i).session_date,'yymmdd'), S(i).taskRule, string(glmName)],'-'),...
        'Position',[100 100 1500 800]);
    setup_figprops('placeholder');
    t = tiledlayout(2,3);

    %--- Performance, moving window -------------------------------
    ax(1)=nexttile;
    c.all = colors.black;
    c.congruent = colors.gray;
    c.conflict = colors.red;
    c.bias = colors.green2;

    accuracy = S(i).movmeanAccuracy;
    for f = string(fieldnames(accuracy))'
        p = plot(1:numel(accuracy.(f)),abs(accuracy.(f)),"Color",c.(f)); hold on
    end
    title('Performance');
    lgd = legend(string(fieldnames(accuracy)),'Location','eastoutside');
    xlabel("Trial number");
    xlim([0,numel(accuracy.(f))+1]);
    ylabel("Mean accuracy");
    ylim([0,1]);
    axis square

%--- Histogram, Towers: nCues_right - nCues_left
    ax(2)=nexttile;
    X = S(i).cueHistogram.edges;
    Y = S(i).cueHistogram.towers;
    histogram('BinEdges',X,'BinCounts',Y,'EdgeColor','k','FaceColor','k'); hold on 
    Y = S(i).cueHistogram.omit.towers;
    histogram('BinEdges',X,'BinCounts',Y,'EdgeColor','k','FaceColor','w'); hold on
    
    title("Towers");
    xlabel("nRightCues-nLeftCues");
    ylabel("Number of trials");
    axis square;
    
    %--- Histogram, Puffs: nCues_right - nCues_left
    ax(3)=nexttile;
    Y = S(i).cueHistogram.puffs;
    histogram('BinEdges',X,'BinCounts',Y,'EdgeColor','k','FaceColor','k'); hold on
    Y = S(i).cueHistogram.omit.puffs;
    histogram('BinEdges',X,'BinCounts',Y,'EdgeColor','k','FaceColor','w');
    
    title("Air Puffs");
    xlabel("nRightCues-nLeftCues");
    ylabel("Number of trials");
    legend(["all","omissions"],"Location","eastoutside");
    axis square;

        %--- GLM ------------------------------------------------------
    ax(4)=nexttile;

    glm = S(i).(glmName);

    if ~isempty(glm)
        plotSessionGLM(glm, colors);
    end

    %--- Psychometric curves for Towers -- all/congruent/conflict trials
    ax(5)=nexttile;
    %Modify panel params wrt specific regression model
    params.colors = colors;
    if glm.model.ResponseName=="rightChoice"
        psychField = "choice";
        params.title_str = '';
        params.xLabel = 'nRightCues-nLeftCues';
        params.yLabel = 'P(chose right)';
    elseif glm.model.ResponseName=="correct"
        psychField = "outcome";
        params.title_str = '';
        params.xLabel = 'nCues';
        params.yLabel = 'P(correct choice)';
    end

    %Move psychometric data to psychStruct.data to make room for psychStruct.model
    psychometric.data = S(i).psychometric.(psychField); %Rename field for all (congruent|conflict) to "data"
    if ~isempty(S(i).psychometric.(psychField))
        if ~isempty(glm) && ~isempty(glm.psychometric)
            psychometric.model = glm.psychometric;
        end
        lgd = plotPsychometric(psychometric, "towers", glm.model.ResponseName, params); %p = plotPsychometric(psychStruct, cueName, responseName, params)
    end
    
    %--- Psychometric curves for Air Puffs -- all/congruent/conflict trials
    ax(6) = nexttile;
    if ~isempty(psychometric)
        lgd = plotPsychometric(psychometric, "puffs", glm.model.ResponseName, params);
        lgd.Location="eastoutside";
    end

    t.Padding = "loose";
    t.TileSpacing = "loose";
end

