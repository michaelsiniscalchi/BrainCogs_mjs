function figs = fig_longitudinal_performance( subjects, vars, params )

setup_figprops('placeholder'); %Customize for performance plots
figs = gobjects(0);

%Plotting params
shadeOffset = 0.5;
transparency = 0.2;
lineWidth = params.lineWidth;
colors = params.colors;

% Plot Performance as a function of Training Day
% one panel for each subject

%Load performance data
prefix = 'Performance';

for i = 1:numel(subjects)
    %Performance as a function of training day
    figs(i) = figure(...
        'Name',join([prefix, subjects(i).ID, string(vars)],'_'));
    tiledlayout(1,1);
    ax = nexttile();
    hold on;

    % Shade according to different phases of training
    %Omit shaping levels (and anything other than visual/tactile)
    if params.omitShaping
        subjects(i).sessions = subjects(i).sessions(ismember([subjects(i).sessions.taskRule],["visual","tactile"]));
    end

    taskRule = [subjects(i).sessions.taskRule];
    rules = unique(taskRule,'stable');
    shading = gobjects(0);
    for j = 1:numel(rules)
        patches = shadeDomain(find(taskRule==rules(j)),...
            ylim, shadeOffset, colors.taskRule.(rules(j)), transparency);
        shading(numel(shading)+(1:numel(patches))) = patches;
    end

    %Line at 0.5 for proportional quantities
    allProportional = all(ismember(vars,...
        {'pCorrect','pCorrect_congruent','pCorrect_conflict','pOmit',...
        'pLeftTowers','pLeftPuffs','pLeftCues'...
        'maxmeanAccuracy','maxmeanAccuracy_congruent','maxmeanAccuracy_conflict','bias'}));
    X = 1:numel(subjects(i).sessions);
    if allProportional
        plot([0,X(end)+1],[0.5, 0.5; 0.2, 0.2; 0.7, 0.7],...
            ':k','LineWidth',1);
        %Overall mean for congruent & conflict plots
        if ismember(vars,{'maxmeanAccuracy_congruent','maxmeanAccuracy_conflict'}) 
            p(3) = plot(X, [subjects(i).sessions.maxmeanAccuracy],...
                'Color',[0.8,0.8,0.8],'LineWidth',3);
        elseif any(ismember(vars,{'pCorrect_congruent','pCorrect_conflict'})) 
            p(3) = plot(X, [subjects(i).sessions.pCorrect],...
                'Color',[0.8,0.8,0.8],'LineWidth',3);
        end
    end

    yyax = {'left','right'};
    for j = 1:numel(vars)
        %Dual Y-axes
        if numel(vars)>1 && ~allProportional
            yyaxis(ax,yyax{j});
            ax.YAxis(j).Color = colors.(vars{j});
        end

        p(j) = plot(X, [subjects(i).sessions.(vars{j})],...
            'o','MarkerSize',params.markerSize,...
            'Color',colors.(vars{j}),...
            'MarkerFaceColor',colors.(vars{j}),...
            'LineWidth',lineWidth,'LineStyle','none');

        marker = {'o','o','_'};
        %         faceColor = {colors.(vars{j}),'none','none'};
        faceColor = {colors.(vars{j}),'none','none'};
        if j>1 && isequal(colors.(vars{j}),colors.(vars{j-1}))
            set(p(j),'Marker',marker{j},...
                'MarkerSize',params.markerSize,...
                'MarkerFaceColor',faceColor{j},...
                'LineWidth',lineWidth);
        end

        switch vars{j}
            case 'pCorrect'
                ylabel('Accuracy');
                ylim([0, 1]);
            case {'pCorrect_conflict','pCorrect_congruent'}
                %Only applies to Sensory and Alternation Sessions
                p(j).YData(taskRule=="forcedChoice") = NaN;
                ylabel('Accuracy');
                ylim([0, 1]);
            case {'maxCorrectMoving','maxCorrectMoving_congruent','maxCorrectMoving_conflict'}
                %Only applies to Sensory and Alternation Sessions
                p(j).YData(taskRule=="forcedChoice") = NaN;
                ylabel('Max. Accuracy');
                ylim([0, 1]);
            case {'pOmit','pConflict','pStuck','pLeftTowers','pLeftPuffs','pLeftCues'}
                ylabel('Proportion of trials');
                ylim([0, 1]);
            case 'mean_velocity'
                ylabel('Mean velocity (cm/s)');
            case 'mean_stuckTime'
                ylabel('Proportion of time spent stuck');
                ylim([0, 1]);
            case 'mean_pSkid'
                ylabel('Proportion of maze spent skidding');
                ylim([0, 1]);
            case 'nCompleted'
                ylabel('Number of completed trials');
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

        %If final plot, make legend
        if j==numel(vars)
            if isequal(vars,{'pCorrect','pCorrect_conflict'})
                lgd = legend(p,{'All','Conflict'},'Location','best','Interpreter','none');
            elseif isequal(vars,{'pCorrect_congruent','pCorrect_conflict'})
                lgd = legend(p,{'Congruent','Conflict'},'Location','best','box','off','Interpreter','none');
            elseif isequal(vars,{'maxCorrectMoving_congruent','maxCorrectMoving_conflict'})
                lgd = legend(p,{'Congruent','Conflict','All'},'Location','best','Interpreter','none');
            else
                legendVars = cellfun(@(C) ~all(isnan([subjects(i).sessions.(C)])), vars);
                lgd = legend(p, vars{legendVars},'Location','best','Interpreter','none');
            end
        end
    end

    %Cutoff L-maze data
    zoom2TMaze = false; %Cutoff L-maze data
    if all(ismember(vars,{'pCorrect','pCorrect_conflict','pCorrect_congruent',...
            'maxCorrectMoving','maxCorrectMoving_congruent','maxCorrectMoving_conflict'}))
        zoom2TMaze = true;
        taskRule(taskRule=="forcedChoice") = "";
    end

    %Axes scale
    ax.PlotBoxAspectRatio = [3,2,1];
    xlim([0, max(X)+1]);
    if zoom2TMaze
        if taskRule=="", continue %No T-maze sessions
        else
            xlim([find(ismember(taskRule,["visual","tactile","sensory","alternation"]),1,'first')-shadeOffset,...
                max(xlim)]);
        end
    end

    %Labels and titles
    xlabel('Session number');

    title({subjects(i).ID; ''},'interpreter','none'); %Extra text line below title

    %Add labels for maze-type/rule
    typeLabels = unique(taskRule,'stable');
    txtX = arrayfun(@(idx) find(taskRule==typeLabels(idx),1,'first'), 1:numel(typeLabels));
    %     txtY = min(ylim)+(1:numel(typeLabels)).*0.05*(max(ylim)-min(ylim));
    txtY = min(ylim)+0.05*(max(ylim)-min(ylim));
    %     yyaxis left;
    txt = gobjects(numel(typeLabels),1);
    for j = 1:numel(typeLabels)
        txt(j) = text(txtX(j),txtY,typeLabels(j),...
            'Color',colors.taskRule.(typeLabels(j)),...
            'HorizontalAlignment','left');
    end
    txt(end).HorizontalAlignment='left';
    %     txt(end).Position(1) = find(taskRule==typeLabels(end),1,'first');
    txt(end).Position(1) = find(taskRule==typeLabels(end),1,'first');

    %Adjust height of shading as necessary
    newVert = [max([ax.YAxis.Limits]),max([ax.YAxis.Limits]),min([ax.YAxis.Limits]),min([ax.YAxis.Limits])]; %Might need ax.YAxis(i).Limits...
    for j = 1:numel(shading)
        shading(j).Vertices(:,2) = newVert;
    end
    clearvars shading
end
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