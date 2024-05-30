function figs = fig_session_summary(subject, glmName, colors)

figs = gobjects(numel(subject.sessions));
S = subject.sessions;
for i = 1:numel(subject.sessions)
    if S(i).taskRule=="forcedChoice"
        continue
    elseif numel(S(i).movmeanAccuracy)>1
        disp('');
    end

    figs(i) = ...
        figure('Name', strjoin([subject.ID, datestr(S(i).session_date,'yymmdd'), S(i).taskRule],'-'),...
        'Position',[1000 100 1000 500]);
    setup_figprops('placeholder');
    t = tiledlayout(2,2);

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
    %     title(strjoin([subject.ID, string(S(i).session_date)]),'Interpreter','none');
    title('Performance');
    lgd = legend(string(fieldnames(accuracy)),'Location','eastoutside');
    xlabel("Trial number");
    xlim([0,numel(accuracy.(f))+1]);
    ylabel("Mean accuracy");
    ylim([0,1]);
    axis square

    %Psychometric curves for Air Puffs -- all/congruent/conflict trials
    ax(2) = nexttile;
    if ~isempty(S(i).psychometric)
    [~,lgd] = plotPsychometric(S(i).psychometric, "puffs", colors, "Air Puffs");
    lgd.Location="eastoutside";
    end

    %--- GLM ------------------------------------------------------
    ax(3)=nexttile;
    if ~isempty(S(i).(glmName))
        plotSessionGLM(S(i), glmName, colors);
    end

    %Psychometric curves for Towers -- all/congruent/conflict trials
    ax(4)=nexttile;
    if ~isempty(S(i).psychometric)
    [~,lgd] = plotPsychometric(S(i).psychometric, "towers", colors, "Towers"); %p = plotPsychometric(psychStruct, cueName, colors, title_str)
    lgd.Visible='off';
    end
    t.Padding = "loose";
    t.TileSpacing = "loose";
end

