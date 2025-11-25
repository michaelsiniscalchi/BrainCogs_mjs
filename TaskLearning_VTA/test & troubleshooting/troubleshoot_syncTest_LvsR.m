
clearvars;

subjectID = "m477";

[ dirs, expData, calculate, summarize, figures, mat_file, params ] =...
    getAnalysisParams_T2V( subjectID );

idx = ismember({expData.sub_dir},{'250905-m477-maze8'});
load(mat_file.img_beh(idx))
% load(mat_file.img_beh(idx),'sessions','trialData','trials','trialDFF');
saveDir = 'X:\michael\tactile2visual-vta\troubleshooting'; %TEMP

%% --------------------------------------------------------------------------

%Figure: heatmap of trial dF/F, aligned to each trigger
events = ["start", "towers", "puffs", "firstTower", "outcome", "cueRegion"]; 
x = trialDFF.t;
for i = 1:numel(events)
    figs(i) = figure('Name', ['Aligned fluorescence - ',events{i}],...
        'Position',[1000,100,400,800]);
    x = trialDFF.t; 
    data = trialDFF.(events(i)){:};
    x_label = 'Time from event onset (s)';
    if ismember(events(i),["towers","puffs"])
        data = cell2mat(trialDFF.(events(i)){:}); %'towers' requires concatenation
    elseif events(i)=="cueRegion"
        x = trialDFF.position;
        x_label = 'Distance from start of maze (cm)';
    end
    %Image fluorescence, nEvents x time (position)

    img = imagesc([min(x),max(x)],[min(1),size(data,1)], data);
    title(events{i});
    ylabel('Event Index');
    xlabel(x_label);
   
    c = colorbar();
    c.Label.String = 'dF/F';
end
%save_multiplePlots(figs, saveDir); %Save figure

%%

disp('------------------');
disp('------------------');

%Response Time
for f = ["leftTowers","rightTowers","leftPuffs","rightPuffs"]
    idx = trials.(f);
    responseTime.(f) = mean(trialData.response_time(idx),1,"omitnan");
    disp(strjoin(['Response time,', f, 'trials:', num2str(responseTime.(f))],' '));
end
disp('------------------');
%Time to Complete Cue Region
for f = ["leftTowers","rightTowers","leftPuffs","rightPuffs"]
    idx = trials.(f);
    cueRegionTime.(f) = mean(trialData.duration_cueRegion(idx),1,"omitnan");
    disp(strjoin(['Time to complete cue region,', f, 'trials:', num2str(cueRegionTime.(f))],' '));
end
disp('------------------');
%Response Delay
for f = ["leftTowers","rightTowers","leftPuffs","rightPuffs"]
    idx = trials.(f);
    responseDelay.(f) = mean(trialData.response_delay(idx),1,"omitnan");
    disp(strjoin(['Response delay,', f, 'trials:', num2str(responseDelay.(f))],' '));
end
disp('------------------');
disp(['Median delay bias: ', num2str(sessions.median_delay_bias)]);

%% Tests after running analysis code to align routine
figure('Position',[300,300,1200,600]);
tiledlayout(1,2,'TileSpacing','tight','Padding','compact')
nexttile;
plot(diff(t));
title('Time difference between neighboring frames');
xlabel('Frame index')
ylabel('Inter-frame interval (s)');

nexttile;
histogram(diff(t));
title('Histogram of frame-time intervals');
xlabel('Inter-frame interval (s)')
ylabel('Number of obs.');

%% Trial Data
allTimes = cell2mat(trialData.time);
firstIterTime = cellfun(@(C) C(2), trialData.time);
for i=1:numel(trialData.response_time)
    choiceTime = trialData.eventTimes(i).choice - trialData.eventTimes(i).start;
    trialIter = sum(trialData.time{i} < choiceTime);
    trialDTCell{i,:} = diff(trialData.time{i}(1:trialIter));
end
trialDT = cell2mat(trialDTCell);
meanDT = mean(trialDT);
virmenFreq = 1/meanDT;

figure; plot(trialDT);
figure; histogram(firstIterTime);

for i=1:numel(trialData.time)
    iterTimes{i,:} = diff(trialData.time{i}(1:11))';
end
M = cell2mat(iterTimes);

