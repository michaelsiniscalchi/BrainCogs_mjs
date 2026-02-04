%%% cvRidge(X, y, lambda, grouping, kFolds) 
%
%PURPOSE: Ridge Regression with Cross-Validation
%
%INPUT ARGS:
%   X, the design matrix, omitting the intercept term
%   y, the output variable
%   lambda, a vector of regularization parameter values
%   grouping, a vector of group labels, eg trial index for each sample in y
%   kFolds, the number of folds for cross-validation
%
%OUTPUTS:
%   rss, the residual sum of squares
%   dF, the degrees of freedom associated with X and lambda_fit
%   lambda_fit, the optimal regularization parameter determined by
%       cross-validation
%
%AUTHOR: MJ Siniscalchi, PNI, 260129
%
%--------------------------------------------------------------------------

function [ rss, dF, lambda_fit ] = cvRidge(X, y, lambda, grouping, kFolds)

%Select regularization parameter using K-fold CV
lambda_fit = cvLambda(X, y, lambda, kFolds, grouping); %Find lambda value that minimizes MSE; random sample of groups (eg, trial indices) 

%Estimate model parameters and predict output variable
y_hat = ridgePredict(X, y, lambda_fit );
rss = sum((y - y_hat).^2, 1, "omitmissing"); %Residual sum of squares

%Calculate Degrees of Freedom
% *For Ridge Regression, df(lambda) = sum(d.^2/(d.^2+lambda))
%   d, the singular values of X: d = svd(X)
X = X(~any(isnan(X),2),:); %Remove NaN rows, which are omitted in regression
d = svd(X); %Get singular values from SVD
dF_lambda = sum(d.^2./(d.^2+lambda_fit)); %Calculate dF assoc with the coefficients B1...Bn
dF = size(X,1)-dF_lambda-1; %Error df = n-p-1, where p=df_lambda

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