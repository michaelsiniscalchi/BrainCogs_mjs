function trialMasks = getCueValueMasks( leftPuffs, rightPuffs, leftTowers, rightTowers, rewarded, trialMasks )

%Initialize output struct if not provided
if ~exist("trialMasks", "var")
    trialMasks = struct();
end

trials = struct(...
    'leftPuffs',leftPuffs,'rightPuffs',rightPuffs,...
    'leftTowers',leftTowers,'rightTowers',rightTowers,...
    'rewarded',rewarded);

%Get masks for each previously rewarded (and previously unrewarded) cue 
for f = ["leftPuffs","rightPuffs","leftTowers","rightTowers"]
       
    priorRewardedCue = false(size(rewarded)); %Initialize
    priorUnrewardedCue = false(size(rewarded)); %Initialize
    
    cueIdx = find(trials.(f));
    if ~isempty(cueIdx)
        for i = 1:numel(cueIdx)-1
            priorRewardedCue(cueIdx(i)+1:cueIdx(i+1)) = rewarded(cueIdx(i)); %Was previous presentation of this cue type rewarded?
        end

        %Complete prev rew cue mask for last cue presentation
        priorRewardedCue(cueIdx(end)+1:end) = rewarded(cueIdx(end)); %Was previous presentation of this cue type rewarded?

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
        (trials.(['right',f{:}]) & trialMasks.(['right', f{:}, ff{:}])) |...
        (trials.(['left',f{:}]) & trialMasks.(['left', f{:}, ff{:}]));
    end
end
