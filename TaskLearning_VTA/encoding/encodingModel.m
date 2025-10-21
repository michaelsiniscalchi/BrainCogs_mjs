function glm = encodingModel( predictors, dFF, encodingData )

%-------Multiple Linear Regression Model------------------------------------------------

%Create Matrix of Regressors
pNames = string(fieldnames(predictors))';
X = [];
varNames = string([]);

%Name components of regression splines by number
for P = pNames
    nTerms = size(predictors.(P), 2);
    tempNames = P; %Initialize as predictor name, no numeric suffix
    if nTerms>1
        for i = 1:nTerms %Append term index for b-spline or higher order predictor (moments, etc.)
            tempNames(i) = strjoin([P, num2str(i)],'');
        end
    end
    varNames = [varNames, tempNames]; %#ok<AGROW>
    idx.(P) = 1 + size(X,2) + (1:nTerms); %1st term reserved for intercept
    X = [X, predictors.(P)]; %#ok<AGROW>
end

%Z-score the predictor matrix
X = normalize(X,1,"zscore");

for i = 1:numel(dFF)
    if encodingData.regularization=="ridge"
        %10-fold CV with each lambda to find minimum MSE
        [lambda, lambda_cv] = cvLambda(X, dFF{i}, encodingData.lambda,...
            encodingData.lambda_kfolds); %Find lambda value that minimizes MSE
        
        if encodingData.getRidgeTrace
            %Ridge regression on all timepoints w/ ridge trace for validation
            [yHat, ridgeTrace, mse] = ridgePredict(X, dFF{i}, encodingData.lambda); %[y_hat, beta, mse] = ridgePredict(x,y,k)
            kIdx = encodingData.lambda==lambda;
            yHat = yHat(:,kIdx);
            B = ridgeTrace(:,kIdx);
            mse = mse(kIdx);
        else
            %Ridge regression on all timepoints using cross-validated lambda value
            [yHat, B, mse] = ridgePredict(X, dFF{i}, lambda);
        end     
        
        %Generate output similar to fitglm()
        mdl.Coefficients = struct('Estimate', B, 'SE', nan(size(B)));
        mdl.Fitted = struct('Response', yHat, 'MSE', mse);
        mdl.Lambda = lambda;
        mdl.CV = struct('ridgeTrace', ridgeTrace, 'cvLambda', lambda_cv);
    else
        mdl = fitglm(X, dFF{i}, 'PredictorVars', varNames);
    end

    %Store model in struct
    glm.model{i} = mdl;

    %Model-predicted response
    glm.predictedDFF{i,:} = mdl.Fitted.Response;

    %Estimate response kernels for each event-related predictor (and other spline-bases)
    %***FOR SE, we need to linearly combine the MSE and take the square root! (you can't just take the weighted sum of the SEs)
    %*** square the SE, do the matrix multiplication, and then take the SQRT...
    for varName = [string(encodingData.eventVars), string(encodingData.positionVars)] %All event- & position-splines
        if ismember(varName, encodingData.positionVars)
            bSpline = encodingData.bSpline_pos; %series of basis functions for position
            binWidth = encodingData.bSpline_position_binWidth; %spatial bin width in cm
            x_min = encodingData.position(1); %Start location (cm)
        else
            bSpline = encodingData.bSpline; %series of basis functions of time following event
            binWidth = encodingData.dt; %Mean timestep per sample dF/F
            x_min = 0; %time from event
        end
        
        %Coefficient estimates and SE
        estimate = bSpline * mdl.Coefficients.Estimate(idx.(varName)); %(approx. resp func) = bSpline * Beta
        [mse, se] = deal(nan(size(estimate))); %initialize
        if encodingData.regularization~="ridge" %Coef SE estimates not meaningful after regularization
            mse = (mdl.Coefficients.SE(idx.(varName))).^2; %Calculate MSE, which is SE^2
            se = sqrt(bSpline * mse); %Square root of weighted MSE
        end

        %Spatial/temporal kernels
        glm.kernel(i).(varName).estimate = estimate'; %transpose for plotting
        glm.kernel(i).(varName).se = (estimate + [1,-1].*se)'; %Express as estimate +/- se; transpose for plotting
        glm.kernel(i).(varName).x = (0:binWidth:binWidth*(size(bSpline,1)-1)) + x_min;
        
        %AUC
        winDuration = range(glm.kernel(i).(varName).x);
        glm.kernel(i).(varName).AUC = mean(estimate)*winDuration;
        glm.kernel(i).(varName).AUC_se = sqrt(mean(mse).*winDuration);
        
        %Peak
        peak = max(abs(estimate)); %Find extreme value
        peakIdx = estimate==peak | estimate==-peak; %Get idx of extreme value
        glm.kernel(i).(varName).peak = estimate(peakIdx); %Recover sign
        glm.kernel(i).(varName).peak_se = se(peakIdx,:)';
        %L2 Norm of kernel estimate
        glm.kernel(i).(varName).L2 = norm(estimate); %Approx vector magnitude
    end

    %Kinematics
    for varName = string(encodingData.kinematicVars)
        glm.coef(i).(varName).estimate = mdl.Coefficients.Estimate(idx.(varName));
        glm.coef(i).(varName).se = mdl.Coefficients.SE(idx.(varName));
    end
end

%Calculate condition number for inversion of moment matrix
Xi = X(~isnan(sum(X,2)),:); %Omit nan rows, which are also omitted in regression
moment = Xi'*Xi; %Moment matrix of regressors; note that X is already z-scored
glm.conditionNum = cond(moment); %Condition number for inversion
glm.rank = rank(moment); %Rank
glm.corrMatrix = corrcoef(Xi);

%Variance Inflation Factor (VIF)
glm.VIF = diag(inv(corrcoef(Xi))); %Equivalent calculation: diagonal of the inverse correlation matrix

%Adjusted for ridge param
glm.conditionNum_adj = []; %Initialize
if encodingData.regularization == "ridge"
    moment2 = moment + lambda*eye(size(moment));
    glm.conditionNum_adj = cond(moment2);
end

%Metadata
glm.predictorIdx = idx;
for F = string(fieldnames(encodingData))'
    glm.(F) = encodingData.(F);
end

function [lambda_fit, cv] = cvLambda(X,y,lambda,kFolds)
CV = cvpartition(numel(y),"KFold",kFolds);
mse = nan(kFolds,numel(lambda)); %Initialize
for i = 1:CV.NumTestSets
    trainIdx = CV.training(i);
    testIdx = CV.test(i);
    nTest = CV.TestSize(i); 
    [~, beta] = ridgePredict(X(trainIdx,:), y(trainIdx), lambda);
    %Predict test responses from test predictors and training coefs
    y_hat = [ones(nTest,1), X(testIdx,:)]*beta; %Predicted response; size(y_hat) = [nObs, nLambda];
    mse(i,:) = mean((y(testIdx) - y_hat).^2); %Calc MSE; size(mse) = [kFolds, nLambda] 
end
cv = mean(mse); %Cross-validation MSE
lambda_fit = lambda(cv==min(cv)); %Lambda value with lowest CV MSE

function [y_hat, beta, mse] = ridgePredict(x,y,k)

beta = nan(size(x,2)+1, numel(k)); %Initialize ridge trace: size(beta)=[nPredictors, nLambda]
parfor i = 1:numel(k)
    beta(:, i) = ridge(y,x,k(i),0); %Last ARG=0, do not scale data, and include intercept
end
y_hat = [ones(size(x,1),1), x]*beta; %Append a column of ones for intercept
mse = mean((y - y_hat).^2); %Training mse

%NEXT STEP: determine the relative influence of each class of predictors in
%the model (ie, firstTower(1:n) or velocity) using mdl2 = removeTerms(mdl1, terms)
% mdl1 = removeTerms(mdl,'x2')
% %Variance Inflation Factor (VIF)
% parfor i = 1:numel(varNames) %start with ITI + position
%     idx = true(1, size(Xi,2)); %Idx of predictors to include
%     idx(i) = false; %Remove term (i)
%     newMdl = fitglm(Xi(:,idx), Xi(:,i)); %Predict var(i) based on remaining predictors
%     R2 = newMdl.Rsquared.Ordinary;
%     VIF(i) = 1/(1-R2);
% end
% glm.VIF = VIF';

%% Alternatives
% mdl = fitglm(X, dFF{i}, 'PredictorVars', varNames)
%
% [mdl, FitInfo ] = ...
%     fitrlinear(X', dFF{i},... %Transpose X to reduce exe time
%     'PredictorNames',varNames,...
%     'Regularization','ridge','ObservationsIn','columns',...
%     'OptimizeHyperparameters',{'Lambda'});
%
% [mdl, FitInfo] = ...
% fitrlinear(X', dFF{i},'ObservationsIn','columns','Learner', 'leastsquares'); %Ridge is default
% 
% [mdl, FitInfo] = ...
% fitrlinear(X', dFF{i},'ObservationsIn','columns','Lambda',lambda);
%  glm.model{i} = mdl;