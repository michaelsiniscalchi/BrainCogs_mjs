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

function [ pValues, pSignificant ] = calcEncodingStats_parallel( img_beh, params )

%Full Design Matrix
[X, encodingData] = ...
    encoding_makePredictors(img_beh.trialData, img_beh.trials, img_beh.t, params); %Make Predictors

%Unpack variables for parallelization
dFF = img_beh.dFF;
beh = rmfield(img_beh,{'dFF','cellID'});
pNames = string(fieldnames(encodingData.predictorIdx));
pIdx = struct2cell(encodingData.predictorIdx);
trialIdx = encodingData.trialIdx;

lambda = params.lambda;
lambda_kfolds = params.lambda_kfolds;
nShuffles = params.nShuffles;

%Initialize sliced variables
pValues_mat = NaN(numel(dFF), numel(pNames));

% parfor i = 1:numel(dFF)
parfor i = 1:numel(dFF)
    % Calculate F-statistic for Full vs. Reduced model
    
    %Full model
    F = NaN(1,numel(pNames)); %Initialize
    y = dFF{i};
    [ rss_full, df_full ] = ...
        cvRidge(X, y, lambda, trialIdx, lambda_kfolds);

    %Reduced model
    for p = 1:numel(pNames)   

        reducedIdx = true(1, size(X,2)); %Initialize predictor idx for reduced model
        reducedIdx(pIdx{p}) = false; %Drop variable of interest

        X_reduced = X(:, reducedIdx);
        [ rss_reduced, df_reduced ] = ...
            cvRidge(X_reduced, y, lambda, trialIdx, lambda_kfolds);

        %F-statistic for Full vs. Reduced Model
        F(p) = ((rss_reduced-rss_full)/(df_reduced-df_full)) / (rss_full/df_full);
    end

    % Null Distribution for F-stat
    F_null = NaN(nShuffles, numel(pNames)); %Initialize
    for j = 1:nShuffles
        %Construct new design matrix from shuffled trials
        [X_null, pseudoIdx] = generatePseudoSession(beh, params);

        %Full model - shuffled trials
        [ rss_full, df_full ] = ...
            cvRidge(X_null, y, lambda, pseudoIdx, lambda_kfolds);

        %Reduced models - shuffled trials
        for p = 1:numel(pNames)
            reducedIdx = true(1, size(X,2)); %Initialize predictor idx for reduced model
            reducedIdx(pIdx{p}) = false; %Drop variable of interest
            X_reduced = X_null(:, reducedIdx);

            [ rss_reduced, df_reduced ] = ...
                cvRidge(X_reduced, y, lambda, pseudoIdx, lambda_kfolds);

            %Null Distribution for the F-statistic (size: nShuffles x nPredictors)
            F_null(j, p) = ((rss_reduced-rss_full)/(df_reduced-df_full)) / (rss_full/df_full);
        end
    end

    %P-value, calculated as P(F_null>F)
    pValues_mat(i,:) = mean(F_null > F); 

end

%Get the proportion of cells p<alpha for each variable
%Convert matrix of p-values to struct
for p = 1:numel(pNames)
    pSignificant.(pNames(p)) = mean(pValues_mat(:,p)<params.alpha);
    pValues.(pNames(p)) = pValues_mat(:, p)';
end