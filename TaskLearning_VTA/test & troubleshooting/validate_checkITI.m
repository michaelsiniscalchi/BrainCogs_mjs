startTimes = [trialData.eventTimes(:).start];
outcomeTimes = [trialData.eventTimes(:).outcome];
ITI = startTimes(2:end) - outcomeTimes(1:end-1);
figure; histogram(ITI,[0:0.5:10])
