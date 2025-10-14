clearvars;

subjectID = "m913";

[ dirs, expData, calculate, summarize, figures, mat_file, params ] =...
    getAnalysisParams_T2V( subjectID );

% options.calculate = struct('encoding',true)
idx = find(ismember({expData.sub_dir},{'250212-m913-maze7'}));
pathname = fullfile(dirs.results,expData(idx).sub_dir,"encodingMdl_cell004.mat");
S = load(mat_file.results.encoding(idx),'cellID','conditionNum',...
    'corrMatrix','VIF','VIF2','rank','predictorIdx');
load(pathname, 'mdl'); %Model for individual cell


%% Variance Inflation Factor
%VIF(i) = 1/(1-R_2(i)); from a regression of P(i) as fcn of all other predictors
%Equivalent to diagonal of the inverted correlation matrix
%VIF = diag(inv(S.corrMatrix{4})); %Idx arbitrary if all cells use same model

Tbl = mdl.Variables(:,1:end-1);
varNames = Tbl.Properties.VariableNames;
x = 1:numel(varNames);
% VarDecompTbl = collintest(Tbl)

figure; 
title('Variance Inflation Factors')
% plot(x,S.VIF,'LineWidth',2);
bar(x,S.VIF);
xlabel('Predictors'); ylabel('VIF'); 
set(gca,'XTick',x,'XTickLabel',varNames);
%Returned some large negative values!


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
