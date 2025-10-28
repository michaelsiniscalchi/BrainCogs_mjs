function figs = fig_encodingMdlCV(glm, mdl, cellID, colors)

% Set up figure properties
setup_figprops('timeseries')  %placeholder

%Figure: Ridge Trace, VIF Trace, Condition Num co-plotted with CV_err
figs = figure('Name',[glm.sessionID, '-', glm.modelName, '-cell', cellID],...
    'Position',[25,100,1200,600]);

T = tiledlayout(2,3,"TileSpacing","tight","Padding","loose");

%Panel 1: Ridge trace
ax = nexttile();
%Plot ridge trace with log-scaled X
X = log10(glm.lambda);
Xk = repmat(log10(mdl.Lambda),1,2);
y = mdl.CV.ridgeTrace;
p = plot(X, y); hold on;
%Assign colors/linestyles
p = assignLineFormatting(p, glm.predictorIdx, colors);
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
p = assignLineFormatting(p, glm.predictorIdx, colors);
%Plot fitted lambda for this cell
Yk = [min(y(:))-0.05*range(y(:)), max(y(:))+0.05*range(y(:))];
plot(Xk,Yk,'k:','LineWidth',1);
%Labels & axis formatting
title('VIF Trace');
ylabel('Variance inflation factor (adj.)');
xlabel('Ridge parameter, log(k)');
% xscale('log');
axis square tight

%Co-plot CV error and condition number
nexttile()
%Plot CV MSE and Cond. Number traces
colororder([colors.black;colors.red]);
yyaxis right
plot(X, glm.conditionNum_trace,'DisplayName','Condition Num. (adj.)');
ylabel('Condition number (adj.)');
yyaxis left
plot(X, mdl.CV.cvLambda, 'DisplayName','CV-MSE'); hold on;
ylabel('CV-MSE');
%Plot fitted lambda for this cell
y = mdl.CV.cvLambda;
Yk = [min(y(:))-0.05*range(y(:)), max(y(:))+0.05*range(y(:))];
plot(Xk,Yk,'k:','LineWidth',1);
%Labels & axis formatting
title('CV(lambda)');
ylabel('Cross validation MSE');
xlabel('Ridge parameter, log(k)');
% xscale('log');
axis square tight

%Legend
ax = nexttile();
ax.Visible = "off";
leg = makeLegend(p, glm.predictorIdx);
leg.Layout.Tile = 4;
leg.NumColumns = 2;

%--------------------------------------------------------------------------
function lineSeries = assignLineFormatting(lineSeries, pIdx, C)

%Default colors/lineStyles and then amend as necessary
for f = string(fieldnames(pIdx))'
    color = C.(f);
    lineStyle = '-';
    if regexp(f,'_position')
        lineStyle = ':';
    end
    [lineSeries(pIdx.(f)-1).Color] = deal(color);
    [lineSeries(pIdx.(f)-1).LineStyle] = deal(lineStyle);
end
[lineSeries.LineWidth] = deal(1);

function leg = makeLegend(lineSeries, pIdx)
f = string(fieldnames(pIdx));
for i = 1:numel(f)
    subset(i) = pIdx.(f(i))(1)-1; %first instance of each predictor type
    labels(i) = f(i);
end
leg = legend(lineSeries(subset), labels,...
    'Location', 'bestoutside','FontSize', 10, 'Interpreter','none');