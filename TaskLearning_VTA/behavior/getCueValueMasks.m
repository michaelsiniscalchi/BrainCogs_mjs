function trialMasks = getCueValueMasks( trialMasks )

%Get masks for each previously rewarded (and previously unrewarded) cue 
for f = ["leftPuffs","rightPuffs","leftTowers","rightTowers"]
       
    priorRewardedCue = false(size(trialMasks.rewarded)); %Initialize
    priorUnrewardedCue = false(size(trialMasks.rewarded)); %Initialize
    
    cueIdx = find(trialMasks.(f));
    if ~isempty(cueIdx)
        for i = 1:numel(cueIdx)-1
            priorRewardedCue(cueIdx(i)+1:cueIdx(i+1)) = trialMasks.rewarded(cueIdx(i)); %Was previous presentation of this cue type rewarded?
        end

        %Complete prev rew cue mask for last cue presentation
        priorRewardedCue(cueIdx(end)+1:end) = trialMasks.rewarded(cueIdx(end)); %Was previous presentation of this cue type rewarded?

        %Prev unrew cue mask is inverse, except for prior to first cue presentation
        priorUnrewardedCue = ~priorRewardedCue;
        priorUnrewardedCue(1:cueIdx(1)) = false;
    end

    %Generate fieldname
    trialMasks.([f{:},'Valued']) = priorRewardedCue;
    trialMasks.([f{:},'Devalued']) = priorUnrewardedCue;
end

%Derived masks: cueSideValued vs. cueSideDevalued
for f = ["Towers", "Puffs"]
    for ff = ["Valued", "Devalued"]
    trialMasks.([lower(f{:}(1:end-1)),'Side', ff{:}]) =...
        (trialMasks.(['right',f{:}]) & trialMasks.(['right', f{:}, ff{:}])) |...
        (trialMasks.(['left',f{:}]) & trialMasks.(['left', f{:}, ff{:}]));
    end
end
