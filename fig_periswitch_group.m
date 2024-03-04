function fig = fig_periswitch_group( subjects, var, params )

setup_figprops('placeholder'); %Customize for performance plots

%Plotting params
markerSize = [10, 6]; %[mean, individual]
lineWidth = params.lineWidth;

%Colors
colors = params.colors;

%Prefix for save
prefix = 'Group';

%Aggregate data
nRule1 = params.nRule1;
for i = 1:numel(subjects)
    %Exclude shaping sessions
    S(i).sessions = subjects(i).sessions(ismember([subjects(i).sessions.taskRule],["visual","tactile"]));

    % Group according to different phases of training
    idx.visual{i} = [S(i).sessions.taskRule]=="visual"; % Tower-guided sessions
    idx.tactile{i} = [S(i).sessions.taskRule]=="tactile"; % Puff-guided sessions

    %Find rule order and index first two blocks
    ruleOrder = unique([S(i).sessions.taskRule],'stable');
    ruleSwitchIdx = diff([ruleOrder(1) S(i).sessions.taskRule]==ruleOrder(2));
    ruleSwitch1 = find(ruleSwitchIdx,1,'first');
    ruleSwitch2 = min([find(ruleSwitchIdx==-1,1,'first'), numel(ruleSwitchIdx)+1]); %Or last session
    idx.rule1{i} = ruleSwitch1 + (-nRule1:-1);%Last N sessions from rule-1
    idx.rule2{i} = ruleSwitch1:ruleSwitch2-1;
end

%How to treat data from most experienced mice
nRule2 = min(cellfun(@numel,idx.rule2)); %Use min number of sessions across mice
if isnumeric(params.nRule2)
    nRule2 = params.nRule2;
elseif strcmp(params.nRule2,'max')
    nRule2 = max(cellfun(@numel,idx.rule2)); %Use max number of sessions across mice
end

%Truncate data from Rule 2
idx.rule2 = cellfun(@(C) C(1:nRule2), idx.rule2, 'UniformOutput', false); %Cell

% data{2}(i,1:min(numel(altSessions{i}),maxSessions)) =...
%         values(altSessions{i}(1:min(numel(altSessions{i}),maxSessions)));

%Aggregate data into matrix for each variable
X = -nRule1 : nRule2-1;
data = getData(S, var, idx); %loops through each variable

% Generate Figure
fig = figure('Name',join([prefix,var],'-'));

Title = {'First Rule Switch'; ''}; %Extra text line
cbrew = brewColorSwatches;
colororder(cbrew.series);
ax = axes(); hold on;

%Plot dotted line for rule switch
plot([0,0],[0,1],'LineStyle',':','LineWidth',lineWidth,'Color',cbrew.gray);

%Plot group mean with SEM
for i = 1:numel(var)
    plot(X, mean(data.(var(i)),'omitnan'),'o',...
        'MarkerSize',markerSize(2),'LineStyle','none','LineWidth',lineWidth,...
        'Color', colors.(var(i)), 'MarkerFaceColor', colors.(var(i)));
    plotSEM(X, data.(var(i)), colors.(var(i)), lineWidth);

    switch var(i)
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
end

%Axes scale
xlim([min(X)-0.5, max(X)+0.5]);
axis square;

%Labels and titles
xlabel('Sessions from rule switch');
title(Title,'interpreter','none');

end
%End main fcn

%-------------------------------------------------------------------------------------------------

function data = getData(subjects, var, idx)
idx = cell2mat([idx.rule1', idx.rule2']);
for i = 1:numel(var)
    values = NaN(size(idx));
    for j = 1:numel(subjects)
        values(j,:) = [subjects(j).sessions(idx(j,:)).(var(i))];
    end
    data.(var(i)) = values;
end
end

function plotSEM( X, data, color, lineWidth )
sem = std(data,'omitnan')./sqrt(sum(~isnan(data),1));
sem = mean(data,'omitnan') + [-1;1].*sem;
for i = 1:numel(X)
    plot([X(i),X(i)],sem(:,i),'Color', color, 'LineWidth', lineWidth);
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