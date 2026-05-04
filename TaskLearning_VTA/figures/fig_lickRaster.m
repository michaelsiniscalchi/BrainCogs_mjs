function   figs = fig_lickRaster( session, trialData, trialMasks, subjectID, colors )

setup_figprops("timeseries");

figs = figure(...
    'Name', strjoin(["Lick Raster", subjectID, datestr(session.session_date,'yymmdd'),session.taskRule],'-'),...
    'Position',[50,50,500,900]);
T = tiledlayout(10,1,'TileSpacing','loose','Padding','compact');

%DEVO
win = [-2 8];
binWidth = 0.2;
edges = win(1):binWidth:win(2); %100 ms bins

%Additional trialmasks
puffMask = trialMasks.leftPuffs | trialMasks.rightPuffs;
towerMask = trialMasks.leftTowers | trialMasks.rightTowers;

%Populate trial-wise cell array of lick times
nTrials = numel(trialData.eventTimes);

for i = 1:nTrials
    if trialMasks.leftPuffs(i) || trialMasks.rightPuffs(i)
        t0 = trialData.eventTimes(i).firstPuff;
        % X.lickTimes{i} = trialData.eventTimes(i).licks - t0;
        % X.cueTimes{i} = [trialData.eventTimes(i).leftPuffs, trialData.eventTimes(i).rightPuffs] - t0; 
    elseif trialMasks.leftTowers(i) || trialMasks.rightTowers(i)
        t0 = trialData.eventTimes(i).firstTower;
        % X.lickTimes{i} = trialData.eventTimes(i).licks - t0;
        % X.cueTimes{i} = [trialData.eventTimes(i).leftTowers, trialData.eventTimes(i).rightTowers] - t0; 
    end
    fieldNames = ["leftPuffs", "rightPuffs", "leftTowers", "rightTowers",...
        "licks","reward","noReward"];
    for f = fieldNames
        X(i).(f) = trialData.eventTimes(i).(f) - t0; 
        idx =  X(i).(f)>win(1) & X(i).(f)<win(2);
        X(i).(f) = X(i).(f)(idx);
    end
end

%Lick/cue/outcome raster
nexttile(1,[6,1])
C = {colors.purple2, colors.purple, colors.blue2, colors.blue,...
        colors.black, colors.green, colors.pink}; %Add to colors struct in future
for i = 1:nTrials
    fields = ["leftPuffs", "rightPuffs", "leftTowers", "rightTowers",...
        "reward","noReward","licks"];
    C = {colors.purple2, colors.purple, colors.blue2, colors.blue,...
        colors.green, colors.pink, colors.black}; %Add to colors struct in future
    M = ["<", ">", "<", ">", "|", "|", "|"]; %Markers
    markerSize  = [5, 5, 5, 5, 5, 5, 5];
    lineWidth   = [0.5, 0.5, 0.5, 0.5, 2, 2, 0.5]; %Linewidth~markersize
    y = i-0.5;
    for j = 1:numel(fields)
        if ~isempty(X(i).(fields(j)))
            h(j) = plot(X(i).(fields(j)), repmat(y,1,numel(X(i).(fields(j)))), 'Marker', M(j), 'MarkerSize', markerSize(j),...
                'Color', C{j}, 'LineWidth', lineWidth(j),'LineStyle','none',...
                'DisplayName',fields(j)); 
            hold on;
        end
    end

end
%Show only the first 50 trials
ylim([0,50]);
xlim(win);
axis ij
title("Event Raster");
xlabel('Time from first cue (s)');
ylabel('Trial number');
lgd = legend(h,'Location','eastoutside');
clearvars h

%Histogram of licks for CS+/CS-
trialTypes = ["leftPuffs", "rightPuffs", "leftTowers", "rightTowers"];
C = {colors.purple2, colors.purple, colors.blue2, colors.blue}; %Add to colors struct in future

nexttile(T,7,[4,1]);
for i=1:numel(trialTypes)
    x = edges(1:end-1);
    idx = trialMasks.(trialTypes(i));
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
legend(h,'Location','eastoutside')

% binnedLicks = zeros(nTrials,numel(edges)-1);
% binIdx = discretize(lickTimes{i}, edges);
% binIdx = binIdx(~isnan(binIdx));
% binnedLicks(i, binIdx) = true; %Binary for now: lick or no lick in this bin
% I = imagesc(binnedLicks); hold on
% colormap('gray')