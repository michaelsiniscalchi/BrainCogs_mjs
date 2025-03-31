clearvars;

dataDir = fullfile("X:","michael","mjs_tactile2visual","results");
matfiles = ["mjs20_913","mjs20_40","mjs20_42"];
nSwitches = [2,3,4]; %Counted manually
figName = 'SessionsToCriterion_jGCaMP8s';

for i = 1:numel(matfiles)
    subjects(i) = load(fullfile(dataDir,matfiles(i)),'ID','sessions');
end

%Crunch performance data
for i = 1:numel(subjects)
    level = cellfun(@min,{subjects(i).sessions.level});
    perf = [subjects(i).sessions.pCorrect];
    bias = [subjects(i).sessions.bias];
    rule = [subjects(i).sessions.taskRule];
    criterion = @(lvl,levelIdx) perf(lvl==levelIdx)>0.7 & bias(lvl==levelIdx)<0.2;

    if sum(criterion(level,7))
        nSessions.rule1(i) = find(criterion(level,7),1,'first');
    else
        nSessions.rule1(i) = sum(level==7);
    end

    nSessions.rule2(i)=NaN;
    if sum(criterion(level,8))
        nSessions.rule2(i) = find(criterion(level,8),1,'first');
    end

    totalSessions(i) = sum(level>6) -(sum(criterion(level,7))+sum(criterion(level,8))) +nSwitches(i); %Exclude sessions where a switch should have occurred but did not
    switchesPer100(i) = (nSwitches(i)/totalSessions(i))*100;

    t2v(i) = find(rule=="tactile",1,'first')<find(rule=="visual",1,'first');
    v2t(i) = ~t2v(i);
end

%Box plot of nSessions for each maze condition
fig = figure('Name',figName,'Position',[300 300 1000 400]);
t=tiledlayout(1,4,'TileSpacing','loose');
cbrew = brewColorSwatches;
boxWidth = 0.5;
lineWidth = 1;

%Sessions to Criterion, Groups Combined
ax = nexttile;
data = {nSessions.rule1, nSessions.rule2};
colors = {cbrew.black; cbrew.black};
transparency = [0, 0.4];
X = 1:numel(data);
for i=1:numel(data)
    p(i) = plot_basicBox( X(i), data{i}, boxWidth, lineWidth,...
        colors{i}, transparency(i) ); hold on
    plot(X(i), data{i},'o','MarkerSize',5,...
        'LineStyle','none','LineWidth',lineWidth,'Color',colors{i}); %Overlay data points
end
%Labels and titles
title('Sessions to Criterion')
ylabel('Number of sessions');
set(ax,'XTick',X,'XTickLabel',({'Rule 1','Rule 2'}));
axis square;
xlim([0.5,2.5]);

%Sessions to Criterion, Groups Combined
% ax = subplot(1,2,2);
ax = nexttile;
data = {...
    [nSessions.rule1(v2t); nSessions.rule2(v2t)],...
    [nSessions.rule2(t2v); nSessions.rule1(t2v)]};
colors = {cbrew.blue; cbrew.purple};
for i=1:numel(data)
    p(i) = scatter(data{i}(1,:), data{i}(2,:), 30, colors{i},'filled'); hold on;
end
plot([0,50],[0,50],':k','LineWidth',0.5);
%Labels and titles
title('Sessions to Criterion')
xlabel('Visual rule');
ylabel('Tactile rule');
xlim([0,50]); ylim([0,50]);
xticks([0,25,50]); yticks([0,25,50]);
lgd = legend(["V2T","T2V"],"Location","layout");
lgd.Layout.Tile = 3;
axis square;

%Switches per 100 sessions, Groups Combined
ax = nexttile;
X = 1;
plot_basicBox( X, switchesPer100, boxWidth, lineWidth,...
    cbrew.black, 0 ); hold on
plot(X, switchesPer100,'o','MarkerSize',5,...
    'LineStyle','none','LineWidth',lineWidth,'Color',cbrew.black); %Overlay data points

%Labels and titles
title({'Rule Blocks'; 'Per 100 Sessions'})
ylabel('Number of blocks');
xticks([]);
axis square;
xlim([0,2]);
ylim([0,15]);

medianSwitchesPer100 = median(switchesPer100);
meanSwitchesPer100 = mean(switchesPer100);
semSwitchesPer100 = std(switchesPer100)/sqrt(numel(switchesPer100));
disp(['medianSwitchesPer100 = ' num2str(medianSwitchesPer100)]);
disp(['meanSwitchesPer100 = ' num2str(meanSwitchesPer100)]);
disp(['semSwitchesPer100 = ' num2str(semSwitchesPer100)]);

saveDir = 'X:\michael\mjs_tactile2visual';
save_multiplePlots(fig,saveDir);

% %Sessions to Criterion, Visual-to-Tactile Rule
% ax = subplot(1,4,1);
% data = {nSessions.rule1(v2t), nSessions.rule2(v2t)};
% colors = {cbrew.blue; cbrew.purple};
% transparency = [0.4, 0.4];
% X = 1:numel(data);
% for i=1:numel(data)
%     p(i) = plot_basicBox( X(i), data{i}, boxWidth, lineWidth,...
%         colors{i}, transparency(i) );
%     plot(X(i), data{i},'o','MarkerSize',5,...
%         'LineStyle','none','LineWidth',lineWidth,'Color',colors{i}); %Overlay data points
% end
% %Labels and titles
% title('Visual-to-Tactile')
% ylabel('Sessions to Criterion');
% set(ax,'XTickLabel',({'Rule 1','Rule 2'}));
% axis square;
% xlim([0.5,2.5]);
% 
% %Sessions to Criterion, Tactile-to-Visual Rule
% ax = subplot(1,4,2);
% data = {nSessions.rule1(t2v), nSessions.rule2(t2v)};
% colors = {cbrew.purple; cbrew.blue};
% transparency = [0.4, 0.4];
% X = 1:numel(data);
% for i=1:numel(data)
%     p(i) = plot_basicBox( X(i), data{i}, boxWidth, lineWidth,...
%         colors{i}, transparency(i) );
%     plot(X(i), data{i},'o','MarkerSize',5,...
%         'LineStyle','none','LineWidth',lineWidth,'Color',colors{i}); %Overlay data points
% end
% %Labels and titles
% title('Tactile-to-Visual')
% set(ax,'XTickLabel',({'Rule 1','Rule 2'}));
% axis square;
% xlim([0.5,2.5]);

%["mjs20_22","mjs20_23","mjs20_24","mjs20_25","mjs20_26","mjs20_103","mjs20_105"]
%nRuleSwitches = [,,,15,,,]
%nSessions = 