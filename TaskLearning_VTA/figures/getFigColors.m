function colors = getFigColors()

%% FIGURES: COLOR PALETTE FROM CBREWER
% Color palette from cbrewer()
c = cbrewer('qual','Paired',10);
colors = {'red',c(6,:),'red2',c(5,:),'blue',c(2,:),'blue2',c(1,:),'green',c(4,:),'green2',c(3,:),...
    'purple',c(10,:),'purple2',c(9,:),'orange',c(8,:),'orange2',c(7,:)};
% Add additional colors from Set1 & Pastel1
c = cbrewer('qual','Set1',9);
c2 = cbrewer('qual','Pastel1',9);
colors = [colors {'pink',c(8,:),'pink2',c2(8,:),'gray',c(9,:),'gray2',[0.7,0.7,0.7],'black',[0,0,0]}];
cbrew = struct(colors{:}); %Merge palettes
clearvars colors

% %Define color codes for cell types, etc.
choiceColors = {'left',cbrew.red,'left2',cbrew.red2,'right',cbrew.blue,'right2',cbrew.blue2}; 
ruleColors = {'all',cbrew.black,'alternation',cbrew.purple,'alternation2',cbrew.purple2,...
    'congruent',cbrew.black,'congruent2',cbrew.gray,'conflict',cbrew.red,'conflict2',cbrew.red2}; 
outcomeColors = {'correct',cbrew.green,'correct2',cbrew.green2,'err',cbrew.pink,'err2',cbrew.pink2,...
    'pErr',cbrew.pink,'pErr2',cbrew.pink2,'oErr',cbrew.pink,'oErr2',cbrew.pink2,...
    'miss',cbrew.gray,'miss2',cbrew.gray2};
performanceColors = {'bias',cbrew.green2};
dataColors = {'data',cbrew.black,'data2',cbrew.gray};
colors = struct(choiceColors{:}, ruleColors{:}, outcomeColors{:}, dataColors{:}, performanceColors{:});

%Color names
for f = string(fieldnames(cbrew))'
    colors.(f) = cbrew.(f);
end