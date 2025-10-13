clearvars;

subjectID = "m913";

[ dirs, expData, calculate, summarize, figures, mat_file, params ] =...
    getAnalysisParams_T2V( subjectID );

% options.calculate = struct('encoding',true)
idx = find(ismember({expData.sub_dir},{'250212-m913-maze7'}));
pathname = fullfile(dirs.results,expData(idx).sub_dir,"encodingMdl_cell004.mat");
S = load(mat_file.results.encoding(idx));%,'cellID','conditionNum','corrMatrix','rank','predictorIdx');
load(pathname, 'mdl'); %Model for individual cell



T = mdl.Formula.Terms; %terms matrix
predictors = ["position", "viewAngle", "velocity", "acceleration","ITI"];
for i = 1:numel(predictors)
    idx = S.predictorIdx.(predictors(i));
    omittedTerms = T(idx,:); %T after omission of indexed terms
    reducedMdl = removeTerms(mdl,omittedTerms); %Reduced model
    %Calculate condition number for inversion of moment matrix
    X  = table2array(mdl.Variables(:,1:end-1)); %Last column reserved for Y 
    X = [ones(length(X),1), X]; %Add a column of ones for intercept term
    Xi = X(~isnan(sum(X,2)),:); %Omit nan rows, which are also omitted in regression
    moment = Xi'*Xi; %Moment matrix of regressors; note that X is already z-scored
    glm.conditionNum{i,:} = cond(moment); %Condition number
    glm.rank{i,:} = rank(moment); %Rank
    glm.corrMatrix{i,:} = corrcoef(Xi); 


    reduced.(predictors(i)) = reducedMdl;
end

%Tbl.Properties.VariableNames
Tbl = mdl.Variables(:,1:end-1);
% VarDecompTbl = collintest(Tbl)

%% Variance Inflation Factor
%VIF(i) = 1/(1-R_2(i)); from a regression of P(i) as fcn of all other predictors
%Equivalent to diagonal of the inverted correlation matrix
%VIF = diag(inv(S.corrMatrix{4})); %Idx arbitrary if all cells use same model

X = table2array(Tbl);
idx = ~any(isnan(X),2);
X = X(idx,:);
R0 = inv(corrcoef(X));
VIF = diag(R0);

x = 1:numel(VIF);
predictorNames = string(mdl.VariableNames(1:end-1))';
figure; 
title('Variance Inflation Factors')
plot(x,VIF,'LineWidth',2);
xlabel('Predictors'); ylabel('VIF'); 
set(gca,'XTick',X,'XTickLabel',predictorNames);
%Returned some large negative values!

Tbl = mdl.Variables(:,1:end-1); %Last col reserved for response var Y
predictorNames = mdl.VariableNames(1:end-1); %Last col reserved for response var Y
X = table2array(Tbl);

parfor i = 1:numel(predictorNames) %start with ITI + position
    idx = true(1, size(X,2));
    idx(i) = false;
    newMdl = fitglm(X(:,idx), X(:,i), 'PredictorVars', mdl.VariableNames(idx));
    R2(i) = newMdl.Rsquared.Ordinary;
    VIF(i) = 1/(1-R2(i));
end