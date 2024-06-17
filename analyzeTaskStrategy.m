function subjects = analyzeTaskStrategy(subjects)

for i = 1:numel(subjects)
    for j = 1:numel(subjects(i).sessions)

        %Skip forced choice (L-Maze) sessions
        if subjects(i).sessions(j).taskRule=="forcedChoice"
            continue
        end

        %Trial masks for predictors and response variable
        trials = subjects(i).trials(j);
        trialData = subjects(i).trialData(j);
        exclIdx = trials.omit | ~trials.forward;
        priorExclIdx = [true, exclIdx(1:end-1)];

        %Cue Side
        rightTowers = trials.rightTowers(~exclIdx)'; %Exclude omissions and ~forward trials
        rightPuffs = trials.rightPuffs(~exclIdx)'; %Exclude omissions for all
        
        %Number of Cues
        nTowersLeft = trialData.nTowers(~exclIdx,1);
        nTowersRight = trialData.nTowers(~exclIdx,2);
        nPuffsLeft = trialData.nPuffs(~exclIdx,1);
        nPuffsRight = trialData.nPuffs(~exclIdx,2);

        %Choice
        rightChoice = trials.right(~exclIdx)';
        rightPriorChoice = trials.priorRight';
        rightPriorChoice(priorExclIdx) = NaN;
        rightPriorChoice = rightPriorChoice(~exclIdx);
        %Outcome
        reward = trials.correct(~exclIdx)'; %Trial outcome

        %Code predictors as {-1,1}
        effectCode = @(X) 2*(X-0.5);

        %% GLM 1: Logistic regression of Choices based on each Sensory Modality

        % Y = Bias + towerSide(n)*X + puffSide(n)*X + Choice(n-1)*X + error
        X = struct(...
            'bias',ones(size(rightTowers)),...
            'towers', effectCode(rightTowers),... %Cueside(n)
            'puffs', effectCode(rightPuffs),...
            'priorChoice', effectCode(rightPriorChoice)...
            );
        response = rightChoice;
        subjects(i).sessions(j).glm1 = logisticStats(X, response, trials, exclIdx);
        subjects(i).sessions(j).glm1_bias = subjects(i).sessions(j).glm1.bias.beta;

        %% GLM 2: Logistic regression of Choices based on nCues_L, nCues_R
        % Y = B0 + nTowers_L*X + nTowers_R*X + nPuffs_L*X + nPuffs_R*X + error
        X = struct(...
            'bias',ones(size(rightTowers)),...
            'nTowersLeft', nTowersLeft,... 
            'nTowersRight', nTowersRight,... 
            'nPuffsLeft', nPuffsLeft,... 
            'nPuffsRight', nPuffsRight,... 
            'priorChoice', effectCode(rightPriorChoice)...
            );
        response = rightChoice;
        subjects(i).sessions(j).glm2 = logisticStats(X, response, trials, exclIdx);
        subjects(i).sessions(j).glm2_bias = subjects(i).sessions(j).glm2.bias.beta;

    end
end
%---------------------------------------------------------------------------------------------------

function trialHistory = history(trialMask,nBack)

trialHistory = nan(length(trialMask),numel(nBack));
for i = 1:numel(nBack)
    trialHistory(nBack(i)+1:end,i) = trialMask(1:end-nBack(i));
end

%---------------------------------------------------------------------------------------------------

function regStruct = logisticStats( X, response, trials, exclIdx )

%% Regress
[predictors, pNames, idx] = formatPredictors(X, trials, exclIdx);
[stats, predictors, response, condNum, warnMsg, warnId] = logistic(predictors, response);

%If regression algorithm does not converge within time limit, etc.
if ~isempty(warnMsg)
    for P = string(fieldnames(X))'
        idx.(P) = [];
    end
end

%% Assign into output structure
regStruct.name              = strjoin(pNames(pNames~="bias"),'_');
regStruct.predictors        = pNames;

%Regression stats: beta, p, se
for P = string(fieldnames(X))' %f = string(fieldnames(idx)) 
    if ~isempty(idx.(P))
        regStruct.(P) = struct(...
            'beta', stats.beta(idx.(P))',...
            'se',(stats.beta(idx.(P))' - [stats.se(idx.(P)),-stats.se(idx.(P))]'),... %B -/+ SE
            'p',stats.p(idx.(P))');
    else
        regStruct.(P) = struct('beta', NaN,'se', [NaN,NaN]','p', NaN);
    end
end
%Additional outputs
regStruct.R_predictors  = corrcoef(predictors,'Rows','pairwise');
regStruct.N             = numel(response);
regStruct.conditionNum  = condNum;
regStruct.warning       = struct('msg',warnMsg,'ID',warnId);

%---------------------------------------------------------------------------------------------------

function [ predictors, pNames, idx ] = formatPredictors( X, trials, exclIdx )
%Idx into stats structure
pNames = fieldnames(X);
for k = 1:numel(pNames)
    nameVal(:,k) = [pNames(k); k];
end
idx = struct(nameVal{:});

%Special cases for sessions with only one sensory modality
if all(~trials.rightPuffs(~exclIdx)) && all(~trials.leftPuffs(~exclIdx))
    X = rmfield(X,'puffs'); %remove term from glm
    idx.puffs = [];
elseif all(~trials.rightTowers(~exclIdx)) && all(~trials.leftTowers(~exclIdx))
    X = rmfield(X,'towers'); %remove term from glm
    idx.towers = []; %For handling stats below
end

%Predictor matrix and idxs
pNames = string(fieldnames(X))'; %Output as string array
predictors = NaN(size(X.bias,1),numel(pNames));
for k = 1:numel(pNames)
    predictors(:,k) = X.(pNames{k});
    idx.(pNames(k)) = k;
end

%---------------------------------------------------------------------------------------------------

function [ stats, predictors, response, condNum, warnMsg, warnId ] = logistic( predictors, response )

%Remove rows with missing values (NaNs) for accurate N, etc.
exclIdx = any(isnan([predictors, response]),2);
predictors = predictors(~exclIdx,:);
response = response(~exclIdx);

%Exclude early sessions with few trials (rare)
if isempty(response) %|| all(isnan(sum(predictors,2)))
    [stats.beta, stats.se, stats.p] = deal(NaN(size(predictors,2)+1,1));
    predictors = deal(NaN(1,size(predictors,2)+1));
    response = NaN;
else
    lastwarn(''); % Clear last warning message
    [~,~,stats] = glmfit(predictors, response, 'binomial', 'link', 'logit','constant','off');
end
[warnMsg, warnId] = lastwarn;

%Get condition number for GLM
X = [ones(size(predictors,1),1),predictors]; %Design matrix
X = X(~isnan(sum(X,2)),:); %Omit nan rows, which are also omitted in regression
moment = X'*X; %Moment matrix of regressors
condNum = cond(moment); %Condition number

%---------------------------------------------------------------------------------------------------

function regParams = params( stats, term )

if ~isempty(term)
    regParams = struct(...
        'beta', stats.beta(term)',...
        'se',(stats.beta(term)' - [stats.se(term),-stats.se(term)]'),... %B -/+ SE
        'p',stats.p(term)');
else
    regParams = struct('beta', NaN,'se', [NaN,NaN]','p', NaN);
end