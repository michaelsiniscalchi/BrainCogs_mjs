function subjects = analyzeTaskStrategy(subjects)

for i = 1:numel(subjects)
    for j = 1:numel(subjects(i).sessions)
        
        %Skip forced choice (L-Maze) sessions 
        if subjects(i).sessions(j).sessionType=="Forced"
            continue
        end
               
        %Trial masks for predictors and response variable
        trials = subjects(i).trials(j);
        rightCue = trials.rightCue(~trials.omit)'; %Exclude omissions for all
        rightChoice = trials.right(~trials.omit)'; 
        reward = trials.correct(~trials.omit)'; %Trial outcome
        conflict = trials.conflict(~trials.omit)';
            
        %Additional session summary separated by conflict/congruent trials ***Add to getRemoteVRData.m
        pCorrect_conflict = mean(reward(conflict));
        pConflict = mean(conflict);
        subjects(i).sessions(j).pConflict = pConflict;
        subjects(i).sessions(j).pCorrect_conflict = pCorrect_conflict;
        
        congruent = trials.congruent(~trials.omit)'; 
        pCorrect_congruent = mean(reward(congruent));
        
        %% GLM 1: Logistic regression of Choices based on Sensory Cues and Prior Choice
        
        include = 2:numel(rightChoice); %Omit first trial
        rightPriorChoice = history(rightChoice,1);
        effectCode = @(X) 2*(X-0.5);
        predictors = effectCode([rightCue, rightPriorChoice]);
        response = rightChoice;
        
        %Run regression
        [stats, predictors, response, condNum, warnMsg, warnId] = logistic(predictors, response);
                
        %Assign into output structures
        subjects(i).sessions(j).glm1 = struct(...
            'Name','cueSide_priorChoice',...
            'bias',parms(stats,1),'cueSide',parms(stats,2),'priorChoice',parms(stats,3),...
            'R_predictors', min(corrcoef(predictors(include,:)),[],'all'),... %Excludes diagonal ones
            'R_cue_choice', min(corrcoef([rightCue(include),response(include)]),[],'all'),...
            'R_priorChoice_choice', min(corrcoef([rightPriorChoice(include),response(include)]),[],'all'),...
            'N',numel(include),...
            'pRightChoice',mean(rightPriorChoice(include)),'pRightCue',mean(rightCue(include)),...
            'conditionNum',condNum);
        
        if ~isempty(warnMsg)
            subjects(i).sessions(j).glm1.warning = struct('msg',warnMsg,'ID',warnId);
        end
        
        %% GLM 2: Logistic regression of Choices based on Choice x Outcome History (1-Back)
        % Y = Bias + Cue(n) + SUM( Choice(n-i)*Outcome(n-i)*X ) + error 

        nBack = 1;
        predictors = [...
            effectCode(rightCue),...                                                 %Cueside(n)
            effectCode(history(rightChoice,1:nBack)) .* history(reward,1:nBack),...  %Choice*Reward(n-1:n-5)
            effectCode(history(rightChoice,1:nBack)) .* history(~reward,1:nBack),... %Choice*NoReward(n-1:n-5)
            ];
        include = nBack+1:size(predictors,1);
        predictors = predictors(include,:); %Omit first n trials where Choice(n-nBack) is undefined
        response = rightChoice(include);

        %Regress
        [stats, predictors, response, condNum, warnMsg, warnId] = logistic(predictors, response);
        
        %Assign into output structures
        subjects(i).sessions(j).glm2 = struct(...
            'Name','cueSide_choice*outcome',...
            'Predictors',["Bias","CueSide","Rewarded Choice(n-1)","Unrewarded Choice(n-1)"],...           
            'bias',parms(stats,1),'cueSide',parms(stats,2),...
            'rewChoice',parms(stats,3),'unrewChoice',parms(stats,4),...
            'R_predictors', corrcoef(predictors),...
            'N',numel(response),...
            'pRightChoice',mean(rightChoice(include)),...
            'pRightCue',mean(rightCue(include)),...
            'pReward',mean(reward(include)),...
            'conditionNum',condNum);
        
        if ~isempty(warnMsg)
            subjects(i).sessions(j).glm2.warning = struct('msg',warnMsg,'ID',warnId);
        end
        
        %% GLM 3: Logistic regression of Choices based on Choice x Outcome History (5-Back)
        % Y = Bias + Cue(n) + SUM( Choice(n-i)*Outcome(n-i)*X ) + error 

        nBack = 5;
        predictors = [...
            effectCode(rightCue),...                                                 %Cueside(n)
            effectCode(history(rightChoice,1:nBack)) .* history(reward,1:nBack),...  %Choice*Reward(n-1:n-5)
            effectCode(history(rightChoice,1:nBack)) .* history(~reward,1:nBack),... %Choice*NoReward(n-1:n-5)
            ];
        include = nBack+1:size(predictors,1);
        predictors = predictors(include,:); %Omit first n trials where Choice(n-nBack) is undefined
        response = rightChoice(include);

        %Regress
        [stats, predictors, response, condNum, warnMsg, warnId] = logistic(predictors, response);
        
        %Autocorrelation (different results from xcorr()!)
%         'xcorrChoice', xcorr(rightChoice,nBack,'coeff'),...         %Autocorrelation of Choice vector
%         choiceHistory = history(rightChoice,1:nBack);
%         choiceHistory = choiceHistory(nBack+1:end,:); %Truncate to omit NaNs
%         choice =  rightChoice(nBack+1:end);
%         xcorrChoice = corrcoef([choice,choiceHistory]);
%         xcorrChoice = xcorrChoice(:,end:-1:1);
               
        %Assign into output structures
        subjects(i).sessions(j).glm3 = struct(...
            'Name','cueSide_choice*outcome',...
            'Predictors',["Bias","CueSide","Rewarded Choice(n-i)","Unrewarded Choice(n-i)"],...           
            'bias',parms(stats,1),'cueSide',parms(stats,2),...
            'rewChoice',parms(stats,3:7),'unrewChoice',parms(stats,8:12),...
            'xcorrChoice', xcov(rightChoice,nBack,'coeff'),...         %Autocovariance of Choice vector
            'R_predictors', corrcoef(predictors),...
            'N',numel(response),...
            'pRightChoice',mean(rightChoice(include)),...
            'pRightCue',mean(rightCue(include)),...
            'pReward',mean(reward(include)),...
            'conditionNum',condNum);
        
        if ~isempty(warnMsg)
            subjects(i).sessions(j).glm3.warning = struct('msg',warnMsg,'ID',warnId);
        end
        
        %% GLM 4: Logistic regression of Choices based on Choice History * Rule Conflict
        % Y = Bias + Choice(n-1)*Conflict(n)) + SUM(Choice(n-1)*nonConflict(n)) + error 
        
        nBack = 1;
        predictors = [...
            effectCode(history(rightChoice,1:nBack)) .* conflict,...  %Choice(n-1:n-nBack)*Conflict
            effectCode(history(rightChoice,1:nBack)) .* ~conflict,... %Choice(n-1:n-nBack)*Congruent
            ];
        predictors = predictors(nBack+1:end,:); %Omit first n trials where Choice(n-nBack) is undefined
        response = rightChoice(nBack+1:end);

        %Regress
        [stats, predictors, response, condNum, warnMsg, warnId] = logistic(predictors, response);
        
        %Assign into output structures
        subjects(i).sessions(j).glm4 = struct(...
            'Name','choice*conflict',...
            'Predictors',["Bias","Conflict(n-1)","Congruent(n-1)"],...
            'bias',parms(stats,1),'conflict',parms(stats,2),'congruent',parms(stats,3),...
            'R_predictors', min(corrcoef(predictors),[],'all'),... %Excludes diagonal ones
            'R_conflict_choice', min(corrcoef([predictors(:,1),response]),[],'all'),...
            'R_congruent_choice', min(corrcoef([predictors(:,2),response]),[],'all'),...
            'N',numel(response),...
            'pRightChoice',mean(response),...
            'pConflict',mean(conflict(nBack+1:end)),...
            'pReward',mean(reward(nBack+1:end)),...
            'conditionNum',condNum);
        
        if ~isempty(warnMsg)
            subjects(i).sessions(j).glm4.warning = struct('msg',warnMsg,'ID',warnId);
        end
        
    end
end

function trialHistory = history(trialMask,nBack)

trialHistory = nan(size(trialMask,1),numel(nBack));
for i = 1:numel(nBack)
    trialHistory(nBack(i)+1:end,i) = trialMask(1:end-nBack(i));
end

function [ stats, predictors, response, condNum, warnMsg, warnId ] = logistic( predictors, response )

%Exclude early sessions with few trials (rare)
if isempty(response) || all(isnan(sum(predictors,2)))
    [stats.beta, stats.se, stats.p] = deal(NaN(size(predictors,2)+1,1));
    predictors = deal(NaN(1,size(predictors,2)+1));
    response = NaN;
else
    lastwarn(''); % Clear last warning message
    [~,~,stats] = glmfit(predictors,response,'binomial','link','logit');
end
[warnMsg, warnId] = lastwarn;

%Get condition number for GLM
X = [ones(size(predictors,1),1),predictors]; %Design matrix
X = X(~isnan(sum(X,2)),:); %Omit nan rows, which are also omitted in regression
moment = X'*X; %Moment matrix of regressors
condNum = cond(moment); %Condition number

function regParams = parms( stats, terms ) 
regParams = struct(...
            'beta', stats.beta(terms)',...
            'se',(stats.beta(terms)' - [stats.se(terms),-stats.se(terms)]'),... %B -/+ SE
            'p',stats.p(terms)');