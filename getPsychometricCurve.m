function psychStruct = getPsychometricCurve( trialData, trials, trialSubset )

if nargin<3
    trialSubset = true(size(trials.right));
end

%Get domain (difference R-L cues) for each category
diffCues.towers = diff(trialData.nTowers(trialSubset,:),[],2); %nTowers is formatted L,R x nTrials
diffCues.puffs = diff(trialData.nPuffs(trialSubset,:),[],2);
diffCues.all = diffCues.towers + diffCues.puffs;

%Get proportion of R-choice trials at each contrast
logistic = @(x, b, b0, L) L./(1+exp(-b*(x-b0))); % Y = a/(1+exp(-b*(x-c)))

%Restrict analysis to choice trials
choiceMask = trials.right(trialSubset & ~trials.omit); %Logical mask for right trials
omitMask = trials.omit(trialSubset);

for f = string(fieldnames(diffCues))'
    %Initialize
    psychStruct.(f) = struct(...
        'pRight', [], 'pOmit', [], 'diffCues', [], 'bins', [], 'nTrials', []);
    
    %Probability of omission
    edges = -max(abs(diffCues.(f))):max(abs(diffCues.(f)))+1;
    psychStruct.(f).pOmit =...
        histcounts(diffCues.(f)(omitMask), edges) ./ histcounts(diffCues.(f), edges);
    %Probability of right choice
    diffCues.(f) = diffCues.(f)(~omitMask); %Exclude omissions
    psychStruct.(f).pRight =...
        histcounts(diffCues.(f)(choiceMask), edges) ./ histcounts(diffCues.(f), edges);
    psychStruct.(f).bins = edges(1:end-1); %Remove right bin-edge
    
    %Store source data
    psychStruct.(f).diffCues = diffCues.(f);

    %Logistic regression
    [~,~,stats] = glmfit(diffCues.(f), choiceMask', 'binomial', 'link', 'logit');
    L = max(psychStruct.(f).pRight);
    psychStruct.(f).curvefit = logistic(psychStruct.(f).bins,stats.beta(2),stats.beta(1),L);

end

%Trial counts
psychStruct.towers.nTrials = [sum(trials.leftTowers(trialSubset)), sum(trials.rightTowers(trialSubset))];
psychStruct.puffs.nTrials = [sum(trials.leftPuffs(trialSubset)), sum(trials.rightPuffs(trialSubset))];
