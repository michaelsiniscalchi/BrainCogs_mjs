function psychStruct = getPsychometricCurve( responseName, trialData, trials, trialSubset, nBins )

if nargin<4
    trialSubset = true(size(trials.(responseName)));
end
if nargin<5
    nBins = NaN;
end

%Exclude forced choice trials


%Get domain (difference R-L cues) or cue/distractor count for each category
diffCues.towers = diff(trialData.nTowers(trialSubset,:),[],2); %nTowers is formatted L,R x nTrials
diffCues.puffs  = diff(trialData.nPuffs(trialSubset,:),[],2);
diffCues.all = diffCues.towers + diffCues.puffs;

cueCounts.towers = sum(trialData.nTowers(trialSubset,:), 2);
cueCounts.puffs = sum(trialData.nPuffs(trialSubset,:), 2);

%Get proportion of R-choice trials at each contrast
logistic = @(x, b, b0, L) L./(1+exp(-b*(x-b0))); % Y = a/(1+exp(-b*(x-c)))

%Restrict analysis to choice trials
omitMask = trials.omit(trialSubset);
responseMask = trials.(responseName)(trialSubset) & ~omitMask; %Logical mask for response variable (rightChoice or correctChoice)


if ismember(responseName, ["rightChoice", "right"])
    for f = string(fieldnames(diffCues))'
        %Initialize
        psychStruct.(f) = struct(...
            'counts', [], 'pResponse', [], 'nTrials', [] ,'pOmit', [], ...
            'bins', [],  'pResponse_binned', [], 'se_binned', [], 'nTrials_binned', [] ,...
            'edges', [], 'curvefit', []);

        %Handle forced choice, etc
        if isempty(diffCues.(f)) || all(diffCues.(f)==0) || isscalar(responseMask)
            continue
        end

        %Probability of right choice (unbinned)
        edges = -max(abs(diffCues.(f))) : max(abs(diffCues.(f)))+1; %Edges are in general E[x-1, x); E[x-1, x] for last edge
        psychStruct.(f).counts = edges(1:end-1); %Domain for distribution

        nTrials = histcounts(diffCues.(f)(~omitMask), edges); %Frequency of each cue count (number of trials), excluding omissions
        psychStruct.(f).pResponse = histcounts(diffCues.(f)(responseMask), edges) ./ nTrials;
        psychStruct.(f).nTrials = nTrials;

        %Probability of omission (unbinned)
        nTrials = histcounts(diffCues.(f), edges); %Frequency of each cue count (number of trials) including omissions
        psychStruct.(f).pOmit = histcounts(diffCues.(f)(omitMask), edges) ./ nTrials;

        %Probability of right choice (binned)
        nBins = min(nBins, max(abs(diffCues.(f)))); %If no nBins is specified, determine number of bins using max of data
        binWidth = ceil(max(abs(diffCues.(f)))/nBins);
        edges = 0 : binWidth : nBins*binWidth+1;
        %Include 1 bin for X==0
        edges = unique([(-(edges-1)), 0, 1, edges(2:end)]); %Edges are in general E[x-1, x); E[x-1, x] for last edge; note unique() sorts by default

        bins = binWidth-1 : binWidth : (nBins*binWidth)-1; %Aligned to most extreme value in each bin
        psychStruct.(f).bins = unique([-bins, 0, bins]); %Sort;  %Include 1 bin for X==0

        [nTrials, ~, bInd] = histcounts(diffCues.(f)(~omitMask), edges); %Frequency of each cue count; exclude omissions
        psychStruct.(f).pResponse_binned = histcounts(diffCues.(f)(responseMask), edges) ./ nTrials;
        psychStruct.(f).se_binned = arrayfun(@(i) std(responseMask(bInd==i))/sqrt(sum(bInd==i)), 1:numel(psychStruct.(f).bins)); %Loop through each bin index and get STD
        psychStruct.(f).nTrials_binned = nTrials;
        psychStruct.(f).edges = edges;

        %Logistic fit
        [~,~,stats] = glmfit(diffCues.(f)(~omitMask), responseMask', 'binomial', 'link', 'logit','LikelihoodPenalty','jeffreys-prior');
        L = max(psychStruct.(f).pResponse);
        psychStruct.(f).curvefit = logistic(psychStruct.(f).counts,stats.beta(2),stats.beta(1),L);

    end
elseif responseName=="correct"
    for f = string(fieldnames(cueCounts))'
        %Initialize
        psychStruct.(f) = struct(...
            'counts', [], 'pResponse', [], 'nTrials', [] ,'pOmit', [], ...
            'bins', [],  'pResponse_binned', [], 'se_binned', [], 'nTrials_binned', [] ,...
            'edges', [], 'curvefit', []);

        %Handle forced choice, etc
        if isempty(cueCounts.(f)) || ~any(cueCounts.(f)) || isscalar(responseMask)
            continue
        end

        %Probability of correct choice (unbinned)
        edges = 0 : max(cueCounts.(f))+1; %Edges are in general E[x-1, x); E[x-1, x] for last edge
        psychStruct.(f).counts = edges(1:end-1); %Domain for distribution

        nTrials = histcounts(cueCounts.(f)(~omitMask), edges); %Frequency of each cue count (number of trials), excluding omissions
        psychStruct.(f).pResponse = histcounts(cueCounts.(f)(responseMask), edges) ./ nTrials;
        psychStruct.(f).nTrials = nTrials;

        %Probability of omission (unbinned)
        nTrials = histcounts(cueCounts.(f), edges); %Frequency of each cue count (number of trials) including omissions
        psychStruct.(f).pOmit = histcounts(cueCounts.(f)(omitMask), edges) ./ nTrials;

        %Probability of correct choice (binned)
        nBins = min(nBins, max(cueCounts.(f))); %If no nBins is specified, determine number of bins using max of data
        binWidth = ceil(max(cueCounts.(f))/nBins);
        edges = [0, 1:binWidth:nBins*binWidth+1];
        
        psychStruct.(f).bins = [0, binWidth:binWidth:nBins*binWidth]; %Aligned to center of each bin
       
        [nTrials, ~, bInd] = histcounts(cueCounts.(f)(~omitMask), edges); %Frequency of each cue count; exclude omissions
        psychStruct.(f).pResponse_binned = histcounts(cueCounts.(f)(responseMask), edges) ./ nTrials;
        psychStruct.(f).se_binned = arrayfun(@(i) std(responseMask(bInd==i))/sqrt(sum(bInd==i)), 1:numel(psychStruct.(f).bins)); %Loop through each bin index and get STD
        psychStruct.(f).nTrials_binned = nTrials;
        psychStruct.(f).edges = edges;

        %Logistic fit
        [~,~,stats] = glmfit(cueCounts.(f)(~omitMask), responseMask', 'binomial', 'link', 'logit','LikelihoodPenalty','jeffreys-prior');
        L = max(psychStruct.(f).pResponse);
        psychStruct.(f).curvefit = logistic(psychStruct.(f).counts,stats.beta(2),stats.beta(1),L);
    end
end

%Trial counts
% psychStruct.towers.nTrials = [sum(trials.leftTowers(trialSubset)), sum(trials.rightTowers(trialSubset))];
% psychStruct.puffs.nTrials = [sum(trials.leftPuffs(trialSubset)), sum(trials.rightPuffs(trialSubset))];
