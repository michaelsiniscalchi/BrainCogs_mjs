function fig = fig_encodingPSignificantHeatmap( population, sessions, subjectID)

fig = figure('Name',strjoin([subjectID, "-encoding-p-significant"],''),...
    'Position',[100,100,1000,600]);

pSig = population.pSignificant;
N = population.N;
fields = string(fieldnames(pSig));
for i = 1:numel(fields)
    data(i,:) = [pSig.(fields(i))];
end
ruleSwitchIdx = find(abs(diff([sessions.taskRule]=="visual")))+0.5; %+1 for diff, -0.5 for image elements, centered on X value

imagesc(data); hold on
plot([ruleSwitchIdx,ruleSwitchIdx],[min(ylim),max(ylim)],'m');
ax = gca;
yticks(1:numel(fields));
yticklabels(fields);
ax.TickLabelInterpreter = 'none';

% axis square
colorbar();
title('Proportion of Neurons Significant');
% fig.Visible = "off";