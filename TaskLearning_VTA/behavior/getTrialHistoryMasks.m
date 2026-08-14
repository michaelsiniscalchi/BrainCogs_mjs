function priorTrialMasks = getTrialHistoryMasks( trialMasks )

%Get masks for each previously rewarded (and previously unrewarded) cue 
for f = string(fieldnames(trialMasks))'
    %Generate fieldname
    priorTrialMasks.(['prior', upper(f{:}(1)), f{:}(2:end)]) = ...
        [false, trialMasks.(f)(1:end-1)];
end