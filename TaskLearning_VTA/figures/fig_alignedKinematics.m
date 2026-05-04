function   figs = fig_alignedKinematics( session, kinematicData, trialMasks, subjectID, colors )

setup_figprops("timeseries");

%Get event names and relative time vector
events = string(fieldnames(kinematicData));
events = events(events~="t");
t = kinematicData.t;

figIdx = 1;
figs(figIdx) = figure(...
    'Name',strjoin([subjectID, datestr(session.session_date,'yymmdd'), "aligned", "speed"],'-'),...
    'Position',[10,100,600,400]);



xLabels = [...
    "Time from first cue (s)",...
    "Time from first puff (s)",...
    "Time from first tower (s)"];

titles = ["Running Speed","Lateral Movement","Lateral Movement"];
lgdLabels = ["First puff","First tower"];
if session.taskRule=="visualCS"
    lgdLabels = ["First puff (CS-)","First tower (CS+)"];
    titles(2:3) = ["Lateral Movement (CS+)","Lateral Movement (CS-)"];
elseif session.taskRule=="tactileCS"
    lgdLabels = ["First puff (CS+)","First tower (CS-)"];
    titles(2:3) = ["Lateral Movement (CS-)","Lateral Movement (CS+)"];
end

%Plot speed/velocity with sd
%Speed, visual vs. tactile cue
cues = ["firstPuff","firstTower"];
C = {colors.taskRule.tactile, colors.taskRule.visual};
for i = 1:numel(cues)
    data = kinematicData.(cues(i)).speed;
    baseline = mean(data(:,t<=0),2,"omitmissing");
    data = data-baseline; %subtract baseline
    y = mean(data,'omitmissing');
    sd = y + std(data, 'omitmissing').*[-1,1]';
    errorshade(t, sd(1,:), sd(2,:), C{i}, 0.5); hold on
    p(i) = plot(t, y, "Color", C{i}, "DisplayName", lgdLabels(i));
end
plot([0,0],[min(ylim), max(ylim)], ':k');
ylims = ylim;
axis square
ylim(ylims);

title(titles(figIdx));
ylabel("Relative speed (cm/s)");
xlabel(xLabels(figIdx));
lgd = legend(p);
lgd.Location = "eastoutside";

clearvars sd
figIdx = figIdx+1;


%X-velocity, visual, left vs. right trials
figs(2) = figure(...
    'Name',strjoin([subjectID, datestr(session.session_date,'yymmdd'), "aligned", "xDisplacement"],'-'),...
    'Position',[10,100,1000,400]);
T = tiledlayout(1,2,"TileSpacing","tight","Padding","tight");
ax(2) = nexttile(T);
cueTypes = ["leftTowers","rightTowers"];
C = {colors.left, colors.right};
lgdLabels = ["Left cue","Right cue"];
for i = 1:numel(cueTypes)
    data = kinematicData.firstTower.xPosition(trialMasks.(cueTypes(i)),:);
    baseline = mean(data(:,t<=0),2,"omitmissing");
    data = data-baseline; %subtract baseline
    y = mean(data,'omitmissing');
    sd = y + std(data, 'omitmissing').*[-1,1]';
    errorshade(t, sd(1,:), sd(2,:), C{i}, 0.5); hold on
    p(i) = plot(t, y, "Color", C{i}, "DisplayName", lgdLabels(i));
end
ylim([-1,1]);
plot([0,0],[min(ylim), max(ylim)], ':k');
axis square
title(titles(figIdx));
ylabel("X-displacement (cm)");
xlabel(xLabels(figIdx));

clearvars sd
figIdx = figIdx+1;

%X-velocity, tactile, left vs. right trials
ax(3) = nexttile(T);

cueTypes = ["leftPuffs","rightPuffs"];
C = {colors.left, colors.right};

for i = 1:numel(cueTypes)
    data = kinematicData.firstPuff.xPosition(trialMasks.(cueTypes(i)),:);
     baseline = mean(data(:,t<=0),2,"omitmissing");
    data = data-baseline; %subtract baseline
    y = mean(data,'omitmissing');
    sd = y + std(data, 'omitmissing').*[-1,1]';
    errorshade(t, sd(1,:), sd(2,:), C{i}, 0.5); hold on
    p(i) = plot(t, y, "Color", C{i}, "DisplayName", lgdLabels(i));
end
% maxAbs = max(abs([sd{:}]),[],"all");
ylim([-1,1]);
plot([0,0],[min(ylim), max(ylim)], ':k');
axis square
title(titles(figIdx));
ylabel("X-displacement (cm)");
xlabel(xLabels(figIdx));
lgd = legend(p);
lgd.Location = "eastoutside";

end