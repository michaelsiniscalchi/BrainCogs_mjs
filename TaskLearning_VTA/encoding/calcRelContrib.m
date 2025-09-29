%%% RC = calcRelContrib( mdl, idx )
%
%INPUT ARGS:
%   
%   mdl, a GeneralizedLinearModel intended to account for 
%       calcium signal (dF/F) based on a set of behavioral variables 
%
%   idx, a struct with one field containing the idxs into the terms matrix 
%       for each predictor
%
%OUTPUTS:
%
%   RC, a struct array of size nCells x 1, with one field for each
%       predictor, containing its relative % contribution to variance 
%       explained by the model 
%
%--------------------------------------------------------------------------

function [ RC, F, p ] = calcRelContrib(mdl, idx, trialData)

%Generate a set of pseudo-sessions to construct null distribution

% shuffle(i) = 

%Determine relative contribution of each predictor type
T = mdl.Formula.Terms; %terms matrix
for f = string(fieldnames(idx))'
    omittedTerms = T(idx.(f),:); %T after omission of indexed terms
    reducedMdl = removeTerms(mdl,omittedTerms); %Reduced model
    RC.(f) = 1 - (reducedMdl.Rsquared.Ordinary/mdl.Rsquared.Ordinary); 
end