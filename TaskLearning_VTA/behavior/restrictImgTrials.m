function behavior = restrictImgTrials( behavior, mainMazeIdx, excludeBlock )

if any(behavior.trials.level~=mainMazeIdx)
    behavior.trials.exclude(behavior.trials.level~=mainMazeIdx) = true; %'exclude' field used in getMasks()
    level = unique(behavior.trials.level(behavior.trials.level~=mainMazeIdx));
    warning(['Excluding ' num2str(sum(behavior.trials.level~=mainMazeIdx)) ' events from level ' num2str(level) '. Check!'])
end

%Following can be used to exclude blocks specified in expData;
% currently, sessions/blocks are specified in getVRData > excludeBadBlocks()
if excludeBlock
    exclMask = ismember(behavior.trials.blockIdx,excludeBlock);
    behavior.trials.exclude(exclMask) = true; %'exclude' field used in getMasks()
    warning(['Excluding ' num2str(sum(exclMask)) ' trials from block(s) ' num2str(excludeBlock) '. Check!'])
end

