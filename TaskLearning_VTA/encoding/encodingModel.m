function glm = encodingModel( X, dFF, cellID, encodingData )

%-------Multiple Linear Regression Model------------------------------------------------

%Initialize output struct
glm = struct('modelName', "",'sessionID',"",'session_date',[],...
    'model',[], 'cellID', "", 'X', [], 'coef', struct(), 'kernel', struct(),...
    'conditionNum',[],'VIF',[],'VIF_trace',[],...
    'rank',[],'corrMatrix',[],...
    'termIdx',[],'predictorIdx',[],...
    'predictedDFF',{cell(size(dFF))},'predictorNames',"");

for i = 1:numel(dFF)

    y = dFF{i};
    
    if encodingData.regularization=="ridge"
        %10-fold CV with each lambda to find minimum MSE
        [lambda, cv] = cvLambda(X, y, encodingData.lambda,...
            encodingData.lambda_kfolds, encodingData.trialIdx); %Find lambda value that minimizes MSE
        
        if encodingData.getRidgeTrace
            %Ridge regression on all timepoints w/ ridge trace for validation
            [yHat, ridgeTrace, mse] = ridgePredict(X, y, encodingData.lambda); %[y_hat, beta, mse] = ridgePredict(x,y,k)
            kIdx = encodingData.lambda==lambda;
            yHat = yHat(:,kIdx); %Predicted response for optimal lambda
            B = ridgeTrace(:,kIdx); %Ridge coefficients for optimal lambda
            mse = mse(kIdx); %MSE for optimal lambda

            %VIFs adjusted for each lambda
            if isempty(glm.VIF_trace)
                glm.VIF_trace = getVIF(X, encodingData.lambda);
            end

        else
            %Ridge regression on all timepoints using cross-validated lambda value
            [yHat, B, mse] = ridgePredict(X, y, lambda);
        end   

        %Generate output similar to fitglm()
        mdl.Coefficients = struct('Estimate', B, 'SE', nan(size(B)));
        rss = sum((y - yHat).^2, 1, "omitmissing"); 
        tss = sum((y - mean(y)).^2, 1, "omitmissing"); 
        r_squared = 1-(rss/tss); 
        mdl.Fitted = struct('Response', yHat, 'MSE', mse);
        mdl.Rsquared = r_squared;
        mdl.Lambda = lambda;
        mdl.CV = struct('ridgeTrace', ridgeTrace(2:end,:), 'cvLambda', cv); %Exclude B0 from ridege trace
    else
        mdl = fitglm(X, y, 'PredictorVars', varNames);
    end

    %Store model in struct
    glm.model{i} = mdl;
    
    %Model-predicted response
    glm.predictedDFF{i,:} = mdl.Fitted.Response;
    
    %Coefficients for all predictors
    glm.coef.estimate(i,:) = mdl.Coefficients.Estimate;
    glm.coef.se(i,:) = mdl.Coefficients.SE;

    %Estimate response kernels for each event-related predictor (and other spline-bases)
    %***FOR SE, we need to linearly combine the MSE and take the square root! (you can't just take the weighted sum of the SEs)
    %*** square the SE, do the matrix multiplication, and then take the SQRT...
    for varName = [string(encodingData.eventVars), string(encodingData.positionVars)] %All event- & position-splines
        binWidth = encodingData.dt; %Mean timestep per sample dF/F
        x_min = 0; %time from event
        if ismember(varName, encodingData.positionVarNames)
            bSpline = encodingData.bSpline.position; %series of basis functions for position
            binWidth = mean(diff(encodingData.position)); %spatial bin width in cm
            x_min = encodingData.position(1); %Start location (cm)
        elseif ismember(varName, encodingData.cueVarNames)
            bSpline = encodingData.bSpline.cue; %series of basis functions of time following event
        elseif ismember(varName, encodingData.outcomeVarNames)
            bSpline = encodingData.bSpline.outcome; %series of basis functions of time following event
        end
        
        %Coefficient estimates and SE
        estimate = bSpline * mdl.Coefficients.Estimate(encodingData.termIdx.(varName)); %(approx. resp func) = bSpline * Beta
        [mse, se] = deal(nan(size(estimate))); %initialize
        if encodingData.regularization~="ridge" %Coef SE estimates not meaningful after regularization
            mse = (mdl.Coefficients.SE(encodingData.termIdx.(varName))).^2; %Calculate MSE, which is SE^2
            se = sqrt(bSpline * mse); %Square root of weighted MSE
        end

        %Spatial/temporal kernels
        glm.kernel(i).(varName).estimate = estimate'; %transpose for plotting
        glm.kernel(i).(varName).se = (estimate + [1,-1].*se)'; %Express as estimate +/- se; transpose for plotting
        glm.kernel(i).(varName).x = (0:binWidth:binWidth*(size(bSpline, 1)-1)) + x_min;
        
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
end

%Store design matrix, then remove NaN rows for further analysis
glm.X = [ones(size(X,1),1), X]; %Append a column of ones for constant term
X = glm.X(~any(isnan(glm.X),2),:); %Remove NaN rows, which are omitted in regression

%Calculate VIF and condition number for inversion of moment matrix
VIF = getVIF(X); %Variance Inflation Factor (VIF)
glm.VIF = VIF(2:end,:); %Include constant term in VIF calculation, but don't store VIF for c
glm.conditionNum = cond(X);

glm.rank = rank(X); %Rank of design matrix, X
glm.corrMatrix = corrcoef(X(:,2:end)); %Correlation matrix, only the predictors; omitting rows containing NaN

%Metadata
glm.cellID = cellID;
for F = string(fieldnames(encodingData))'
    glm.(F) = encodingData.(F);
end

%-------INTERNAL FUNCTIONS-------------------------------------------------

function [M, nObs] = momentMat(X)
idx = ~isnan(sum(X,2));
nObs = sum(idx);
X = X(idx,:); %Omit nan rows, which are also omitted in regression
M = X'*X; %Moment matrix of regressors; note that X should be standardized

function VIF = getVIF(X, k)
if nargin==1
    k = 0; %Ridge parameter, lambda
end

VIF = NaN(size(X,2), numel(k)); %Initialize array
[XtX, nObs]  = momentMat(X);
for j = 1:numel(k)
    M = XtX + k(j)*eye(size(XtX)); %Penalized moment matrix for inversion
    R = M/(nObs-1); %R = XtX/nObservations; to work, columns of X must be standardized!
    VIF(:,j) = diag(inv(R)); %Equivalent matrix operation for VIF: Trace of Inverse Correlation MAtrix 
end

function [lambda_fit, cvError] = cvLambda( X, y, lambda, kFolds, trialIdx )
trialIDs = unique(trialIdx);
CV = cvpartition(numel(trialIDs), "KFold", kFolds);
mse = nan(kFolds,numel(lambda)); %Initialize
for i = 1:CV.NumTestSets
    trainIdx = ismember(trialIdx, trialIDs(CV.training(i)));
    testIdx = ismember(trialIdx, trialIDs(CV.test(i)));
    nTest = sum(testIdx); 
    [~, beta] = ridgePredict(X(trainIdx,:), y(trainIdx), lambda);
    %Predict test responses from test predictors and training coefs
    y_hat = [ones(nTest,1), X(testIdx,:)]*beta; %Predicted response; size(y_hat) = [nObs, nLambda];
    mse(i,:) = mean((y(testIdx) - y_hat).^2,1,"omitnan"); %Calc MSE; size(mse) = [kFolds, nLambda] 
end
cvError = mean(mse); %Cross-validation MSE
lambda_fit = lambda(cvError==min(cvError)); %Lambda value with lowest CV MSE

function [y_hat, beta, mse] = ridgePredict( x, y, k )

beta = nan(size(x,2)+1, numel(k)); %Initialize ridge trace: size(beta)=[nPredictors+nIntercept, nLambda]
parfor i = 1:numel(k)
    beta(:, i) = ridge(y, x, k(i),0); %Last ARG=0, restore scale of the data, and include intercept
end
y_hat = [ones(size(x,1),1), x]*beta; %Append a column of ones for intercept
mse = mean((y - y_hat).^2, 1, "omitmissing"); %Training mse

%NEXT STEP: determine the relative influence of each class of predictors in
%the model (ie, firstTower(1:n) or velocity) using mdl2 = removeTerms(mdl1, terms)
%**** NOT VALID FOR RIDGE REGRESSION...NEED ALT ANALYSIS
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

