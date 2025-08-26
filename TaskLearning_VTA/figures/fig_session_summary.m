function figs = fig_session_summary(subject, glmName, colors)

figs = gobjects(numel(subject.sessions),1);
S = subject.sessions;
for i = 1:numel(subject.sessions)
    if S(i).taskRule=="forcedChoice" || S(i).nTrials<100
        continue
    end

    % || all(arrayfun(@(f) isempty(S(i).(f)), ["glm1","glm2"]))

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
    if ~isempty(S(i).(glmName))
        plotSessionGLM(S(i), glmName, colors);
    end

    %--- Psychometric curves for Towers -- all/congruent/conflict trials
    ax(5)=nexttile;
    S(i).psychometric.data = S(i).psychometric; %Rename field for all (congruent|conflict) to "data"
    S(i).psychometric = rmfield(S(i).psychometric,{'towers','puffs','all'});
    if ~isempty(S(i).psychometric)
        if ~isempty(S(i).(glmName).psychometric)
            S(i).psychometric.model = S(i).(glmName).psychometric;
        end
    lgd = plotPsychometric(S(i).psychometric, "towers", colors, ""); %p = plotPsychometric(psychStruct, cueName, colors, title_str)
    lgd.Visible='off';
    end
    
    %--- Psychometric curves for Air Puffs -- all/congruent/conflict trials
    ax(6) = nexttile;
    if ~isempty(S(i).psychometric)
        lgd = plotPsychometric(S(i).psychometric, "puffs", colors, "");
        lgd.Location="eastoutside";
    end

    t.Padding = "loose";
    t.TileSpacing = "loose";
end

