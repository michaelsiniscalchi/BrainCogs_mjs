load('X:\michael\tactile2visual-vta\results\250221-m913-maze8\img_beh.mat', 'trialDFF', 'trials')

field = "stuckOnset";
cellFluo = trialDFF.(field){1};
if iscell(cellFluo) %For >1 potential events per trial
    cellFluo = cell2mat(cellFluo); 
end
XData = trialDFF.t;
YData = 1:size(cellFluo,1);

figure; 
img = imagesc(XData, YData, cellFluo);
% img = imagesc(cellFluo);

xlabel('Time (s)');
ylabel('Event index');

%%
sum(isnan(cellFluo(:,100)),1)
sum(all(isnan(cellFluo),2))

%% From within alignCellFluo
%load('X:\michael\tactile2visual-vta\results\250221-m913-maze8\img_beh.mat', 'trials')

XData = rel_idx*dt;
YData = 1:size(idx,1);
cellFluo = aligned.(events{i}){j};
% cellFluo = cell2mat(cellFluo); %If cell array

figure; 
img = imagesc(XData, YData, cellFluo);
figure;
Y = mean(cellFluo,'omitmissing');
plot(XData,Y);

%Big problem for data stored in cells: NaN for relative time prior to t0 and fluorescence following t0 where it should be absent!
%Duplication of first row for events absent in trial
%'frameDelay' and missing data handling in alignCellFluo.m likely to blame...*Fixed!*