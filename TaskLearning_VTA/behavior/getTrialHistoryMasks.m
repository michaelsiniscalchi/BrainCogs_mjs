function trialMasks = getTrialHistoryMasks( trialMasks )

%Get masks for each previously rewarded (and previously unrewarded) cue 
for f = string(fieldnames(trialMasks))'
    %Generate fieldname
    trialMasks.(['prior', upper(f{:}(1)), f{:}(2:end)]) = ...
        [false, trialMasks.(f)(1:end-1)];
end

%Previous rewarded trialType and opposite-side trialType
if isfield(trialMasks,'priorLeftPuffs')
   for f = ["Towers", "Puffs"]
    trialMasks.(['repeat',f{:}(1:end-1),'Side']) = ...
        (trialMasks.(['left',f{:}]) & trialMasks.(['priorLeft',f{:}])) |... 
        (trialMasks.(['right',f{:}]) & trialMasks.(['priorRight',f{:}]));
    trialMasks.(['switch',f{:}(1:end-1),'Side']) = ...
        (trialMasks.(['left',f{:}]) & trialMasks.(['priorRight',f{:}])) |... 
        (trialMasks.(['right',f{:}]) & trialMasks.(['priorLeft',f{:}]));
   end
end