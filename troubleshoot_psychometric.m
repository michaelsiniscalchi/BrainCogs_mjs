S=subjects(1).sessions(end)

figure;
plot(S.psychometric.all.towers.bins, S.psychometric.all.towers.pRight)
figure;
plot(S.psychometric.conflict.towers.bins, S.psychometric.conflict.towers.pRight)
%%
figure;
plot(psychometric.all.towers.bins, psychometric.all.towers.pRight)
figure;
plot(psychometric.congruent.towers.bins, psychometric.congruent.towers.pRight)

%%
figure;
plot(psychometric.towers.bins,psychometric.towers.pRight)
figure;
plot(psychometric.puffs.bins,psychometric.puffs.pRight)


%%
figure;
plot(psychStruct.towers.bins,psychStruct.towers.pRight); hold on
plot(psychStruct.puffs.bins,psychStruct.puffs.pRight);
