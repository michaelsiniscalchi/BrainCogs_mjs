function figs = fig_longitudinal_glm( subjects, vars_cell, glmName, colors )

% vars = struct('pCorrect',false,'pOmit',false,'mean_velocity',false);
for i = 1:numel(vars_cell)
    vars{i} = vars_cell{i};
end
% predictorNames = {'towerSide','puffSide','priorRewChoice','priorRewChoice','priorUnrewChoice','bias'}; %Predictors vs parameters, etc

setup_figprops('placeholder'); %Customize for performance plots
figs = gobjects(0);

%Plotting params
lineWidth = 1;
shadeOffset = 0.3;
transparency = 0.1;

% Plot Performance as a function of Training Day
% one panel for each subject

%Load performance data
for i = 1:numel(subjects)
    
    sessions = subjects(i).sessions;
    
    figs(i) = figure(...
        'Name',join([glmName, subjects(i).ID, string(vars)],'_'));
    tiledlayout(1,1);
    ax = nexttile();
    hold on;
    
    % Shade according to different phases of training
    sessions = sessions([sessions.taskRule]~="forcedChoice"); %Exclude L-maze data
    sessionType = [sessions.taskRule];

    levels = cellfun(@(L) L(end),{sessions.level});
    levels(sessionType=="alternation")=98; %**TEMPORARY for mixed Alt/Tactile/Vis cohort
    levels(sessionType=="visual" & levels==6)=99; %**TEMPORARY for mixed Alt/Tactile/Vis cohort
    values = unique(levels);
    shading = gobjects(0);
    for j = 1:numel(values)
        sameType = unique(sessionType(levels==values(j)));
        pastLevels = levels>=values(j) & sessionType==sameType;% Sessions at each level
        alpha = transparency;
        if unique(levels(sessionType==sameType))==values(j)
        	alpha = 2*transparency;
        end
        patches = shadeDomain(find(pastLevels),...
            ylim, shadeOffset, colors.taskRule.(sameType), alpha);
        shading(numel(shading)+(1:numel(patches))) = patches; 
    end
    
    %Performance as a function of training day
    X = find(~cellfun(@isempty,{sessions.(glmName)}));
    predictorNames = sessions(end).(glmName).predictors;
    for j = 1:numel(vars)
        %Extract data
        if ismember(vars{j}, predictorNames)
            data{j} = arrayfun(@(sessionIdx) sessions(sessionIdx).(glmName).(vars{j}).beta, X)';
            se = arrayfun(@(sessionIdx) sessions(sessionIdx).(glmName).(vars{j}).se, X,'UniformOutput',false);
        else
            data{j} = arrayfun(@(sessionIdx) sessions(sessionIdx).(glmName).(vars{j}), X);
        end
       
        if numel(vars)>1 && any(ismember(vars,{'N','conditionNum'}))
            if j==1
                yyaxis left
            else
                yyaxis right
            end
            ax.YAxis(j).Color = colors.(vars{j});
        else
            %Axes scale
            xlim([0, max(X)+1]);
            rng = max(cellfun(@max,data))-min(cellfun(@min,data));
            ylim([min(cellfun(@min,data)),max(cellfun(@max,data))] + 0.1*rng*[-1,1]);
        end
        

        %Plot baseline
        plot(X,zeros(size(X)), ':k', 'LineWidth', lineWidth);
        
        %Plot predictor coefficients, etc.
        if ismember(vars{j}, predictorNames)
            for k = 1:numel(X)
                plot([X(k),X(k)],se{k},'color',colors.predictor.(vars{j}),'LineWidth',lineWidth);
            end
        end
        
        %Title and Labels
        title(subjects(i).ID,'interpreter','none');
        xlabel('Session number');
        if j==1
            switch vars{j}
                case 'N'
                    ylabel('Number of trials');
                case 'conditionNum'
                    ylabel('Condition number for X''X');
                case  {'R_predictors', 'R_cue_choice', 'R_priorChoice_choice'}
                    plot([0,numel(X)+1],[0, 0],'k:','LineWidth',1);   %Zero line
                    ylabel('Correlation Coef.');
                case {'pRightCue','pRightChoice'}
                    plot([0,numel(X)+1],[0.5, 0.5],'k:','LineWidth',1);   %0.5 line
                    ylabel('Proportion of trials');
                case predictorNames
                    plot([0,numel(X)+1],[0, 0],'k:','LineWidth',1);   %Zero line
                    ylabel('Regression Coef.');
            end
        end
        p(j) = plot(X, data{j},'.','MarkerSize',20,'Color',colors.predictor.(vars{j}),...
            'LineWidth',lineWidth,'LineStyle','none');
    end
     
    %Simplify markers/colors for >2 vars
    symbols = repmat("o",1,numel(vars)); %initialize
    for j = 1:numel(vars)
        faceColor{j} = colors.predictor.(vars{j}); %#ok<AGROW> 
        switch vars{j}
            case {'nTowersLeft','nTowersRight','towers'} 
            case {'nPuffsLeft','nPuffsRight','puffs'} 
                faceColor{j} = 'none'; %#ok<AGROW> 
            case 'priorChoice'
                symbols(j) = "<";
            case 'bias'
                symbols(j) = "_";
        end
    end
    
    for j = 1:numel(vars)
        set(p(j),'Marker',symbols(j),'MarkerSize',8,'LineWidth',lineWidth);
        p(j).MarkerFaceColor = faceColor{j};
    end

    %Axes scale
    ax.PlotBoxAspectRatio = [3,2,1];
    if ismember(vars{j},...
            {'pRightChoice','pRightCue'})
        ylim([0,1]);
    elseif ismember(vars{j},{'R_predictors', 'R_cue_choice', 'R_priorChoice_choice'})
        ylim([-1, 1]);
    elseif ismember(vars{j}, predictorNames)
        ylim([-5, 5]);
    else
        rng = max(cellfun(@max,data))-min(cellfun(@min,data));
        ylim([min(cellfun(@min,data)),max(cellfun(@max,data))] + 0.1*rng*[-1,1]);
    end
    xlim([find(ismember(sessionType,["visual","tactile","sensory","alternation"]),1,'first')-shadeOffset,...
        max(xlim)]); %Truncate L-maze data
   
    %Figure legend
    legend(p,vars,'Location','best','Interpreter','none');

     %Labels for maze-type/rule
    typeLabels = unique(sessionType,'stable');
    txtX = arrayfun(@(idx) find(sessionType==typeLabels(idx),1,'first'), 1:numel(typeLabels));
    txtY = min(ylim)+[1,2,1].*...
        0.1*(max(ylim)-min(ylim));
    for j = 1:numel(typeLabels)
        txt(j) = text(txtX(j),txtY(j),typeLabels(j),...
            'Color',colors.taskRule.(typeLabels(j)),...
            'HorizontalAlignment','left');
    end
    txt(end).HorizontalAlignment='right';
    txt(end).Position(1) = find(sessionType==typeLabels(end),1,'last');
       
    %Adjust height of shading as necessary
    if numel(ax.YAxis)==2
        ax.YAxis(1).Limits = [0, max(ax.YAxis(1).Limits)]; %Set min to zero
        ax.YAxis(2).Limits = [0, max(ax.YAxis(2).Limits)];
    end
    maxY = max([ax.YAxis(1).Limits]);
    minY = min([ax.YAxis(1).Limits]);
    newVert = [maxY,maxY,minY,minY];
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