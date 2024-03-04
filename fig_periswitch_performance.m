function fig = fig_periswitch_performance( subjects, var, params )

setup_figprops('placeholder'); %Customize for performance plots

%Plotting params
markerSize = [10,6];
lineWidth = 1;
shadeOffset = 0.5;
transparency = 0.3;

%Colors
colors = params.colors;

%Prefix for save
prefix = 'Group';

%Aggregate data
nPrior = params.nPriorSessions;
for i = 1:numel(subjects)
    % Group according to different phases of training
    idx.visual = [subjects(i).sessions.taskRule]=="visual"; % Sensory-guided sessions
    idx.tactile = [subjects(i).sessions.sessionType]=="tactile"; % Alternation sessions
    
    rule1 = [subjects(i).sessions.taskRule];        
    sessions.rule1{i} = find(idx.(rule1),nPriorSessions,'last');
    altSessions{i} = find(altIdx);
end

%How to treat data from most experienced mice
nAdaptive = min(cellfun(@numel,altSessions)); %Use min number of sessions across mice
if isnumeric(params.nAlternation)
    nAlternation = params.nAlternation;
elseif strcmp(params.nAlternation,'max')
    nAlternation = max(cellfun(@numel,altSessions)); %Use max number of sessions across mice
end

%Aggregate into matrix
Title = 'Sensory to Alternation';
cbrew = brewColorSwatches;
shading = cbrew.blue;
    
    fig = figure('Name',join([prefix,var],'-'));
    colororder(cbrew.series);
    ax = axes();
    hold on;

    data = getData(subjects,var,sensorySessions,altSessions,nSensory,nAlternation);
    X = -(size(data{1},2)) : size(data{2},2)-1;
%     shadeDomain(X(X>=0),... %Shade sessions after switch
%         [0,1], shadeOffset, shading, transparency);
plot([0,0],[0,1],'LineStyle',':','LineWidth',lineWidth,'Color',cbrew.gray);
    
    if var=="pCorrect_conflict"
        plot(X, mean([data{:}],'omitnan'),'o','MarkerSize',markerSize(2),...
            'LineStyle','none','LineWidth',lineWidth,'Color',colors.(var));
        plotSEM(X, [data{:}],colors.(var),lineWidth);
        var = "pCorrect_congruent";
        data = getData(subjects,var,sensorySessions,altSessions,nSensory,nAlternation); %Co-plot with pCorrect_congruent
        plot(X, mean([data{:}],'omitnan'),'o','MarkerSize',markerSize(2),...
            'LineStyle','none','LineWidth',lineWidth,'Color',colors.(var));
        plotSEM(X, [data{:}],colors.(var),lineWidth);
    elseif var=="maxCorrectMoving_conflict"
        plot(X, mean([data{:}],'omitnan'),'o','MarkerSize',markerSize(2),...
            'LineStyle','none','LineWidth',lineWidth,'Color',colors.(var));
        plotSEM(X, [data{:}],colors.(var),lineWidth);
        var = "maxCorrectMoving_congruent";
        data = getData(subjects,var,sensorySessions,altSessions,nSensory,nAlternation); %Co-plot with pCorrect_congruent
        plot(X, mean([data{:}],'omitnan'),'o','MarkerSize',markerSize(2),...
            'LineStyle','none','LineWidth',lineWidth,'Color',colors.(var));
        plotSEM(X, [data{:}],colors.(var),lineWidth);
    
    else
        plot(X, [data{:}],'.','MarkerSize',markerSize(1),'LineStyle','none');
        plot(X(X<0), mean([data{1}],'omitnan'),'Color',colors.(var));
        plot(X(X>=0), mean([data{2}],'omitnan'),'Color',colors.(var));
    end
        switch var
            case {'pCorrect','pCorrect_congruent','pCorrect_conflict'}
                ylabel('Accuracy');
                ylim([0, 1]);
            case {'maxCorrectMoving_congruent','maxCorrectMoving_conflict'}
                ylabel('Max. Accuracy');
                ylim([0, 1]);
            case 'pOmit'
                ylabel('Proportion of trials');
                ylim([0, 1]);
            case 'mean_velocity'
                ylabel('Mean velocity (cm/s)');
            case 'nCompleted'
                ylabel('Number of completed trials');
        end
    
    %Axes scale
    xlim([min(X)-0.5, max(X)+0.5]);
    axis square;
    
    %Labels and titles
    xlabel('Sessions from introduction');
%     title(Title,'interpreter','none');
end
%End main fcn

    function data = getData(subjects,var,sensorySessions,altSessions,nSensory,maxSessions)
        data = {NaN(numel(subjects),nSensory), NaN(numel(subjects),maxSessions)};
        for i = 1:numel(subjects)
            values = [subjects(i).sessions.(var)];
            nSessions = numel(sensorySessions{i});
            data{1}(i,end-nSessions+1:end) = values(sensorySessions{i});
            data{2}(i,1:min(numel(altSessions{i}),maxSessions)) =...
                values(altSessions{i}(1:min(numel(altSessions{i}),maxSessions)));
        end
    end
    
    function plotSEM(X,data,color,lineWidth)
    sem = std(data,'omitnan')./sqrt(sum(~isnan(data)));
    sem = mean(data,'omitnan') + [-1;1].*sem;
    for i = 1:numel(X)
        plot([X(i),X(i)],sem(:,i),'Color',color,'LineWidth',lineWidth);
    end
    end

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
            p = patch(X, Y, color,'EdgeColor','none',...
                'FaceAlpha',transparency); hold on;
        end
        
    end