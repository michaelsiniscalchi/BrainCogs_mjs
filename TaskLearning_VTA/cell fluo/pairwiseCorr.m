function [ output ] = pairwiseCorr ( signal, t, params)
% % decode_linearclassifier %
%PURPOSE:   Decoding with linear classifier
%AUTHORS:   AC Kwan 170522
%
%INPUT ARGUMENTS
%   signal:         time-series signal (time x cells)
%   t:              time points corresponding to the signal
%   trials:         the structure generated by flex_getTrialMasks().
%
%   params.trigEvent:     event, dummy-coded (e.g., for choice, left=-1, right=1)
%   params.trigTime:      the event times
%   params.window:        the time window around which to align signal
%   params.numRepeat:     number of times to scramble

%OUTPUT ARGUMENTS
%   output:         structure containing decoding analysis results
%
% To plot the output, use plot_pcorr().

%% interpolate signal, finer time bins here allows finer alignment to events

nCell = size(signal,2);

window=params.window;

% interpolate the signal to a finer time scale
interdt=0.05;
intert=[t(1):interdt:t(end)]';
intersig=interp1(t,signal,intert);

% align signal to the event
% use window slightly wider than the regression, so regression analysis
% won't run into the boundaries of this variable
% sigbyTrial has dimensions (time x trials x cells)
[sigbyTrial, tbyTrial]=align_signal(intert,intersig,params.trigTime,[window(1)-1 window(end)+1]);

%% which trials to analyze

eventbyTrial = params.trigEvent;

% restrict to the specified trial subset
badTrials = isnan(eventbyTrial);
eventbyTrial = eventbyTrial(~badTrials);
sigbyTrial = sigbyTrial(:,~badTrials,:);

% if sigbyTrial has NaN, it should be removed, for example no signal prior to t=0 in first trial)
badTrials = (sum(sum(isnan(sigbyTrial),3),1)>0)';
eventbyTrial = eventbyTrial(~badTrials);
sigbyTrial = sigbyTrial(:,~badTrials,:);

%% calculate pairwise corrleation for real ensemble

% concatenate the trials into one long time trace
sigbyCell=reshape(sigbyTrial,size(sigbyTrial,1)*size(sigbyTrial,2),size(sigbyTrial,3));

pcorr = corrcoef(sigbyCell);

for kk=1:params.numRepeat
    %% calculate pairwise correlation for pseudo-ensemble
    
    %activity is scrambled for trials with same outcome (as if neurons were not recorded simultaneously)
    sigbyTrial_rand = nan(size(sigbyTrial));
    eventType = unique(eventbyTrial);
    for k = 1:nCell  %for each cell..
        for j = 1:numel(eventType) %for each outcome type..
            idx = find(eventbyTrial == eventType(j));
            randIdx = idx(randperm(numel(idx)));
            sigbyTrial_rand(:,randIdx,k) = sigbyTrial(:,idx,k); %shuffle the trial-by-trial activity of this cell
        end
    end
    
    % concatenate the trials into one long time trace
    sigbyCell_rand=reshape(sigbyTrial_rand,size(sigbyTrial_rand,1)*size(sigbyTrial_rand,2),size(sigbyTrial_rand,3));
    
    pcorr_randsig = corrcoef(sigbyCell_rand);
    
    %% calculate pairwise correlation for scramble
    
    %activity is scrambled, no consideration for outcome
    sigbyTrial_scram = nan(size(sigbyTrial));
    for k = 1:nCell  %for each cell..
        idx = [1:size(sigbyTrial,2)];
        randIdx = idx(randperm(numel(idx)));
        sigbyTrial_scram(:,randIdx,k) = sigbyTrial(:,idx,k); %shuffle the trial-by-trial activity of this cell
    end
    
    % concatenate the trials into one long time trace
    sigbyCell_scram=reshape(sigbyTrial_scram,size(sigbyTrial_scram,1)*size(sigbyTrial_scram,2),size(sigbyTrial_scram,3));
    
    pcorr_scram = corrcoef(sigbyCell_scram);
    
    %%
    output.pcorr(:,:,kk) = pcorr;
    output.pcorr_randsig(:,:,kk) = pcorr_randsig;
    output.pcorr_scram(:,:,kk) = pcorr_scram;
    
end

end
