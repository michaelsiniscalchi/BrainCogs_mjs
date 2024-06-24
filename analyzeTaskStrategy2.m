function subjects = analyzeTaskStrategy2(subjects)

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
        normCode = @(X) X./max(X,[],"omitnan");
        meanCenter = @(X) X-mean(X,1,"omitnan");

        %% GLM 1: Logistic regression of Choices based on each Sensory Modality

        % Y = Bias + towerSide(n)*X + puffSide(n)*X + Choice(n-1)*X + error
        X = struct(...
            'bias', ones(size(rightTowers)),... %Need field, but column of ones not used for glmfit(); used previously with fitglm()
            'towers', effectCode(rightTowers),... %Cueside(n)
            'puffs', effectCode(rightPuffs)...
            );
        response = rightChoice;

        subjects(i).sessions(j).glm1 = logisticStats(X, response, trials, exclIdx);
        subjects(i).sessions(j).glm1_bias = subjects(i).sessions(j).glm1.bias.beta;
        
        %% GLM 2: Logistic regression of Choices based on nCues_L, nCues_R
        % Y = B0 + nTowers_L*X + nTowers_R*X + nPuffs_L*X + nPuffs_R*X + error
        X = struct(...
            'bias',ones(size(rightTowers)),...
            'nTowersLeft', normCode(nTowersLeft),...
            'nTowersRight', normCode(nTowersRight),...
            'nPuffsLeft', normCode(nPuffsLeft),...
            'nPuffsRight', normCode(nPuffsRight)...
            );
       
        response = rightChoice;
        subjects(i).sessions(j).glm2 = logisticStats(X, response, trials, exclIdx);
        subjects(i).sessions(j).glm2_bias = subjects(i).sessions(j).glm2.bias.beta;

        %% GLM 3: Logistic regression of Choices based on nCues_L, nCues_R, and cueSide
        %         % Y = B0 + nTowers_L*X + nTowers_R*X + nPuffs_L*X + nPuffs_R*X + error
        %         X = struct(...
        %             'bias',ones(size(rightTowers)),...
        %             'towers', rightTowers,... %Cueside(n)
        %             'puffs', rightPuffs,...
        %             'nTowersLeft', nTowersLeft,...
        %             'nTowersRight', nTowersRight,...
        %             'nPuffsLeft', nPuffsLeft,...
        %             'nPuffsRight', nPuffsRight,...
        %             'priorChoice', rightPriorChoice...
        %             );
        %         response = rightChoice;
        %         subjects(i).sessions(j).glm3 = logisticStats(X, response, trials, exclIdx);
        %         subjects(i).sessions(j).glm3_bias = subjects(i).sessions(j).glm3.bias.beta;

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

%Format the predictors and append name of response variable
[predictors, pNames ] = formatPredictors(X, trials, exclIdx);
varNames = [pNames, "choice"]; %Append response name

%Regress based on specified terms
[mdl, condNum, warnMsg, warnId] = logistic(predictors, response, varNames);

%If regression algorithm does not converge within time limit, etc.
if ~isempty(warnMsg)
    %empty
end

%% Assign into output structure
regStruct.name              = strjoin(pNames(pNames~="bias"),'_');
regStruct.predictors        = pNames;
regStruct.model             = mdl;

%Regression stats: beta, p, se
for pName = string(fieldnames(X))' %pName = string(mdl.CoefficientNames)
    if ismember(pName,mdl.Coefficients.Properties.RowNames)
        regStruct.(pName) = struct(...
            'beta', mdl.Coefficients{pName,'Estimate'},...
            'se', mdl.Coefficients{pName,'Estimate'} + mdl.Coefficients{pName,'SE'}*[-1;1],... %B -/+ SE
            'p', mdl.Coefficients{pName,'pValue'});
    else
        regStruct.(pName) = struct('beta', NaN,'se', [NaN,NaN]','p', NaN);
    end
end

%Additional outputs
regStruct.R_predictors  = corrcoef(predictors,'Rows','pairwise');
regStruct.N             = numel(response);
regStruct.conditionNum  = condNum;
regStruct.warning       = struct('msg',warnMsg,'ID',warnId);

%GeneralizedLinearModel methods:
%mdl.CoefficientNames
%mdl.Coefficients.(pName).Estimate 
%mdl.Coefficients.(pName).SE
%mdl.Coefficients.(pName).pValue
%mdl.Fitted.Response
%mdl.Rsquared.Ordinary
%mdl.Rsquared.LLR

%---------------------------------------------------------------------------------------------------

function [ predictors, pNames ] = formatPredictors( X, trials, exclIdx )

%Special cases for sessions with only one sensory modality
if all(~trials.rightPuffs(~exclIdx)) && all(~trials.leftPuffs(~exclIdx))
    if isfield(X,'puffs')
        X = rmfield(X,'puffs'); %remove term from glm
    end
    if isfield(X,'nPuffsLeft')
        X = rmfield(X,{'nPuffsLeft','nPuffsRight'}); %remove term from glm
    end
elseif all(~trials.rightTowers(~exclIdx)) && all(~trials.leftTowers(~exclIdx))
    if isfield(X,'towers')
        X = rmfield(X,'towers'); %remove term from glm
    end
    if isfield(X,'nTowersLeft')
        X = rmfield(X,{'nTowersLeft','nTowersRight'}); %remove term from glm
    end
end

%Predictor matrix
pNames = string(fieldnames(X))'; %Output as string array
predictors = NaN(size(X.bias,1), numel(pNames));
for k = 1:numel(pNames)
    predictors(:,k) = X.(pNames{k});
end

%---------------------------------------------------------------------------------------------------

function [ mdl, condNum, warnMsg, warnId ] = logistic( predictors, response, varNames )

%Remove rows with missing values (NaNs) for accurate N, etc.
exclIdx = any(isnan([predictors, response]),2);
predictors = predictors(~exclIdx,:);
response = response(~exclIdx);

%Exclude early sessions with few trials (rare)
if isempty(response) %|| all(isnan(sum(predictors,2)))
    mdl = [];
    condNum = []
else
    lastwarn(''); % Clear last warning message

%Terms matrix (nTerms x (nTerms+1))
nTerms = size(predictors,2); %Number of predictors, including constant term (all included in 'predictors' var)
mdlSpec = [eye(nTerms),zeros(nTerms,1)]; %all terms first-order, with no interactions; last column represents response var    

%Fit GLM
mdl = fitglm(predictors, response, mdlSpec, 'Distribution', 'binomial', 'Link', 'logit', 'VarNames', varNames); %GeneralizedLinearModel object

end

%Get warnings
[warnMsg, warnId] = lastwarn;

%Calculate condition number for GLM
X = predictors; %Design matrix
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