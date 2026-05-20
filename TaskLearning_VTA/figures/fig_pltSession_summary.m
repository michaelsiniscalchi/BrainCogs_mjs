function fig = fig_pltSession_summary(session, trialData, trials, subjectID, colors)

fig = ...
    figure('Name', strjoin([subjectID, datestr(session.session_date,'yymmdd'), session.taskRule],'-'),...
    'Position',[100 100 1500 800]);
setup_figprops('placeholder');
t = tiledlayout(2,2);

%--- Lick Time Histogram -------------------------------
win = [-2 8];
binWidth = 0.2;
edges = win(1):binWidth:win(2); %100 ms bins

%Populate trial-wise cell array of lick times
nTrials = numel(trialData.eventTimes);
for i = 1:nTrials
    t0 = trialData.eventTimes(i).firstCue;
    X(i).licks = trialData.eventTimes(i).licks - t0;
    idx =  X(i).licks>win(1) & X(i).licks<win(2);
    X(i).licks = X(i).licks(idx);
end

%Histogram of licks for each cue type
trialTypes = ["leftPuffs", "rightPuffs", "leftTowers", "rightTowers"];
C = {colors.purple2, colors.purple, colors.blue2, colors.blue}; %Add to colors struct in future

ax(1) = nexttile;
for i=1:numel(trialTypes)
    x = edges(1:end-1);
    idx = trials.(trialTypes(i));
    nTrials = sum(idx);
    y = histcounts([X(idx).licks], edges)/(nTrials*binWidth);
    h(i) = plot(x, y, 'Color', C{i}, 'DisplayName', trialTypes(i));
    hold on
end
plot([0,0],ylim,'k:'); %Cue time, t0
xlim(win);
title('Histogram of Licks by Cue Type')
xlabel('Time from cue (s)');
ylabel('Lick frequency (Hz)');
axis square

   
    %--- Number of licks as a function of trial number
    ax(2)=nexttile(3);
    for i = 1:numel(trialTypes) 
        data = trialData.nLicksCue(trials.(trialTypes(i)));
        x = find(trials.(trialTypes(i)));
        p(i) = plot(x,data,'LineWidth',2,'Color',C{i}); hold on;
        p(i).DisplayName = trialTypes(i);
    end

    title("Number of Licks by Trial");
    xlabel("Trial number");
    ylabel("Lick count");
    legend(h,'Location','eastoutside')
    clearvars p

    % %Histogram of licks for CS+/CS-
    % 
    % trialTypes = ["csPlus", "csMinus"];
    % C = {colors.green2, colors.pink}; %Add to colors struct in future
    % for i=1:numel(trialTypes)
    %     x = edges(1:end-1);
    %     idx = trials.(trialTypes(i));
    %     nTrials = sum(idx);
    %     y = histcounts([X(idx).licks], edges)/(nTrials*binWidth);
    %     h(i) = plot(x, y, 'Color', C{i}, 'DisplayName', trialTypes(i));
    %     hold on
    % end
    % plot([0,0],ylim,'k:'); %Cue time, t0
    % xlim(win);
    % title('Histogram of Licks by CS type')
    % xlabel('Time from cue (s)');
    % ylabel('Lick frequency (Hz)');
    % axis square

%--- Bar Plot of Lick Counts for each Trial-Type(CS+ vs CS-), Normalized by Post-Reward Licks
ax(3)=nexttile(2);
X = 1:numel(trialTypes);
boxWidth = 0.5;
for i = 1:numel(trialTypes)
    data = trialData.nLicksCue(trials.(trialTypes(i)))/session.meanLicksReward;
    rewLicks = mean(trialData.nLicksReward(trials.rewarded));
    p(i) = plot_basicBox( i, data, boxWidth, 2, C{i}, 0.5 );
    p(i).DisplayName = trialTypes(i);
end

title("Normalized Lick Counts by Cue Type");
xlabel("Cue type");
ylabel("Number of licks (cue/reward)");
legend(p,'Location','eastoutside')
axis square;
clearvars p;

%--- Number of licks as a function of trial number (CS+ vs CS-) and Reward
ax(4)=nexttile;
trialTypes = ["csPlus", "csMinus"];
C = {colors.green2, colors.pink}; %Add to colors struct in future
for i = 1:numel(trialTypes)
    data = trialData.nLicksCue(trials.(trialTypes(i)));
    X = find(trials.(trialTypes(i)));
    p(i) = plot(X,data,'LineWidth',2,'Color', C{i},'DisplayName',trialTypes(i)); hold on;
end
data = trialData.nLicksReward(trials.rewarded);
X = find(trials.rewarded);
p(i+1) = plot(X,data,'LineWidth',2,'Color',colors.green);
p(i+1).DisplayName = 'reward';

title("Number of Licks by Trial");
xlabel("Trial number");
ylabel("Lick count");
legend(p,'Location','eastoutside')

t.Padding = "loose";
t.TileSpacing = "loose";
