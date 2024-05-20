function psychStruct = getPsychometricCurve( trialData, trials, trialSubset )

if nargin<3
    trialSubset = ~trials.omit;
else
    trialSubset = trialSubset & ~trials.omit;
end

%Restrict analysis to trial subset
trialMask = trials.right(trialSubset); %Logical mask for right trials

%Get domain (difference R-L cues) for each category
diff.towers = cellfun(@(C) numel(C{2})-numel(C{1}), trialData.towerPositions(trialSubset));
diff.puffs = cellfun(@(C) numel(C{2})-numel(C{1}), trialData.puffPositions(trialSubset));
diff.all = diff.towers + diff.puffs;

%Get proportion of R-choice trials at each contrast
for f = string(fieldnames(diff))'
    edges = -max(abs(diff.(f))):max(abs(diff.(f)))+1;
    psychStruct.(f).diffCues = diff.(f);
    psychStruct.(f).pRight =...
        histcounts(diff.(f)(trialMask), edges) ./ histcounts(diff.(f), edges);
    psychStruct.(f).bins = edges(1:end-1); %Remove right bin-edge
    mdl = fit(psychStruct.(f).bins, psychStruct.(f).pRight, fittype('logistic'));
end

%Trial counts
psychStruct.towers.nTrials = [sum(trials.leftTowers(trialSubset)), sum(trials.rightTowers(trialSubset))];
psychStruct.puffs.nTrials = [sum(trials.leftPuffs(trialSubset)), sum(trials.rightPuffs(trialSubset))];
