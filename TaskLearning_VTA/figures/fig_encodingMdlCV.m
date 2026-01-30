function figs = fig_encodingMdlCV(glm, mdl, cellID, colors)

% Set up figure properties
setup_figprops('timeseries')  %placeholder

%Figure: Ridge Trace, VIF Trace, Condition Num co-plotted with CV_err
figs = figure('Name',[glm.sessionID, '-', char(glm.modelName), '-cell', cellID],...
    'Position',[25,100,1000,750]);

T = tiledlayout(2,3,"TileSpacing","loose","Padding","loose");

%Panel 1: Ridge trace
ax = nexttile();
%Plot ridge trace with log-scaled X
X = log10(glm.lambda);
Xk = repmat(log10(mdl.Lambda),1,2);
y = mdl.CV.ridgeTrace;
p = plot(X, y); hold on;
%Assign colors/linestyles
p = assignLineFormatting(p, glm.termIdx, colors);
%Plot fitted lambda for this cell
Yk = [min(y(:))-0.05*range(y(:)), max(y(:))+0.05*range(y(:))]; %Y-position of dotted line for lambda
plot(Xk,Yk,'k:','LineWidth',1);
% xticks(logspace(-3,6,10));

%Labels & axis formatting
title(['Ridge Trace (Cell ', cellID,')']);
ylabel('Ridge coef. (dF/f)');
xlabel('Ridge parameter, log(k)');
% xscale('log');
axis square tight

nexttile()
%Plot VIF trace
y = glm.VIF_trace;
p = plot(X, y); hold on;
%Assign colors/linestyles
p = assignLineFormatting(p, glm.termIdx, colors);
%Plot fitted lambda for this cell
Yk = [min(y(:))-0.05*range(y(:)), max(y(:))+0.05*range(y(:))];
plot(Xk,Yk,'k:','LineWidth',1);
%Labels & axis formatting
title('VIF Trace');
ylabel('Variance inflation factor (adj.)');
xlabel('Ridge parameter, log(k)');
% xscale('log');
axis square tight

%Legend
ax = nexttile();
ax.Visible = "off";
leg = makeLegend(p, glm.termIdx);
leg.Layout.Tile = 3;
leg.NumColumns = 2;

%Variance Inflation Factors
nexttile([1,2])
varNames = string(fieldnames(glm.termIdx));
for i=1:numel(varNames)
    firstBasisIdx(i) = glm.termIdx.(varNames(i))(1);
end
x = 1:numel(glm.VIF);%+1 for whitespace at 
bar(x, glm.VIF,'w'); hold on;
plot([0,x(end)+1], [5,5], ':k'); %Threshold VIF: ~R2 = 0.80
title('Variance Inflation Factors')
xlabel('Predictors'); ylabel('VIF'); 
set(gca,'XTick',firstBasisIdx,...
    'XTickLabel',varNames,'TickLabelInterpreter','none'); 
txtX = max(xlim)-0.05*max(xlim); txtY = max(ylim)-0.1*max(ylim);
text(txtX,txtY,['Condition number: ', num2str(glm.conditionNum,3)],...
    'HorizontalAlignment','right','Interpreter','latex');
txtY = max(ylim)-0.2*max(ylim);
text(txtX,txtY,['$R^{2}$: ', num2str(mdl.Rsquared,3)],...
    'HorizontalAlignment','right','Interpreter','latex');
%--------------------------------------------------------------------------
function lineSeries = assignLineFormatting(lineSeries, pIdx, C)

%Default colors/lineStyles and then amend as necessary
for f = string(fieldnames(pIdx))'
    color = C.(f);
    lineStyle = '-';
    if regexp(f,'_position')
        lineStyle = ':';
    elseif f=="B0"
        lineStyle = '--';
   
    end
    [lineSeries(pIdx.(f)).Color] = deal(color);
    [lineSeries(pIdx.(f)).LineStyle] = deal(lineStyle);
end
[lineSeries.LineWidth] = deal(1);

function leg = makeLegend(lineSeries, pIdx)
f = string(fieldnames(pIdx));
for i = 1:numel(f)
    subset(i) = pIdx.(f(i))(1); %first instance of each predictor type
    labels(i) = f(i);
end
leg = legend(lineSeries(subset), labels,...
    'Location', 'bestoutside','FontSize', 10, 'Interpreter','none');

% %Co-plot CV error and condition number
% nexttile()
% %Plot CV MSE trace
% colororder([colors.black;colors.red]);
% plot(X, mdl.CV.cvLambda, 'DisplayName','CV-MSE'); hold on;
% %Plot fitted lambda for this cell
% y = mdl.CV.cvLambda;
% Yk = [min(y(:))-0.05*range(y(:)), max(y(:))+0.05*range(y(:))];
% plot(Xk,Yk,'k:','LineWidth',1);
% %Labels & axis formatting
% title('CV(lambda)');
% ylabel('Cross validation MSE');
% xlabel('Ridge parameter, log(k)');
% % xscale('log');
% axis square tight