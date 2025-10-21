%Clearly, we've got multicollinearity issues. One unexpected finding:
%increasing df in the spline functions may help with multicollinearity.
%For event-based predictors (5s duration/150 samples), try df=30; for
%position splines (286 cm) try 


clearvars;

subjectID = "m913";

[ dirs, expData, calculate, summarize, figures, mat_file, params ] =...
    getAnalysisParams_T2V( subjectID );

% options.calculate = struct('encoding',true)
idx = find(ismember({expData.sub_dir},{'250212-m913-maze7'}));
% pathname = fullfile(dirs.results,expData(idx).sub_dir,"encodingMdl_cell004.mat");
pathname = fullfile(dirs.results,[expData(idx).sub_dir,'-FM']);
% S = load(mat_file.results.encoding(idx),'cellID','conditionNum',...
%     'corrMatrix','VIF','VIF2','rank','predictorIdx');
S = load(fullfile(pathname,'encoding.mat'),'cellID','conditionNum',...
    'corrMatrix','VIF','VIF2','rank','predictorIdx');
load(fullfile(pathname,'encodingMdl_cell004.mat'), 'mdl'); %Model for individual cell


%% Variance Inflation Factor
%VIF(i) = 1/(1-R_2(i)); from a regression of P(i) as fcn of all other predictors
%Equivalent to diagonal of the inverted correlation matrix
%VIF = diag(inv(S.corrMatrix{4})); %Idx arbitrary if all cells use same model

Tbl = mdl.Variables(:,1:end-1);
varNames = Tbl.Properties.VariableNames;
x = 1:numel(varNames);
% VarDecompTbl = collintest(Tbl)



T = mdl.Formula.Terms; %terms matrix
include = [leftTowers,rightTowers,leftPuffs,rightPuffs];
    idx = [S.predictorIdx.leftTowers,S.predictorIdx.rightTowers,...
        S.predictorIdx.leftPuffs,S.predictorIdx.rightPuffs];
    omittedTerms = T(idx,:); %T after omission of indexed terms
    reducedMdl = removeTerms(mdl,omittedTerms); %Reduced model
    %Calculate condition number for inversion of moment matrix
    varIdx =  reducedMdl.VariableInfo.InModel;
    X  = table2array(reducedMdl.Variables(:,varIdx)); %Last column reserved for Y 
    Xi = X(~isnan(sum(X,2)),:); %Omit nan rows, which are also omitted in regression
    moment = Xi'*Xi; %Moment matrix of regressors; note that X is already z-scored
    reduced.conditionNum = cond(moment); %Condition number
    reduced.rank = rank(moment); %Rank
    reduced.corrMatrix = corrcoef(Xi); 
% end

%Metrics for reduced model
reduced.VIF = diag(inv(corrcoef(Xi)));
varNames = reducedMdl.VariableNames(varIdx);
x=1:numel(varNames);

figure; 
title('Variance Inflation Factors, Reduced Model')
bar(x,reduced.VIF2);
xlabel('Predictors'); ylabel('VIF'); 
set(gca,'XTick',x,'XTickLabel',varNames);
%Returned some large negative values!


%% Figures

%Variance Inflation Factors
figure; 
bar(x,S.VIF);
title('Variance Inflation Factors')
xlabel('Predictors'); ylabel('VIF'); 
set(gca,'XTick',x,'XTickLabel',varNames);

%Correlation Matrices
R = S.corrMatrix;
for cueType = ["leftTowers","rightTowers","leftPuffs","rightPuffs"]
    idx1 = S.predictorIdx.(cueType)-1; %constant term not in R
idx2 = S.predictorIdx.(strjoin([cueType,"_position"],''))-1;
figure('Position',[350,100,600,500]); 
imagesc(R(idx1,idx2));
title(strjoin(["Predictor Correlation Matrix, " cueType],''));
ylabel(strjoin([cueType," event-based (spline) predictors"],''));
xlabel(strjoin([cueType," * position (spline) predictors"],''));
colorbar(gca);
end

%Between cue-event predictors
idx = [S.predictorIdx.leftTowers, S.predictorIdx.rightTowers,...
    S.predictorIdx.leftPuffs, S.predictorIdx.rightPuffs]-1; %constant term not in R
figure('Position',[350,100,600,500]);
imagesc(R(idx,idx));
title("Predictor Correlation Matrix (Cue-Event Predictors)");
ylabel("Predictor index");
xlabel("Predictor index");
xticks([1,22,43,64]+10);
yticks([1,22,43,64]+10);
xticklabels(["leftTowers","rightTowers","leftPuffs","rightPuffs"]);
yticklabels(["leftTowers","rightTowers","leftPuffs","rightPuffs"]);
colorbar(gca);
%First Cue
idx = [S.predictorIdx.firstLeftTower, S.predictorIdx.firstRightTower,...
    S.predictorIdx.firstLeftPuff, S.predictorIdx.firstRightPuff]-1; %constant term not in R
figure('Position',[350,100,600,500]);
img = R(idx,idx); img(logical(eye(size(img)))) = NaN;
imagesc(img);
title("Predictor Correlation Matrix (First-Cue Predictors)");
ylabel("Predictor index");
xlabel("Predictor index");
xticks([1,22,43,64]+10);
yticks([1,22,43,64]+10);
xticklabels(["firstLeftTower","firstRightTower","firstLeftPuff","firstRightPuff"]);
yticklabels(["firstLeftTower","firstRightTower","firstLeftPuff","firstRightPuff"]);
colorbar(gca);

%Cue x position
idx = [S.predictorIdx.leftTowers_position, S.predictorIdx.rightTowers_position,...
    S.predictorIdx.leftPuffs_position, S.predictorIdx.rightPuffs_position]-1; %constant term not in R
figure('Position',[350,100,600,500]);
img = R(idx,idx); img(logical(eye(size(img)))) = NaN;
imagesc(img);
title("Predictor Correlation Matrix (CueType*Position Predictors)");
ylabel("Predictor index");
xlabel("Predictor index");
xticks([1,6,11,16]+2);
yticks([1,6,11,16]+2);
xticklabels(["leftTowers","rightTowers","leftPuffs","rightPuffs"]);
yticklabels(["leftTowers","rightTowers","leftPuffs","rightPuffs"]);
colorbar(gca);

%Between reward-event predictors
idx = [S.predictorIdx.reward]-1; %constant term not in R
figure('Position',[350,100,600,500]);
img = R(idx,idx); img(logical(eye(size(img)))) = NaN;
imagesc(img);
title("Predictor Correlation Matrix (Reward-Event Predictors)");
ylabel("Reward event-related predictor index");
xlabel("Reward event-related predictor index");
colorbar(gca);

%Between reward-event predictors
idx = [S.predictorIdx.reward]-1; %constant term not in R
figure('Position',[350,100,600,500]);
img = R(idx,idx); img(logical(eye(size(img)))) = NaN;
imagesc(img);
title("Predictor Correlation Matrix (Reward-Event Predictors)");
ylabel("Reward event-related predictor index");
xlabel("Reward event-related predictor index");
colorbar(gca);


%%
clearvars("R","mean_R","max_R","min_R");
max_df = 50;
for df = 4:max_df
R{df} = corrcoef(makeBSpline(3,df, 286));
R{df}(R{df}==1)=NaN;

mean_R(df) = mean(abs(R{df}(:)),'omitnan');
max_R(df) = max(R{df}(:));
min_R(df) = min(R{df}(:));
end

figure; 
x=4:max_df;
plot(x,mean_R(x),'DisplayName','mean abs(R)'); hold on
plot(x,max_R(x),'DisplayName','max R'); hold on
plot(x,min_R(x),'DisplayName','min R')
legend();
ylabel('Correlation coef. (R)');
xlabel('Cubic spline, degrees of freedom');

figure;
df = [4,5,10,30,50];
for i=1:numel(df)
ax = subplot(1,numel(df)+1,i);
imagesc(R{df(i)});
clim([-0.8, 0.8]);
title([num2str(df(i)) ' Degrees of Freedom']);
xlabel('Basis function idx');
ylabel('Basis function idx');
axis square;
end

subplot(1,numel(df)+1,numel(df)+1)
axis off
colorbar(ax,'east');
ylabel('Correlation coef. (R)')

%figure; plot(encodingMdl.bSpline_pos)