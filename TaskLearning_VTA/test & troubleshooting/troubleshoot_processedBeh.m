clearvars

search_filter = 'm42';
% search_filter = '250812-m713-maze7';
% search_filter = '250826-m713-maze8';

% Set path
dirs = getRoots();
addGitRepo(dirs,'General','iCorre-Registration','BrainCogs_mjs','TankMouseVR','U19-pipeline-matlab',...
    'datajoint-matlab','compareVersions','GHToolbox');
addpath(genpath(fullfile(dirs.code, 'mym', 'distribution', 'mexa64')));

% Session-specific metadata
[dirs, expData] = expData_Tactile2Visual_VTA(dirs);
expData = expData(contains({expData(:).sub_dir}', search_filter)); %Filter by data-directory name, etc.

% Set parameters for analysis
experiment = 'mjs_tactile2visual'; %If empty, fetch data from all experiments
[calculate, summarize, figures, mat_file ] = params_Tactile2Visual_VTA(dirs, expData);

for i=1:numel(expData)

    %Load processed behavioral data
load(mat_file.img_beh(i),'trialData','trials');

%Est. corr. coef. between nPuffs & nTowers
nPuffs = sum(trialData.nPuffs(~trials.omit,:),2);
nTowers = sum(trialData.nTowers(~trials.omit,:),2);
R = corrcoef(nPuffs, nTowers);
R_nCues(i,:) = R(1,2); %ignore diagonal

%Calc. proportions of single-modality and joint 0-cue trials
pZeroPuffs(i,:) = sum(trials.noPuffs & ~trials.omit)/sum(~trials.omit);
pZeroTowers(i,:) = sum(trials.noTowers & ~trials.omit)/sum(~trials.omit);
pZeroCues(i,:) = sum(trials.noPuffs & trials.noTowers & ~trials.omit)...
    /sum(~trials.omit);
end

fprintf('\n\n\n')
disp('Proportions of Trial-Types for each Behavioral Session:');
fprintf('\n')
sessionID = {expData.sub_dir}';
T = table(sessionID, pZeroPuffs, pZeroTowers, pZeroCues, R_nCues);
disp(T);

%% break at getRemoteVRData.m ln 170
k=2;
 
%Index for trials in current block
Trials = log.block(k).trial;
firstTrial = numel(log.block(1).trial)+1;
lastTrial = firstTrial + numel(Trials) - 1;
blockIdx(firstTrial:lastTrial) = k;
[towerPositions(blockIdx==k,:), puffPositions(blockIdx==k,:)] = getCuePositions(log, k);

            nTowers(blockIdx==k,:) = [...
                arrayfun(@(idx) numel(towerPositions{idx}{1}), find(blockIdx==k)'),... %Left cues
                arrayfun(@(idx) numel(towerPositions{idx}{2}), find(blockIdx==k))']; %Right cues

            nPuffs(blockIdx==k,:) = [...
                arrayfun(@(idx) numel(puffPositions{idx}{1}), find(blockIdx==k)'),... %Left cues
                arrayfun(@(idx) numel(puffPositions{idx}{2}), find(blockIdx==k))']; %Right cues


%% break at getRemoteVRData.m ln 170            
nPuffs = nPuffs(11:end,:);
nTowers = nTowers(11:end,:);

zeroPuffMask = sum(nPuffs,2)==0; %Exclude first block, 10 trials
nZeroPuffTrials = sum(zeroPuffMask);
pZeroPuffTrials = mean(sum(nPuffs,2)==0); %250212-m913-maze7' =0.07...checks out!

zeroTowerMask = sum(nTowers,2)==0;
nZeroTowerTrials = sum(zeroTowerMask);
pZeroTowerTrials = mean(sum(nTowers,2)==0); %250212-m913-maze7' =0.07...checks out!

pZeroCueTrials = mean(zeroPuffMask & zeroTowerMask);

