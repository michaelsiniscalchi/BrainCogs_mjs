function psychStruct = getPsychometricCurve( trialData, trials, trialSubset )

if nargin<3
    trialSubset = ~trials.omit;
else
    trialSubset = trialSubset & ~trials.omit;
end

%Restrict analysis to trial subset
choiceMask = trials.right(trialSubset); %Logical mask for right trials

%Get domain (difference R-L cues) for each category
diff.towers = cellfun(@(C) numel(C{2})-numel(C{1}), trialData.towerPositions(trialSubset));
diff.puffs = cellfun(@(C) numel(C{2})-numel(C{1}), trialData.puffPositions(trialSubset));
diff.all = diff.towers + diff.puffs;

%Get proportion of R-choice trials at each contrast
logistic = @(x, b, b0, L) L./(1+exp(-b*(x-b0))); % Y = a/(1+exp(-b*(x-c)))

for f = string(fieldnames(diff))'
    edges = -max(abs(diff.(f))):max(abs(diff.(f)))+1;
    psychStruct.(f).diffCues = diff.(f);
    psychStruct.(f).pRight =...
        histcounts(diff.(f)(choiceMask), edges) ./ histcounts(diff.(f), edges);
    psychStruct.(f).bins = edges(1:end-1); %Remove right bin-edge
    
    %Logistic regression
    [~,~,stats] = glmfit(diff.(f), choiceMask', 'binomial', 'link', 'logit');
    L = max(psychStruct.(f).pRight);
    psychStruct.(f).curvefit = logistic(psychStruct.(f).bins,stats.beta(2),stats.beta(1),L);

end

%Trial counts
psychStruct.towers.nTrials = [sum(trials.leftTowers(trialSubset)), sum(trials.rightTowers(trialSubset))];
psychStruct.puffs.nTrials = [sum(trials.leftPuffs(trialSubset)), sum(trials.rightPuffs(trialSubset))];
