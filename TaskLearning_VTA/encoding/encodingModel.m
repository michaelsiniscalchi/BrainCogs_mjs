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
dt = encodingData.dt; %Mean timestep per sample dF/F
bSpline = encodingData.bSpline;
%Z-score the predictor matrix
X = (X - mean(X,1,'omitnan')) ./ std(X,0,1,"omitnan"); %MATLAB zscore() does not allow 'omitnan'

for i = 1:numel(dFF)

    mdl = fitglm(X, dFF{i}, 'PredictorVars', varNames);
    glm.model{i} = mdl;

    %Estimate response kernels for each event-related predictor
    %***FOR SE, we need to linearly combine the MSE and take the square root! (you can't just take the weighted sum of the SEs) 
    %*** or square the SE, do the matrix multiplication, and then take the SQRT...
    for varName = string(encodingData.eventNames)'
        estimate = bSpline * mdl.Coefficients.Estimate(idx.(varName)); %(approx. resp func) = bSpline * Beta
        se = bSpline * mdl.Coefficients.SE(idx.(varName)); %***SEE NOTE ABOVE AND MODIFY***
        glm.kernel(i).(varName).estimate = estimate'; %transpose for plotting
        glm.kernel(i).(varName).se = (estimate + [1,-1].*se)'; %Express as estimate +/- se; transpose for plotting
        glm.kernel(i).(varName).t = 0:dt:dt*(size(bSpline,1)-1);
        %AUC
        winDuration = range(glm.kernel(i).(varName).t);
        glm.kernel(i).(varName).AUC = mean(estimate)*winDuration;
        glm.kernel(i).(varName).AUC_se = mean(se).*winDuration;
        %Peak
        peak = max(abs(estimate)); %Find extreme value
        peakIdx = estimate==peak | estimate==-peak; %Get idx of extreme value
        glm.kernel(i).(varName).peak = estimate(peakIdx); %Recover sign
        glm.kernel(i).(varName).peak_se = se(peakIdx,:)';
    end

%Predict full time series from model
glm.predictedDFF{i,:} = mdl.Fitted.Response;

end

%Metadata
glm.predictorIdx = idx;
for F = string(fieldnames(encodingData))'
    glm.(F) = encodingData.(F);
end

%NEXT STEP: determine the relative influence of each class of predictors in
%the model (ie, firstTower(1:n) or velocity) using mdl2 = removeTerms(mdl1, terms)
% mdl1 = removeTerms(mdl,'x2')