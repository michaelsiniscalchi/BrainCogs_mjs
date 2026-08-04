function fig = fig_summary_performance( subjectID, sessions, vars, params )

%Plotting params
setup_figprops('placeholder'); %Customize for performance plots
shadeOffset = 0.5;
transparency = 0.2;
lineWidth = 2;
colors = setPlotColors('mjs_tactile2visual');

% Plot Performance as a function of Training Day
if isfield(params, 'sessionDate') && ~isempty(params.sessionDate)
    fig = figure(...
        'Name',join([subjectID, string(vars),...
        string(datetime(params.sessionDate,"Format","yyMMdd"))],'-'));
else
    fig = figure(...
        'Name',join([subjectID, string(vars)],'-'));
end
if ~params.omitShaping
    fig.Name = join([fig.Name, "+shaping"], '');
end

tiledlayout(1,1);
ax = nexttile();
hold on;

% Shade according to rule
taskRule = [sessions.taskRule];
rules = unique(taskRule,'stable');
shading = gobjects(0);
for j = 1:numel(rules)
    patches = shadeDomain(find(taskRule==rules(j)),...
        ylim, shadeOffset, colors.taskRule.(rules(j)), transparency);
    shading(numel(shading)+(1:numel(patches))) = patches;
end

%Line at 0.5 and 0.7 (criterion)
X = 1:numel(sessions);
plot([0,X(end)+1],[0.5, 0.7; 0.5, 0.7],...
    ':k','LineWidth',1);
%Overall mean for congruent & conflict plots
if ismember(vars,{'maxmeanAccuracy_congruent','maxmeanAccuracy_conflict'})
    p(2) = plot(X, [sessions.maxmeanAccuracy],...
        'Color',colors.data);
    varNames = ["Congruent","Conflict"];
elseif any(ismember(vars,{'pCorrect_congruent','pCorrect_conflict'}))
    p(2) = plot(X, [sessions.pCorrect],...
        'Color',colors.data);
    varNames = ["Congruent","Conflict"];
end

for j = 1:numel(vars)
    p(j) = plot(X, [sessions.(vars{j})],...
        'o','MarkerSize',params.markerSize,...
        'Color',colors.(vars{j}),...
        'MarkerFaceColor',colors.(vars{j}),...
        'LineWidth',lineWidth,'LineStyle','none','DisplayName',varNames(j));

    switch vars{j}
        case 'pCorrect'
            ylabel('Accuracy');
            ylim([0, 1]);
        case {'pCorrect_conflict','pCorrect_congruent'}
            ylabel('Accuracy');

            ylim([0, 1]);
        case {'maxCorrectMoving','maxCorrectMoving_congruent','maxCorrectMoving_conflict'}
            ylabel('Max. Accuracy');

            ylim([0, 1]);
        case 'bias'
            color = p(j).Color; %Store color and data to use for scatter
            yData = p(j).YData;
            p(j).YData = nan(size(yData));
            p(j) = scatter(X(yData<0),abs(yData(yData<0)),...
                '<','MarkerFaceColor','none','MarkerEdgeColor',color);
            scatter(X(yData>0),yData(yData>0),...
                '>','MarkerFaceColor','none','MarkerEdgeColor',color);
            ylabel('Bias or Proportion of trials');
            ylim([0, 1]);
    end
end

%Mark imaging sessions
imgIdx = find([sessions.isImgSession]);
if isfield(params, 'sessionDate') && ~isempty(params.sessionDate)
    imgIdx = find([sessions.session_date]==params.sessionDate);
end
symbolY = max(ylim)-0.05*range(ylim);
for i=1:numel(imgIdx)
    plot(imgIdx(i),symbolY,'v',"Color",colors.green2,"MarkerFaceColor",colors.green2,"MarkerSize",params.markerSize);
end

%Legend
lgd = legend(p);
lgd.Location = "eastoutside";
lgd.Interpreter='none';

%Axes scale
ax.PlotBoxAspectRatio = [3,2,1];
xlim([0, max(X)+1]);
if max(ylim)>1
    idx = str2double(yticklabels)>1;
    [ax.YTickLabel{idx}] = deal('');
end

%Labels and titles
xlabel('Session number');

%Add labels for maze-type/rule
typeLabels = unique(taskRule,'stable');
offsetX = 0.01*range(xlim);
txtX = arrayfun(@(idx) find(taskRule==typeLabels(idx),1,'first')+offsetX, 1:numel(typeLabels));
txtY = min(ylim)+0.05*(max(ylim)-min(ylim));
txt = gobjects(numel(typeLabels),1);
for j = 1:numel(typeLabels)
    txt(j) = text(txtX(j),txtY,typeLabels(j),...
        'Color',colors.taskRule.(typeLabels(j)),...
        'HorizontalAlignment','left');
end
txt(end).HorizontalAlignment='left';
txt(end).Position(1) = find(taskRule==typeLabels(end),1,'first');

%Adjust height of shading as necessary
% newVert = [max([ax.YAxis.Limits]),max([ax.YAxis.Limits]),min([ax.YAxis.Limits]),min([ax.YAxis.Limits])]; %Might need ax.YAxis(i).Limits...
for j = 1:numel(shading)
    % shading(j).Vertices(:,2) = newVert;
    shading(j).Vertices(:,2) = [1,1,0,0];
end
clearvars shading
end %End main fcn

function p = shadeDomain( xVals, yLims, shadeOffset, color, transparency )

if isempty(xVals)
    return
end

%Find start and end of each block
startVal = xVals(logical([1, diff(xVals)-1]));
endVal = xVals(logical([diff(xVals)-1, 1]));

%Color patchs
for i = 1:numel(startVal)
    X = [startVal(i)-shadeOffset, endVal(i)+shadeOffset];
    X = [X, fliplr(X)];
    Y = [yLims(2),yLims(2),yLims(1),yLims(1)];
    p(i) = patch(X, Y, color,'EdgeColor','none',...
        'FaceAlpha',transparency);
end

end