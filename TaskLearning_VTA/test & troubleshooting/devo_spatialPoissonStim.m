meanNumCues = [4 4];
sigmaNumCues = ; %normrnd(mu,sigma)
cueOffset = 10;

cfg.lCue = 200;
cfg.minCueSep = 10;

nCues                     = [];
cuePos                    = [];
cueSide                   = [];
while isempty(cuePos)     % Mazes must have at least one cue
    for iSide = 1:numel(meanNumCues)
        % Draw a Poisson count of tower cues
        nCues(iSide)          = poissrnd(meanNumCues(iSide));
        while nCues(iSide) > cfg.maxNumCues
            nCues(iSide)        = poissrnd(meanNumCues(iSide));
        end

        % Distribute cues uniformly over length available for randomization
        lEffective            = cfg.lCue - cueOffset - nCues(iSide) * cfg.minCueSep;
        stim.cuePos{iSide}    = cueOffset... %Minimum distance for tower visibility
            + sort(rand(1, nCues(iSide))) * lEffective... %Ascending uniform random proportion of segment available for randomization
            + (0:nCues(iSide) - 1) * cfg.minCueSep; %Ascending series of locations with specified minimal separation

        % Shift position by a random proportion of "effective length," to mitigate edge artifacts
        rand_shift = rand*(cfg.lCue - cueOffset);
        stim.cuePos{iSide}=stim.cuePos{iSide}+rand_shift;
        stim.cuePos{iSide}(stim.cuePos{iSide}>cfg.lCue) = ...
            stim.cuePos{iSide}(stim.cuePos{iSide}>cfg.lCue) - (cfg.lCue - cueOffset);
        cueRange              = numel(cuePos) + (1:numel(stim.cuePos{iSide}));
        cuePos(cueRange)      = stim.cuePos{iSide};
        cueSide(cueRange)     = iSide;
    end

    if all(meanNumCues == 0)
        break;
    end
end

% Store canonical (bit pattern) representation of cue presence
[~, index]                = sort(cuePos);
cueSide                   = cueSide(index);
stim.cueCombo             = false(numel(PoissonStimulusTrain_mjs.CHOICES), numel(cueSide));
for iSide = 1:size(stim.cueCombo, 1)
    for iSlot = 1:numel(cueSide)
        stim.cueCombo(cueSide(iSlot), iSlot)  = true;
    end
end

%---------------------------------------------------------------------------------------------------
