function subjects = analyzeTaskStrategy(subjects, nBins_psychometric)

for i = 1:numel(subjects)
    for j = 1:numel(subjects(i).sessions)

        %Skip forced choice (L-Maze) sessions
        taskRule = subjects(i).sessions(j).taskRule;
        if ismember(taskRule,...
                ["forcedChoice","tactileCS","visualCS","leftCS","rightCS"])
            continue
        end

        %Trial masks for predictors and response variable
        trials = subjects(i).trials(j);
        trialData = subjects(i).trialData(j);
        exclIdx = trials.omit(:) | ~trials.forward(:);
        priorExclIdx = [true; exclIdx(1:end-1)];
        noCuesIdx = trials.noCues(:);

        %Cue Side
        rightTowers = trials.rightTowers(:); %Exclude omissions and ~forward trials
        leftTowers  = trials.leftTowers(:); 
        rightPuffs  = trials.rightPuffs(:); %Exclude omissions for all
        leftPuffs   = trials.leftPuffs(:); 
        
        %Effects code with zero cue trials
        towerSide = zeros(size(rightTowers)); 
        towerSide(leftTowers) = -1;
        towerSide(rightTowers) = 1;
        puffSide = zeros(size(rightPuffs)); 
        puffSide(leftPuffs) = -1;
        puffSide(rightPuffs) = 1;

        %Number of Puffs | Towers
        nPuffsLeft = trialData.nPuffs(:,1);
        nPuffsRight = trialData.nPuffs(:,2);
        nTowersLeft = trialData.nTowers(:,1);
        nTowersRight = trialData.nTowers(:,2);
        
        %Number of Cues | Distractors
        if taskRule=="tactile"
            nCues = sum([nPuffsLeft, nPuffsRight],2);
            nDistractors = sum([nTowersLeft, nTowersRight],2);
        elseif taskRule=="visual"
            nCues = sum([nTowersLeft, nTowersRight],2);
            nDistractors = sum([nPuffsLeft, nPuffsRight],2);
        end

        %Rule Conflict
        congruent = trials.congruent(:);
        conflict = trials.conflict(:);
        ruleConflict = trials.conflict(:);
        
        %Prior Choice
        rightPriorChoice = double(trials.priorRight(:));
        
        %Code predictors as {-1,1}
        effectCode = @(X) 2*(X-0.5); %No longer viable for cue-side after inclusion of zero-cue trials
        normCode = @(X) X./max(X,[],"omitnan");
        meanCenter = @(X) X-mean(X,1,"omitnan");

        %% GLM 1: Logistic regression of Choices based on each Sensory Modality

        % Y = Bias + towerSide(n)*X + puffSide(n)*X + Choice(n-1)*X + error
        X = struct(...
            'bias', ones(size(rightTowers)),... %Need field, but column of ones not used for glmfit(); used previously with fitglm()
            'towers', towerSide,... %Cueside(n)
            'puffs', puffSide,...
            'priorChoice', effectCode(rightPriorChoice)...
            );
        responseName = "rightChoice";
        trials.rightChoice = trials.right; %For labels/readability and for flexibility to regress other output vars (eg outcome in glm3)
        exclude = exclIdx | priorExclIdx;   %**If history terms are included**

        %Skip sessions with missing predictors
        f = fieldnames(X);
        if any(cellfun(@(f) all(isnan(X.(f))), f))
            continue
        end

        subjects(i).sessions(j).glm1 = logisticStats(X, responseName, trials, trialData, exclude, nBins_psychometric);
        b0 = subjects(i).sessions(j).glm1.bias.beta;
        subjects(i).sessions(j).glm1_bias = exp(b0)/(1+exp(b0)); %P = odds/(1+odds)
        
        %% GLM 2: Logistic regression of Choices based on nCues_L, nCues_R
        % Y = B0 + nTowers_L*X + nTowers_R*X + nPuffs_L*X + nPuffs_R*X + error
        X = struct(...
            'bias',ones(size(rightTowers)),...
            'nTowersLeft', normCode(nTowersLeft),...
            'nTowersRight', normCode(nTowersRight),...
            'nPuffsLeft', normCode(nPuffsLeft),...
            'nPuffsRight', normCode(nPuffsRight),...
            'priorChoice', rightPriorChoice...
            );
        responseName = "rightChoice";
        trials.rightChoice = trials.right; %For labels/readability and for flexibility to regress other output vars (eg outcome in glm3)
        exclude = exclIdx | priorExclIdx; %**If history terms are included* 
              
        subjects(i).sessions(j).glm2 = logisticStats(X, responseName, trials, trialData, exclude, nBins_psychometric);
        
        b0 = subjects(i).sessions(j).glm2.bias.beta;
        subjects(i).sessions(j).glm2_bias = exp(b0)/(1+exp(b0)); %P = odds/(1+odds)

        %% GLM 3: Logistic regression of Outcomes based on nCues & nDistractors
        %         % Y = B0 + X*nCues + X*nDistractors + X*ruleConflict + X*(nCues*ruleConflict) + X*(nDistractors*ruleConflict) + error
                X = struct(...
                    'bias', ones(size(nCues)),...
                    'nCues', nCues,... %Cueside(n)
                    'nDistractors', nDistractors,...
                    'nCuesXConflict', nCues.*ruleConflict,...
                    'nDistractorsXConflict', nDistractors.*ruleConflict...
                    ); 
                % 'ruleConflict', ruleConflict,... 
                
                responseName = "correct";
                exclude = exclIdx | noCuesIdx;
                subjects(i).sessions(j).glm3 =...
                    logisticStats(X, responseName, trials, trialData, exclude, nBins_psychometric);

                  b0 = subjects(i).sessions(j).glm3.bias.beta;
                  subjects(i).sessions(j).glm3_bias =... 
                            exp(b0)/(1+exp(b0)); %P = odds/(1+odds)
           

    end
end
%---------------------------------------------------------------------------------------------------

function trialHistory = history(trialMask,nBack)

trialHistory = nan(length(trialMask),numel(nBack));
for i = 1:numel(nBack)
    trialHistory(nBack(i)+1:end,i) = trialMask(1:end-nBack(i));
end

%---------------------------------------------------------------------------------------------------

function regStruct = logisticStats( X, responseName, trials, trialData, exclIdx, nBins_psychometric)

%% Regress

%Format the predictors and append name of response variable
[predictors, pNames ] = formatPredictors(X, trials, exclIdx);
varNames = [pNames, responseName]; %Append response name

%Regress based on specified terms
response = trials.(responseName)(~exclIdx);
[mdl, condNum, warnMsg, warnId] = logistic(predictors, response(:), varNames);

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
    if ismember(pName, mdl.Coefficients.Properties.RowNames)
        regStruct.(pName) = struct(...
            'beta', mdl.Coefficients{pName,'Estimate'},...
            'se', mdl.Coefficients{pName,'Estimate'} + mdl.Coefficients{pName,'SE'}*[-1;1],... %B -/+ SE
            'p', mdl.Coefficients{pName,'pValue'});
    else
        regStruct.(pName) = struct('beta', NaN,'se', [NaN,NaN]','p', NaN);
    end
end

%Predicted choice
regStruct.predictedResponse   = mdl.Fitted.Response>0.5; %choose_R or choose_correct if P(choose_R)>0.5

%Psychometric curve based on model parameters
trials.(responseName)(~exclIdx) = regStruct.predictedResponse; %Model/curve based on right- or correct-choice trials, omitted trials excluded within function
regStruct.psychometric = getPsychometricCurve(responseName, trialData, trials, ~exclIdx, nBins_psychometric);

%Side-specific cue sensitivity (similar to "slope" in Garcia, Lak et al., bioRxiv 2023)
if responseName=="rightChoice"
    regStruct.sensitivity.puffs = ...
        calcSensitivity(regStruct.bias.beta, response, trials.rightPuffs(~exclIdx)'); %[sensitivity_L, sensitivity_R]
    regStruct.sensitivity.towers = calcSensitivity(regStruct.bias.beta, response, trials.rightTowers(~exclIdx)');
end

%Additional outputs
regStruct.R2                = mdl.Rsquared.Ordinary;
regStruct.R2_adj            = mdl.Rsquared.AdjGeneralized;
regStruct.N                 = numel(response);
regStruct.R_predictors      = corrcoef(predictors,'Rows','pairwise');
regStruct.conditionNum      = condNum;
regStruct.warning           = struct('msg',warnMsg,'ID',warnId);

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
predictors = NaN(sum(~exclIdx), numel(pNames));
for k = 1:numel(pNames)
    predictors(:,k) = X.(pNames{k})(~exclIdx);
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
    condNum = [];
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
condNum = cond(X); %Condition number: Ilana says take this condition number because SVD is used (rather than matrix inversion)

%---------------------------------------------------------------------------------------------------

function sensitivity_LR = calcSensitivity( b0, rightChoice, rightCues )
% Absolute difference between eg (pRight|rightCue) and pRight (approx by bias)
%***Update after incusion of zero-cues trials--need mean(rightChoice(leftCues))
bias = exp(b0)/(1+exp(b0)); %P = odds/(1+odds)
sensitivity_LR = abs([mean(rightChoice(~rightCues)), mean(rightChoice(rightCues))]-bias);
