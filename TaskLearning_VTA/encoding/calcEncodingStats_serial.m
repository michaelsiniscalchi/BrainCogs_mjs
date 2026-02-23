%%% calcEncodingStats()
%
%PURPOSE: Hypothesis testing for each behavioral coefficient in regression
%           model for GCaMP cellular fluorescence time series.
%
%AUTHOR: MJ Siniscalchi, PNI, 260130
%
%--------------------------------------------------------------------------
% Observed Data
% -->get Full Model RSS/dF [ rss.full, df.full ]
% -->get Reduced Model RSS/dF for each predictor [ rss.(position), df.(position) ]
% -->calculate F-stat, F.(predictorName)
%
% Pseudosessions
% Shuffle trial sequence to generate pseudosessions; for each,
% -->get Full Model RSS/dF [ pseudo_rss.full, pseudo_df.full ]
% -->get Reduced Model RSS/dF for each predictor [ pseudo_rss.(predictorName), pseudo_df.(predictorName) ]
% -->calculate F-stat [ F_null.(predictorName) ]
%
% Calculate P-value for each Predictor
%   = mean(F_null(1:nShuffles) > F)
%   pValues.(predictorName)(1:nCells)
%
% F = ((RSS_full-RSS_reduced)/(df_full-df_reduced)) / (RSS_full/df_full);
% df = n-p-1, the df_error; correction used for ridge regression, see cvRidge() for details
%
%--------------------------------------------------------------------------

function [ pValues, pSignificant ] = calcEncodingStats( img_beh, params )

%Full Design Matrix
[X, encodingData] = ...
    encoding_makePredictors(img_beh.trialData, img_beh.trials, img_beh.t, params); %Make Predictors
pIdx = encodingData.predictorIdx;

for i = 1:numel(img_beh.dFF)
    % Calculate F-statistic for Full vs. Reduced model
    
    %Full model
    y = img_beh.dFF{i};
    [ rss.full, df.full ] = ...
        cvRidge(X, y, params.lambda, encodingData.trialIdx, params.lambda_kfolds);

    
    for f = params.predictorNames

        %Reduced model
        reducedIdx = true(1, size(X,2)); %Initialize predictor idx for reduced model
        reducedIdx(pIdx.(f)) = false; %Drop variable of interest

        X_reduced = X(:, reducedIdx);
        [ rss.reduced, df.reduced ] = ...
            cvRidge(X_reduced, y, params.lambda, encodingData.trialIdx, params.lambda_kfolds);

        F.(f) = ((rss.reduced-rss.full)/(df.reduced-df.full)) / (rss.full/df.full);
    end

    % Null Distribution for F-stat
    for j = 1:params.nShuffles
        %Construct new design matrix from shuffled trials
        [X_null, trialIdx] = generatePseudoSession(img_beh, params);

        %Full model - shuffled trials
        [ rss.full, df.full ] = ...
            cvRidge(X_null, y, params.lambda, trialIdx, params.lambda_kfolds);

        %Reduced models - shuffled trials
        for f = params.predictorNames
            reducedIdx = true(1, size(X,2)); %Initialize predictor idx for reduced model
            reducedIdx(pIdx.(f)) = false; %Drop variable of interest
            X_reduced = X_null(:, reducedIdx);

            [ rss.reduced, df.reduced ] = ...
                cvRidge(X_reduced, y, params.lambda, trialIdx, params.lambda_kfolds);

            F_null.(f)(j) = ((rss.reduced-rss.full)/(df.reduced-df.full)) / (rss.full/df.full);
            %In initial tests, found some RSS_full>RSS_reduced
        end
    end

    %P-value, calculated as P(F_null>F)
    for f = params.predictorNames
        pValues.(f)(i) = mean(F_null.(f)>F.(f));
    end
end

%Finally, get the proportion of cells p<alpha for each variable
for f = params.predictorNames
    pSignificant.(f) = mean(pValues.(f)<params.alpha);
end



function [y_hat, rss, mse] = ridgePredict( x, y, k )
beta = ridge(y, x, k, 0); %Last ARG=0, restore scale of the data, and include intercept
y_hat = [ones(size(x,1),1), x]*beta; %Append a column of ones for intercept
rss = norm(y - y_hat);
mse = mean((y - y_hat).^2, 1, "omitmissing"); %Training mse