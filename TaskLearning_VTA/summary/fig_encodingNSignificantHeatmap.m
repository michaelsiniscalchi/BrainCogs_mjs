function fig = fig_encodingNSignificantHeatmap( population, sessions)

fig = figure('Name','encoding-n-significant',...
    'Position',[100,100,400,600]);

pSig = population.pSignificant;
N = population.N;
fields = string(fieldnames(pSig));
for i = 1:numel(fields)
    data(i,:) = [pSig.(fields(i))].*N;
end
ruleSwitchIdx = find(abs(diff([sessions.taskRule]=="visual")))+1;

imagesc(data);
yticks(1:numel(fields));
yticklabels(fields);
axis square
colorbar();
title('Number of Neurons Significant');