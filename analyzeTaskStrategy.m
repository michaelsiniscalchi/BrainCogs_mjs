function subjects = analyzeTaskStrategy(subjects)

for i = 1:numel(subjects)
    for j = 1:numel(subjects(i).sessions)

        %Skip forced choice (L-Maze) sessions
        if subjects(i).sessions(j).taskRule=="forcedChoice"
            continue
        end

        %Trial masks for predictors and response variable
        trials = subjects(i).trials(j);
        exclIdx = trials.omit | ~trials.forward;
        priorExclIdx = [true, exclIdx(1:end-1)];

        rightTowers = trials.rightTowers(~exclIdx)'; %Exclude omissions and ~forward trials
        rightPuffs = trials.rightPuffs(~exclIdx)'; %Exclude omissions for all
        rightChoice = trials.right(~exclIdx)';
        rightPriorChoice = trials.priorRight';
        rightPriorChoice(priorExclIdx) = NaN;
        rightPriorChoice = rightPriorChoice(~exclIdx);
        reward = trials.correct(~exclIdx)'; %Trial outcome

        %Code predictors as {-1,1}
        effectCode = @(X) 2*(X-0.5);

        %% GLM 1: Logistic regression of Choices based on each Sensory Modality

        % Y = Bias + towerSide(n)*X + puffSide(n)*X + Choice(n-1)*X + error
        X = struct(...
            'bias',ones(size(rightTowers)),...
            'towers', effectCode(rightTowers),... %Cueside(n)
            'puffs', effectCode(rightPuffs)...
            );
        response = rightChoice;
        subjects(i).sessions(j).glm1 = logisticStats(X, response, trials, exclIdx);
        subjects(i).sessions(j).glm1_bias = subjects(i).sessions(j).glm1.bias.beta;

%         %Effect code the predictors and response
%         bias = ones(size(rightChoice));
%         predictors = [bias, effectCode([rightTowers, rightPuffs])]; %Add column of ones to idx bias term in more complicated glms below
%         response = rightChoice;
% 
%         %Idx into stats structure
%         [biasIdx, towerIdx, puffIdx] = deal(1,2,3);
% 
%         %Special cases for sessions with only one sensory modality
%         if all(~trials.rightPuffs(~exclIdx)) && all(~trials.leftPuffs(~exclIdx))
%             predictors = [bias, effectCode(rightTowers)];
%             rightPuffs = nan(size(rightPuffs));
%             puffIdx = [];
%         elseif all(~trials.rightTowers(~exclIdx)) && all(~trials.leftTowers(~exclIdx))
%             predictors = [bias, effectCode(rightPuffs)];
%             rightTowers = nan(size(rightTowers));
%             puffIdx = 2; %Replace towerIdx in stats
%             towerIdx = [];
%         end
% 
%         %Run regression
%         [stats, predictors, response, condNum, warnMsg, warnId] = logistic(predictors, response);
% 
%         %If regression algorithm does not converge within time limit, etc.
%         if ~isempty(warnMsg)
%             [biasIdx, towerIdx, puffIdx] = deal([]);
%         end
% 
%         %Assign into output structures
%         subjects(i).sessions(j).glm1 = struct(...
%             'Name','towerSide_puffSide',...
%             'bias',params(stats, biasIdx),...
%             'towerSide',params(stats, towerIdx),...
%             'puffSide',params(stats, puffIdx),...
%             'R_predictors', min(corrcoef(predictors),[],'all'),... %Excludes diagonal ones
%             'R_towerSide_choice', min(corrcoef([rightTowers, response]),[],'all'),...
%             'R_puffSide_choice', min(corrcoef([rightPuffs, response]),[],'all'),...
%             'N',size(predictors,1),...
%             'pRightTowers', mean(rightTowers), 'pRightPuffs', mean(rightPuffs),...
%             'conditionNum',condNum,...
%             'warning', struct('msg',warnMsg,'ID',warnId)...
%             );

        %% GLM 2: Logistic regression of Choices based on Cues, Prior Choice, and Prior Choice x Outcome
        % Y = Bias + towerSide(n)*X + puffSide(n)*X + Choice(n-1)*X + error
        X = struct(...
            'bias',ones(size(rightTowers)),...
            'towers', effectCode(rightTowers),... %Cueside(n)
            'puffs', effectCode(rightPuffs),...
            'priorChoice', effectCode(rightPriorChoice)...
            );
        response = rightChoice;
        subjects(i).sessions(j).glm2 = logisticStats(X, response, trials, exclIdx);
        subjects(i).sessions(j).glm2_bias = subjects(i).sessions(j).glm2.bias.beta;

        %         %Regress
        %         [predictors, pNames, idx] = formatPredictors(X,trials,exclIdx);
        %         [stats, predictors, response, condNum, warnMsg, warnId] = logistic(predictors, response);
        %
        %         %If regression algorithm does not converge within time limit, etc.
        %         if ~isempty(warnMsg)
        %             for f = string(fieldnames(X))'
        %                 idx.(f) = [];
        %             end
        %         end
        %
        %         %Assign into output structures
        %         subjects(i).sessions(j).glm2 = struct(...
        %             'Name','towerSide_puffSide_choice',...
        %             'Predictors', strjoin(pNames(pNames~="bias"),'_'),...
        %             'bias',params(stats, idx.bias),...
        %             'towerSide',params(stats, idx.towers),...
        %             'puffSide',params(stats, idx.puffs),...
        %             'priorChoice',params(stats, idx.priorChoice),...
        %             'R_predictors', corrcoef(predictors,'Rows','pairwise'),...
        %             'N',numel(response),...
        %             'conditionNum',condNum,...
        %             'warning', struct('msg',warnMsg,'ID',warnId)...
        %             );


        %% GLM 3: Logistic regression of Choices based on Cues, Prior Choice, and Prior Choice x Outcome
        % Y = Bias + towerSide(n)*X + puffSide(n)*X + SUM(Choice(n-i)*Outcome(n-i)*X) + error
        X = struct(...
            'bias',ones(size(rightTowers)),...
            'towers', effectCode(rightTowers),... %Cueside(n)
            'puffs', effectCode(rightPuffs),...
            'priorRewChoice', effectCode(rightPriorChoice) .* history(reward,1),...
            'priorUnrewChoice', effectCode(rightPriorChoice) .* history(~reward,1)...
            );
        response = rightChoice;
        subjects(i).sessions(j).glm3 = logisticStats(X, response, trials, exclIdx);

%         predictorNames = ["Bias","TowerSide","PuffSide","PriorRewChoice","PriorUnrewChoice"];
%         X = struct(...
%             'bias',ones(size(rightTowers)),...
%             'towers', effectCode(rightTowers),... %Cueside(n)
%             'puffs', effectCode(rightPuffs),...
%             'priorRewChoice', effectCode(rightPriorChoice) .* history(reward,1),...
%             'priorUnrewChoice', effectCode(rightPriorChoice) .* history(~reward,1)...
%             );
% 
%         %Idx into stats structure
%         pNames = fieldnames(X);
%         for k = 1:numel(pNames)
%             nameVal(:,k) = [pNames(k); k];
%         end
%         idx = struct(nameVal{:});
% 
%         %Special cases for sessions with only one sensory modality
%         if all(~trials.rightPuffs(~exclIdx)) && all(~trials.leftPuffs(~exclIdx))
%             X = rmfield(X,'puffs'); %remove term from glm
%             predictorNames = predictorNames(predictorNames~="PuffSide");
%             rightPuffs = nan(size(rightPuffs)); %For correlation output to indicate NaN
%             idx.puffs = [];
%         elseif all(~trials.rightTowers(~exclIdx)) && all(~trials.leftTowers(~exclIdx))
%             X = rmfield(X,'towers'); %remove term from glm
%             predictorNames = predictorNames(predictorNames~="TowerSide");
%             rightTowers = nan(size(rightTowers)); %For correlation output to indicate NaN
%             idx.towers = []; %For handling stats below
%         end
% 
%         %Predictor matrix and idxs
%         pNames = fieldnames(X);
%         predictors = NaN(size(rightTowers,1),numel(pNames));
%         for k = 1:numel(pNames)
%             predictors(:,k) = X.(pNames{k});
%             idx.(pNames{k}) = k;
%         end
% 
%         %Regress
%         response = rightChoice;
%         [stats, predictors, response, condNum, warnMsg, warnId] = logistic(predictors, response);
% 
%         %If regression algorithm does not converge within time limit, etc.
%         if ~isempty(warnMsg)
%             [idx.bias, idx.towers, idx.puffs] = deal([]);
%         end
% 
%         %Assign into output structures
%         subjects(i).sessions(j).glm3 = struct(...
%             'Name', 'towerSide_puffSide_choice*outcome',...
%             'Predictors', predictorNames,...
%             'bias', params(stats, idx.bias),...
%             'towerSide', params(stats, idx.towers),...
%             'puffSide', params(stats, idx.puffs),...
%             'priorRewChoice', params(stats, idx.priorRewChoice),...
%             'priorUnrewChoice', params(stats, idx.priorUnrewChoice),...
%             'R_predictors', corrcoef(predictors,'Rows','pairwise'),...
%             'N', numel(response),...
%             'pRightChoice',mean(rightChoice),...
%             'pRightTowers',mean(rightTowers),...
%             'pRightPuffs',mean(rightPuffs),...
%             'pReward',mean(reward),...
%             'conditionNum',condNum,...
%             'warning', struct('msg',warnMsg,'ID',warnId)...
%             );


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