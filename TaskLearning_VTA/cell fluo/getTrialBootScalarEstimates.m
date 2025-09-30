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

%Initialize struct
stats = struct(...
    "timeAvg",NaN,"timeAvg_CI",NaN(2,1),...
    "max",NaN,"max_t",NaN,"max_CI",NaN(2,1),... peak
    "maxAvg",NaN,"maxAvg_CI",NaN(2,1),...
    "min",NaN,"min_t",NaN,"min_CI",NaN(2,1),... trough
    "minAvg",NaN,"minAvg_CI",NaN(2,1),...
    "peak",NaN,"peak_t",NaN,"peak_CI",NaN(2,1),... absolute peak
    "peakAvg",NaN,"peakAvg_CI",NaN(2,1)...
    );

%Mean within window following trigger
idx = t>0 & t<params.avgWin; %sample idx for averaging around max
timeAvgReps = mean(bootRep(:, idx),2); %time average; one value per bootstrap replicate
stats.timeAvg = mean(timeAvgReps);
stats.timeAvg_CI(1,:) = prctile(timeAvgReps, 50+params.CI/2, 1);
stats.timeAvg_CI(2,:) = prctile(timeAvgReps, 50-params.CI/2, 1);

%Smooth bootstrap replicates and take mean trace
signal = movmean(bootRep, params.smoothWin, 2); %Smooth over time with simple moving mean
% meanSignal = mean(signal); %Mean trace

func = struct('max',@max,'min',@min,'peak', @(x) max(abs(x)));
for statName = string(fieldnames(func))'
    stats = getScalarEstimate(stats, signal, t,...
 params.avgWin, char(statName), func.(statName), params.CI);
end

function stats = getScalarEstimate(stats, signal, t, avgWin, statName, func, CI)
%Find min, max, abs peak
meanSignal = mean(signal);
idx = meanSignal==func(meanSignal); %Time of peak, etc in the mean trace @func = @max, @min, etc
if sum(idx)==1 %If distinct peak time
    stats.(statName) = meanSignal(idx); %max dF/F
    stats.([statName,'_t']) = t(idx);
    statReps = signal(:,idx); %dF/F from each bootstrap replicate at time of peak in smoothed mean trace
    stats.([statName,'_CI'])(1,:) = prctile(statReps, 50+CI/2, 1);
    stats.([statName,'_CI'])(2,:) = prctile(statReps, 50-CI/2, 1);

    %Avg surrounding peak
    idx = t>t(idx) - avgWin/2 & t<t(idx) + avgWin/2; %Sample idx for averaging around max
    statReps = mean(signal(:,idx),2); %dF/F from each bootstrap replicate surrounding time of peak in smoothed mean trace
    stats.([statName,'Avg']) = mean(statReps,"all");
    stats.([statName,'Avg_CI'])(1,:) = prctile(statReps, 50+CI/2, 1);
    stats.([statName,'Avg_CI'])(2,:) = prctile(statReps, 50-CI/2, 1);
end