function stats = getTrialBootScalarEstimates(bootRep, t, params)

%--------------------------------------------------------------------------
% PURPOSE: To take scalar statistical estimates of bootstrapped sample of event-locked timeseries data 
%
% INPUT ARGS
%   bootRep: Matrix of size nReps x nSamplePoints
%   t: Time relative to trigger for each sample
%   params: struct containing parameters for bootstrap analysis
%
% OUTPUTS
%   stats: 
%
%--------------------------------------------------------------------------

%Mean within window following trigger
idx = t>0 & t<params.avgWin; %sample idx for averaging around max
timeAvgReps = mean(bootRep(:, idx),2); %time average; one value per bootstrap replicate
stats.timeAvg = mean(timeAvgReps);
stats.timeAvg_CI(1,:) = prctile(timeAvgReps, 50+params.CI/2, 1);
stats.timeAvg_CI(2,:) = prctile(timeAvgReps, 50-params.CI/2, 1);

%Max value or peak
signal = movmean(bootRep, params.smoothWin, 2); %Smooth over time with simple moving mean
meanSignal = mean(signal); %Mean trace
idx = meanSignal==max(meanSignal); %Time of maximum in the mean trace
stats.peak = meanSignal(idx); %max dF/F
stats.peak_t = t(idx);
peakReps = signal(:,idx); %dF/F from each bootstrap replicate at time of peak in smoothed mean trace
stats.peak_CI(1,:) = prctile(peakReps, 50+params.CI/2, 1);
stats.peak_CI(2,:) = prctile(peakReps, 50-params.CI/2, 1);

%Avg surrounding max
idx = t>stats.peak_t - params.avgWin/2 &...
    t<stats.peak_t + params.avgWin/2; %Sample idx for averaging around max
peakReps = mean(signal(:,idx),2); %dF/F from each bootstrap replicate surrounding time of peak in smoothed mean trace
stats.peakAvg = mean(peakReps,"all");
stats.peakAvg_CI(1,:) = prctile(peakReps, 50+params.CI/2, 1);
stats.peakAvg_CI(2,:) = prctile(peakReps, 50-params.CI/2, 1);

%Min value or trough
idx = meanSignal==min(meanSignal); %Time of min/trough in the mean trace
stats.min = meanSignal(idx); %max dF/F
stats.min_t = t(idx);
minReps = signal(:,idx); %dF/F from each bootstrap replicate at time of min/trough in smoothed mean trace
stats.min_CI(1,:) = prctile(minReps, 50+params.CI/2, 1);
stats.min_CI(2,:) = prctile(minReps, 50-params.CI/2, 1);

%Avg surrounding min
idx = t>stats.min_t - params.avgWin/2 &...
    t<stats.min_t + params.avgWin/2; %Sample idx for averaging around min/trough
minReps = mean(signal(:,idx),2); %dF/F from each bootstrap replicate surrounding time of min/trough in smoothed mean trace
stats.minAvg = mean(minReps,"all");
stats.minAvg_CI(1,:) = prctile(minReps, 50+params.CI/2, 1);
stats.minAvg_CI(2,:) = prctile(minReps, 50-params.CI/2, 1);