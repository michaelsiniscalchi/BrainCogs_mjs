 medianTowerInterval.m37 = [0.3169 0.3329 0.2994 0.2810 0.2794];
 medianPuffInterval.m37 = [0.3126 0.3424 0.3073 0.2795 0.2758];
 medianTowerInterval.m39 = [0.6370 0.4845 0.5085 0.5611 0.5219];
 medianPuffInterval.m39 = [0.5212 0.4746 0.5107 0.5571 0.5740];

for S = ["m37","m39"]
    disp(S)
 disp(mean(medianTowerInterval.(S)));
disp(std(medianTowerInterval.(S)));
disp(mean(medianPuffInterval.(S)));
disp(std(medianPuffInterval.(S)));
end

%% Run getRemoteVRData
%Mean inter-cue interval
interTowerIntervals = {...
    arrayfun(@(idx) single(diff(eventTimes(idx).leftTowers)), find(trials.forward),'UniformOutput',false),...
    arrayfun(@(idx) single(diff(eventTimes(idx).rightTowers)), find(trials.forward),'UniformOutput',false)};

medianTowerInterval_left = median([interTowerIntervals{1}{:}]);
medianTowerInterval_right = median([interTowerIntervals{2}{:}]);

interPuffIntervals = {...
    arrayfun(@(idx) single(diff(eventTimes(idx).leftPuffs)), find(trials.forward),'UniformOutput',false),...
    arrayfun(@(idx) single(diff(eventTimes(idx).rightPuffs)), find(trials.forward),'UniformOutput',false)};

medianPuffInterval_left = median([interPuffIntervals{1}{:}]);
medianPuffInterval_right = median([interPuffIntervals{2}{:}]);

%%
figure('Name','Intercue Intervals','Position',[50,50,1600,500]);
T=tiledlayout(1,4,"TileSpacing","compact","Padding","compact");
edges = 0:100:5000;

data = {...
    [interTowerIntervals{1}{:}]*1000;...
    [interTowerIntervals{2}{:}]*1000;...
    [interPuffIntervals{1}{:}]*1000;...
    [interPuffIntervals{2}{:}]*1000;...
    };

titles = ["Left Towers","Right Towers","Left Puffs","Right Puffs"];

for i=1:4
nexttile()
histogram(data{i}, edges); hold on;
xlabel('Intercue interval (ms)');
ylabel('Count');
title(titles(i));
axis square
%Overlay median
plot([median(data{i}),median(data{i})], ylim, 'm-')
end