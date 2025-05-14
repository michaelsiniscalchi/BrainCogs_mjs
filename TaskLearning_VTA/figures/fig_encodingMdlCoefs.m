%Plot regression coefficients for all predictor variables in model

function figs = fig_encodingMdlCoefs( glm, mdl, expID, cellIDs, cellIdx, predictorNames,colors )

% Set up figure properties
setup_figprops('timeseries')  %placeholder
lineWidth = 2;
markerSize = 3;

% predNames = fieldnames(glm.predictorIdx);
kernelNames = string(fieldnames(glm.kernel));

%Raw bSpline coefficients
figs(1) = figure('Name',[expID,'-all coeffs-','-cell', cellIDs{cellIdx}], 'Position', [300,300,1000,500]);
offset=0; %offset from raw index
iOffset = 10; %increment to adjust offset

%Plot all regression coefficients, grouped by predictor class
nDataPoints = numel(mdl.Coefficients.Estimate)-1;
nGroups = numel(predictorNames);
plotBaseline(0:nDataPoints+iOffset*(nGroups-1)); %Plot baseline at B=0 
for i = 1:numel(predictorNames)
    idx = glm.predictorIdx.(predictorNames{i}); %Predictor index in results table 
    estimate = mdl.Coefficients.Estimate(glm.predictorIdx.(predictorNames{i})); %Coeffs
    se = mdl.Coefficients.SE(glm.predictorIdx.(predictorNames{i})); %SE of coeffs
    X = offset + idx - min(idx); %Plot domain
    C = colors.(predictorNames{i}); %Color
    
    plot(X, estimate, 'Color', C, 'MarkerFaceColor', C, ...
        'Marker', 'o','MarkerSize', markerSize,...
        'LineWidth', lineWidth, 'LineStyle', 'none'); hold on;
    errorbar(X, estimate, se, 'Color', C, 'LineWidth', lineWidth, 'LineStyle', 'none', 'CapSize', 0);
    txtX(i) = mean(X); %For XTick
    
    offset = offset + numel(idx) + iOffset; 
end
title('Encoding Model Coefficients')
ax(1) = gca;
set(ax(1),'XTick',txtX,'XTickLabel',predictorNames);
ax(1).YLabel.String = 'Regression coefficient';
axis tight; box off

%AUC of each kernel
figs(2) = figure('Name',[expID,'-kernel AUC-','-cell', cellIDs{cellIdx}], 'Position', [300,300,1000,500]);
pNames = predictorNames(ismember(predictorNames, kernelNames));
pNames  = pNames(pNames~="start");
kernel = glm.kernel(cellIdx);

plotBaseline(0:numel(pNames)+1); %Plot baseline at AUC=0 
for i = 1:numel(pNames)
    auc = kernel.(pNames(i)).AUC; %Peak of response kernel
    se = kernel.(pNames(i)).AUC_se; %SE at peak 
    X = i;
    C = colors.(pNames{i}); %Color
    plot(X, auc, 'Color', C, 'MarkerFaceColor', C, ...
        'Marker', 'o','MarkerSize', markerSize,...
        'LineWidth', lineWidth, 'LineStyle', 'none'); hold on;
    errorbar(X, auc, se, 'Color', C, 'LineWidth', lineWidth, 'LineStyle', 'none', 'CapSize', 0);
end
title('AUC of Response Kernel Estimate')
ax(2) = gca;
set(ax(2),'XTick',1:numel(pNames),'XLim',[0.5,numel(pNames)+0.5],'XTickLabel',pNames);
ax(2).YLabel.String = 'Area under curve (std. dF/F * s)';
axis square tight; box off

%Peak of each kernel
figs(3) = figure('Name',[expID,'-kernel peak-','-cell', cellIDs{cellIdx}], 'Position', [300,300,1000,500]);
plotBaseline(0:numel(pNames)+1); %Plot baseline at AUC=0 
for i = 1:numel(pNames)
    peak = kernel.(pNames(i)).peak; %Peak of response kernel
    se = kernel.(pNames(i)).peak_se; %SE at peak 
    X = i;
    C = colors.(pNames{i}); %Color
    plot(X, peak, 'Color', C, 'MarkerFaceColor', C, ...
        'Marker', 'o','MarkerSize', markerSize,...
        'LineWidth', lineWidth, 'LineStyle', 'none'); hold on;
    errorbar(X, peak, se, 'Color', C, 'LineWidth', lineWidth, 'LineStyle', 'none', 'CapSize', 0);
end
title('Peak of Response Kernel Estimate')
ax(3) = gca;
set(ax(3),'XTick',1:numel(pNames),'XLim',[0.5,numel(pNames)+0.5],'XTickLabel',pNames);
ax(3).YLabel.String = 'Peak value (std. dF/F)';
axis square tight; box off

%Kinematic coefficients separately
figs(4) = figure('Name',[expID,'-kinematic coeffs-','-cell', cellIDs{cellIdx}], 'Position', [300,300,1000,500]);
pNames = predictorNames(~ismember(predictorNames, kernelNames));
plotBaseline(0:numel(pNames)+1); %Plot baseline at B=0 
for i = 1:numel(pNames)
    
    estimate = mdl.Coefficients.Estimate(glm.predictorIdx.(pNames{i})); %Coeffs
    se = mdl.Coefficients.SE(glm.predictorIdx.(pNames{i})); %SE of coeffs
    X = i;
    C = colors.(pNames{i}); %Color
    
    plot(X, estimate, 'Color', C, 'MarkerFaceColor', C, ...
        'Marker', 'o','MarkerSize', markerSize,...
        'LineWidth', lineWidth, 'LineStyle', 'none'); hold on;
    errorbar(X, estimate, se, 'Color', C, 'LineWidth', lineWidth, 'LineStyle', 'none', 'CapSize', 0);

end
title('Kinematic Coefficients')
ax(4) = gca;
set(ax(4),'XTick',1:numel(pNames),'XLim',[0.5,numel(pNames)+0.5],'XTickLabel',pNames);
ax(4).YLabel.String = 'Regression coefficient';
axis square tight; box off

%Standardize axes for event-related and kinematic variables
ylims = [min([ax([1,3,4]).YLim]), max([ax([1,3,4]).YLim])];
[ax([1,3,4]).YLim] = deal(ylims);

function plotBaseline(X)
%Plot baseline at B=0  
% X = 0:size(mdl.Coefficients.Estimate,1); %0:nRegressors + 1 (1 Estimate assigned to bias term)
Y = zeros(size(X)); 
plot(X,Y,'k','LineWidth', 1, 'LineStyle', '-'); hold on;

%===================================================================================================

% DEVO
% %Get indices of each spline basis function
% temp = string(cellfun(@(P) regexp(P,'[a-zA-Z]+','match'),...
%         predNames,'UniformOutput', false)); %Drop the numeric suffixes to find common spline names
% for i = 1:numel(kernelNames) %Index each spline function
%     splineIdxs.(kernelNames(i)) = ismember(temp,kernelNames(i));
% end
