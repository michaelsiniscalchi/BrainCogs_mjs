function figs = fig_longitudinal_licking( subjects, vars, params )

setup_figprops('placeholder'); %Customize for performance plots
figs = gobjects(0);

%Plotting params
shadeOffset = 0.5;
transparency = 0.2;
lineWidth = params.lineWidth;
colors = params.colors;

%Colors
colors.normLicksTactileCS = colors.taskRule.tactileCS;
colors.normLicksVisualCS = colors.taskRule.visualCS; 
colors.normLicksLeftCS  = colors.taskRule.leftCS; 
colors.normLicksRightCS = colors.taskRule.rightCS; 

colors.meanLicksTactileCS = colors.taskRule.tactileCS;
colors.meanLicksVisualCS = colors.taskRule.visualCS; 
colors.meanLicksLeftCS  = colors.taskRule.leftCS; 
colors.meanLicksRightCS = colors.taskRule.rightCS; 

colors.normLicksCSPlus  = colors.green; 
colors.normLicksCSMinus = colors.pink; 

%Performance as a function of training day
for i = 1:numel(subjects)
       
    figs(i) = figure(...
        'Name',join([subjects(i).ID, params.figName],'_'));
       tiledlayout(1,1);
    ax = nexttile();
    hold on;

    % Shade according to different phases of training
    %Omit shaping levels (and anything other than visual/tactile)
    csNames = ["tactileCS","visualCS","leftCS","rightCS"];
    pltIdx = ismember([subjects(i).sessions.taskRule],...
            csNames) & [subjects(i).sessions.session_date]>=datetime('23-Apr-2026'); %first date with good lick detection
    sessions = ...
            subjects(i).sessions(pltIdx);
    trialData = ...
            subjects(i).trialData(pltIdx);


    taskRule = [sessions.taskRule];
    rules = unique(taskRule,'stable');
    shading = gobjects(0);
    for j = 1:numel(rules)
        patches = shadeDomain(find(taskRule==rules(j)),...
            ylim, shadeOffset, colors.taskRule.(rules(j)), transparency);
        shading(numel(shading)+(1:numel(patches))) = patches;
    end

    X = 1:numel(sessions);
   
    % plot([0, X(end)+1],[1, 1],... %Reference for nLicksCue==nLicksReward
    %     ':k','LineWidth',1);

     for j = 1:numel(vars)
         p(j) = plot(X, [sessions.(vars(j))],...
            'o','MarkerSize',params.markerSize,...
            'Color',colors.(vars(j)),...
            'MarkerFaceColor',colors.(vars(j)),...
            'LineWidth',lineWidth,'LineStyle','-',...
            'DisplayName', params.displayNames(j)); hold on
     end

     lgd = legend(p,'Location','eastoutside','Interpreter','none');

       %Labels and titles
       ylabel('Mean lick count');
       xlabel('Session number');

    title({subjects(i).ID; ''},'interpreter','none'); %Extra text line below title

    %Add labels for maze-type/rule
    typeLabels = unique(taskRule,'stable');
    txtX = arrayfun(@(idx) find(taskRule==typeLabels(idx),1,'first'), 1:numel(typeLabels));
    %     txtY = min(ylim)+(1:numel(typeLabels)).*0.05*(max(ylim)-min(ylim));
    txtY = max(ylim)-0.05*(max(ylim)-min(ylim));
    %     yyaxis left;
    txt = gobjects(numel(typeLabels),1);
    for j = 1:numel(typeLabels)
        txt(j) = text(txtX(j),txtY,strjoin([typeLabels(j),"+"],''),...
            'Color',colors.taskRule.(typeLabels(j)),...
            'HorizontalAlignment','left');
    end
    txt(end).HorizontalAlignment='left';
    txt(end).Position(1) = find(taskRule==typeLabels(end),1,'first');

    %Adjust height of shading as necessary
    newVert = [max([ax.YAxis.Limits]),max([ax.YAxis.Limits]),min([ax.YAxis.Limits]),min([ax.YAxis.Limits])]; %Might need ax.YAxis(i).Limits...
    for j = 1:numel(shading)
        shading(j).Vertices(:,2) = newVert;
    end
    clearvars shading

    %Axes scale
    ax.PlotBoxAspectRatio = [4,2,1];
    xlim([find(ismember(taskRule,csNames),1,'first')-shadeOffset,...
        find(ismember(taskRule,csNames),1,'last')+shadeOffset]);

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