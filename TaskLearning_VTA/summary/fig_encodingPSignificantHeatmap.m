function fig = fig_encodingPSignificantHeatmap( population, sessions, subjectID)

fig = figure('Name',strjoin([subjectID, "-encoding-p-significant"],''),...
    'Position',[100,100,800,500]);

pSig = population.pSignificant;
N = population.N;
fields = string(fieldnames(pSig));
for i = 1:numel(fields)
    data(i,:) = [pSig.(fields(i))];
    for j = 1:size(data, 2)
        dataLabel(i,j) = strjoin([string(data(i,j).*N(j)),"/", N(j)],''); %Fraction of nCells in each session
    end
end
ruleSwitchIdx = find(abs(diff([sessions.taskRule]=="visual")))+0.5; %+1 for diff, -0.5 for image elements, centered on X value

imagesc(data); hold on
plot([ruleSwitchIdx,ruleSwitchIdx],[min(ylim),max(ylim)],'m');
for i = 1:size(dataLabel,1)
    for j =1:size(dataLabel,2)
        text(j,i,0,dataLabel(i,j),'Color','m','FontSize',8,'HorizontalAlignment','center');
    end
end

ax = gca;
xticks(1:size(data,2));
yticks(1:numel(fields));
yticklabels(fields);
ax.TickLabelInterpreter = 'none';

% axis square
colorbar();
title('Proportion of Neurons Significant');
% fig.Visible = "off";