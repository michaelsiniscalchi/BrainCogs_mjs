function [ hiTowers, loTowers, hiPuffs, loPuffs ] = get_cueQuantiles(trialData, includeMask, nQuantiles)

%Initialize outputs as false
[ hiTowers, loTowers, hiPuffs, loPuffs ] = ...
    deal(false(1, length(trialData.nTowers))); %All row vectors for trial mask struct

%Calculate quantiles for tower and puff counts
nTowers = sum(trialData.nTowers, 2)'; %Collapse across left and right to determine quantiles
nPuffs = sum(trialData.nPuffs, 2)'; %Transpose to row vector for trial masks
qTowers = quantile(nTowers(includeMask), nQuantiles); %Include only eg forward, 2-choice trials in calculation
qPuffs = quantile(nPuffs(includeMask), nQuantiles);

%Create trial masks for top and bottom quantiles
hiTowers = includeMask & nTowers>=qTowers(end); 
loTowers = includeMask & nTowers<qTowers(1);
hiPuffs  = includeMask & nPuffs>=qPuffs(end);
loPuffs  = includeMask & nPuffs<qPuffs(1);