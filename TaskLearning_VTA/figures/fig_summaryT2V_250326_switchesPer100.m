clearvars;

dataDir = fullfile("X:","michael","mjs_tactile2visual","results");
saveDir = 'X:\michael\mjs_tactile2visual'; %For summary vars and figure

matfiles{1} = ["mjs20_22","mjs20_23","mjs20_24","mjs20_25","mjs20_26"];
nSwitches{1} = [2,3,3,15,4]; %Counted manually

matfiles{2} = ["mjs20_018","mjs20_173","mjs20_175","mjs20_177","mjs20_199",...
    "mjs20_569","mjs20_570","mjs20_571","mjs20_572","mjs20_834","mjs20_32","mjs20_33"];
nSwitches{2} = [1,0,0,1,1,...
    0,3,3,1,1,1,2]; %Counted manually

matfiles{3} = ["mjs20_913","mjs20_40","mjs20_42"];
nSwitches{3} = [2,4,4]; %Counted manually

cohortNames = ["C57", "DAT-cre::Ai148", "DAT-cre::jGCaMP8s"];
figName = 'switchesPer100sessions_strainComp';

for i = 1:numel(cohortNames)
    for j = 1:numel(matfiles{i})
        subjects{i}(j) = load(fullfile(dataDir,matfiles{i}(j)),'ID','sessions');
    end
end

for i = 1:numel(cohortNames)
    %Crunch performance data
    for j = 1:numel(subjects{i})
        rule = [subjects{i}(j).sessions.taskRule];
        perf = [subjects{i}(j).sessions.pCorrect];
        bias = [subjects{i}(j).sessions.bias];
        rule = [subjects{i}(j).sessions.taskRule];
        criterion = @(ruleName) perf(rule==ruleName)>0.7 & bias(rule==ruleName)<0.2;

        totalSessions{i}(j) = sum(rule=="tactile"|rule=="visual") -(sum(criterion("tactile"))+sum(criterion("visual"))) +nSwitches{i}(j); %Exclude sessions where a switch should have occurred but did not
        switchesPer100{i}(j) = (nSwitches{i}(j)/totalSessions{i}(j))*100;
     
    end
end

%Switches per 100 sessions
fig = figure('Name',figName,'Position',[300 300 1000 400]);
cbrew = brewColorSwatches;
boxWidth = 0.5;
lineWidth = 1;

X = 1:numel(cohortNames);
for i = 1:numel(cohortNames)

plot_basicBox( X(i), switchesPer100{i}, boxWidth, lineWidth,...
    cbrew.black, 0 ); hold on
plot(X(i), switchesPer100{i},'o','MarkerSize',5,...
    'LineStyle','none','LineWidth',lineWidth,'Color',cbrew.black); %Overlay data points
end

%Labels and titles
title({'Rule Blocks'; 'Per 100 Sessions'})
ylabel('Number of blocks');
xticks(1:numel(cohortNames));
xticklabels(cohortNames);
axis square;
xlim([0,4]);
ylim([0,16]);

for i = 1:numel(cohortNames)
meanNumSwitches{i} = mean(nSwitches{i});
medianSwitchesPer100{i} = median(switchesPer100{i});
meanSwitchesPer100{i} = mean(switchesPer100{i});
semSwitchesPer100{i} = std(switchesPer100{i})/sqrt(numel(switchesPer100{i}));
disp('=============================================');
disp('');
disp(strjoin([cohortNames(i), ': ']));
disp(['meanNumSwitches = ' num2str(meanNumSwitches{i})]);
disp(['medianSwitchesPer100 = ' num2str(medianSwitchesPer100{i})]);
disp(['meanSwitchesPer100 = ' num2str(meanSwitchesPer100{i})]);
disp(['semSwitchesPer100 = ' num2str(semSwitchesPer100{i})]);
end

%Save summary variables and figure
save(fig.Name,'cohortNames','meanNumSwitches','medianSwitchesPer100','meanSwitchesPer100','semSwitchesPer100');
save_multiplePlots(fig,saveDir);