%Estimate distribution of Inter-cue Intervals
P = diff([trialData.eventTimes(:).puffs]);
P = P(P<0.5);

T = diff([trialData.eventTimes(:).towers]);
T = T(T<0.5);

figure;
subplot(1,2,1)
histogram(T);
title('Towers');
ylabel('Number of Events');
xlabel('Inter-Tower Interval (s)');

subplot(1,2,2)
histogram(P);
title('Air Puffs');
ylabel('Number of Events');
xlabel('Inter-Puff Interval (s)');

%Determine mean time from first to last cue
T = cellfun(@range, cellfun(@double,{trialData.eventTimes.towers},'UniformOutput',false));

P = cellfun(@range, cellfun(@double,{trialData.eventTimes.puffs},'UniformOutput',false));


figure;
subplot(1,2,1)
histogram(T);
title('Towers');
ylabel('Number of Trials');
xlabel('Effective Train Duration (s)');
xlim([0,4]);

subplot(1,2,2)
histogram(P);
title('Air Puffs');
ylabel('Number of Trials');
xlabel('Effective Train Duration (s)');
xlim([0,4]);


