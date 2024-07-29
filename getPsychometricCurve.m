function psychStruct = getPsychometricCurve( trialData, trials, trialSubset, nBins )

if nargin<3
    trialSubset = true(size(trials.right));
end
if nargin<4
    nBins = NaN;
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
        'counts', [], 'pRight', [], 'nTrials', [] ,'pOmit', [], ...
        'bins', [],  'pRight_binned', [], 'se_binned', [], 'nTrials_binned', [] ,...
        'edges', [], 'curvefit', []);
    
    %Handle forced choice, etc
    if isempty(diffCues.(f)) || sum(diffCues.(f))==0
        continue
    end

    %Probability of right choice (unbinned)
    edges = -max(abs(diffCues.(f))) : max(abs(diffCues.(f)))+1; %Edges are in general E[x-1, x); E[x-1, x] for last edge
    psychStruct.(f).counts = edges(1:end-1); %Domain for distribution

    nTrials = histcounts(diffCues.(f)(~omitMask), edges); %Frequency of each cue count (number of trials), excluding omissions
    psychStruct.(f).pRight = histcounts(diffCues.(f)(choiceMask), edges) ./ nTrials;
    psychStruct.(f).nTrials = nTrials;

    %Probability of omission (unbinned)
    nTrials = histcounts(diffCues.(f), edges); %Frequency of each cue count (number of trials) including omissions
    psychStruct.(f).pOmit = histcounts(diffCues.(f)(omitMask), edges) ./ nTrials;

    %Probability of right choice (binned)
    nBins = min(nBins, max(abs(diffCues.(f)))); %If no nBins is specified, determine number of bins using max of data
    binWidth = ceil(max(abs(diffCues.(f)))/nBins);
    edges = 1 : binWidth : nBins*binWidth+1;
    edges = [sort(-(edges-1)), edges(2:end)]; %Edges are in general E[x-1, x); E[x-1, x] for last edge
    
    bins = binWidth : binWidth : nBins*binWidth; %Aligned to most extreme value in each bin
    psychStruct.(f).bins = sort([-bins, bins]); %Sort

    [nTrials, ~, bInd] = histcounts(diffCues.(f)(~omitMask), edges); %Frequency of each cue count; exclude omissions
    psychStruct.(f).pRight_binned = histcounts(diffCues.(f)(choiceMask), edges) ./ nTrials;
    psychStruct.(f).se_binned = arrayfun(@(i) std(choiceMask(bInd==i))/sqrt(sum(bInd==i)), 1:numel(psychStruct.(f).bins)); %Loop through each bin index and get STD
    psychStruct.(f).nTrials_binned = nTrials;
    psychStruct.(f).edges = edges;

    %Store source data
%     psychStruct.(f).diffCues = diffCues.(f);

    %Logistic fit
    [~,~,stats] = glmfit(diffCues.(f)(~omitMask), choiceMask', 'binomial', 'link', 'logit');
    L = max(psychStruct.(f).pRight);
    psychStruct.(f).curvefit = logistic(psychStruct.(f).counts,stats.beta(2),stats.beta(1),L);

end

%Trial counts
% psychStruct.towers.nTrials = [sum(trials.leftTowers(trialSubset)), sum(trials.rightTowers(trialSubset))];
% psychStruct.puffs.nTrials = [sum(trials.leftPuffs(trialSubset)), sum(trials.rightPuffs(trialSubset))];
