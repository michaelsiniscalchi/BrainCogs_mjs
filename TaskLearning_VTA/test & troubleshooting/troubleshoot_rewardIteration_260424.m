% %clearvars
% data = load('C:\Users\mjs20\Downloads\Matlab036.dat');
% figure; plot(data(:,1),data(:,2))

%
session = subjects.sessions;
log = subjects.logs;
trials = subjects.trials;
idx = ~subjects.trials.omit;
time.outcome = ([subjects.trialData.eventTimes.outcome]-[subjects.trialData.eventTimes.logStart])';
t = subjects.trialData.time;
iDuration = cellfun(@(t) diff(t),t,'UniformOutput',false);
nTrials = numel(time.outcome);

win = [-100, 100]; %nIterations
relIter = win(1):win(2);
alignedDuration = NaN(nTrials,numel(relIter));

for i=1:9
    iOutcome = double(log.block(1).trial(i).iOutcome)+1; %Plus one to correct for timestamp assignment
    alignedDuration(i,:) = iDuration{i}(iOutcome+relIter);
end

figure('Name', 'Aligned Iterations');
T = tiledlayout(1,2,"TileSpacing","compact","Padding","loose");

titles = ["Virmen Frame Duration (Rewarded Trials)","Virmen Frame Duration (Unrewarded Trials)"];
trials.unrewarded = ~trials.rewarded;
trialMasks = ["rewarded","unrewarded"];

for i=1:2
nexttile();
data = alignedDuration(trials.(trialMasks(i)),:)*1000;
h(1) = plot(relIter, mean(data),'DisplayName','Mean'); hold on;
h(2) = plot(relIter, min(data),'DisplayName','Min');
h(3) = plot(relIter, max(data),'DisplayName','Max');
title(titles(i));
xlabel('Iterations relative to outcome');
ylabel('Duration (ms)');
lgd = legend(h);
end

