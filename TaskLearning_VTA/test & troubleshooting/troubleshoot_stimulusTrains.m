clearvars;
%Load log file
% fname = 'W:\RigData\training\rig2_188\behav\VRoser\data\vr2617_709\vmr_tactile2visual_NLight_vmr_T2V_DAKO_188-Rig2_vr2617_709_T_20250312.mat';
fname = 'W:\Data\Raw\behavior\mjs20\mjs20_39\20260303_g0\mjs_tactile2visual_T2V_251027_170b-Rig1-I_mjs20_39_T_20260303_0.mat';

load(fname, 'log');

subjectName = log.animal.name;
sessionDate = datetime(num2str(log.session.start(1:3)),'InputFormat','yyyyMd');
sessionID = [subjectName, '_', char(sessionDate)];

T = log.block(2).trial;
nTowers = [cellfun(@(C) numel(C{:,1}), {T.cuePos})',...
    cellfun(@(C) numel(C{:,2}), {T.cuePos})'];
nPuffs = [cellfun(@(C) numel(C{:,1}), {T.puffPos})',...
    cellfun(@(C) numel(C{:,2}), {T.puffPos})'];

R = corrcoef(nPuffs, nTowers);
R_nCues = R(1,2); %ignore diagonal

%Using cueCombo instead of cuePos (cueOnset gave equivalent results to cuePos)
% nTowers = [cellfun(@(C) sum(C(1,:)), {T.cueCombo})]';
% nPuffs  = [cellfun(@(C) sum(C(2,:)), {T.cueCombo})]';
% zeroTowerTrials     = sum(nTowers,2)==0; %Logical
% zeroPuffTrials      = sum(nPuffs,2)==0; %Logical
% pZeroTowerTrials    = mean(zeroTowerTrials);
% pZeroPuffTrials     = mean(zeroPuffTrials);
%-------------------

zeroTowerTrials     = sum(nTowers,2)==0; %Logical
zeroPuffTrials      = sum(nPuffs,2)==0; %Logical

pZeroTowerTrials    = mean(zeroTowerTrials);
pZeroPuffTrials     = mean(zeroPuffTrials);
pZeroCueTrials      = mean(zeroTowerTrials & zeroPuffTrials);

fprintf('\n\n\n')
disp(['sessionID: ',sessionID,...
    ' pZeroTowerTrials: ',num2str(pZeroTowerTrials,3),...
    ' pZeroPuffTrials: ',num2str(pZeroPuffTrials,3),...
    ' pZeroCueTrials: ',num2str(pZeroCueTrials,3),...
    ' R_nCues: ',num2str(R_nCues,3)]);

%%
% T = table(sessionID, pZeroPuffTrials, pZeroTowerTrials, pZeroCueTrials, R_nCues);
% fprintf('\n\n\n')
% disp('Proportions of Trial-Types for each Behavioral Session:');
% fprintf('\n')
% disp(T);

%Load associated stimulus train
fname = 'C:\Users\mjs20\Documents\GitHub\ViRMEn\experiments\protocols\stimulus_trains_MJS_Tactile2Visual.mat';
% fname = 'C:\Users\mjs20\Documents\GitHub\ViRMEn\experiments\protocols\stimulus_trains_VMR_Tactile2Visual.mat';
load(fname, 'poissonStimuli');

trialIDs = [log.block(2).trial.trialID];
idx_perSession = ispositive(trialIDs);
idx_panSession = ~idx_perSession;

towerPos(idx_perSession) = {poissonStimuli.perSession(2,trialIDs(idx_perSession)).cuePos};
towerPos(idx_panSession) = {poissonStimuli.panSession(2,-1*trialIDs(idx_panSession)).cuePos}; %Flip sign on pan-session trialIDs (coded negative)
numTowers = [cellfun(@(C) numel(C{1}), towerPos); cellfun(@(C) numel(C{2}), towerPos)]';


% cuePos = {poissonStimuli.perSession(2,:).cuePos};
% numCuesSalDist = [cellfun(@(C) numel(C{1}),cuePos); cellfun(@(C) numel(C{2}),cuePos)]';
% 
% 
% nCues = numCuesSalDist(:,1);
% % nCues = [poissonStimuli.perSession(2,:).nSalient]; %%Alternate method: nSalient per trial
% pZeroCueTrials = sum(nCues==0)/numel(nCues); %yields ~0.6, so checks out!
% 
% %After running NormalStimulusTrain_mjs to break at ln 190
% cuePos = {poissonStimuli.perSession(2,:).cuePos};
% numCuesSalDist = [cellfun(@(C) numel(C{1}),cuePos); cellfun(@(C) numel(C{2}),cuePos)]';
% nCues_sal = numCuesSalDist(:,1);
% nCues_dis = numCuesSalDist(:,2);
% pZeroCueTrials = sum(nCues_sal==0)/numel(nCues_sal); %yields ~0.6, so checks out!

%% Check out the trial duplication features
idx = vr.poissonStimuli.selTrials;
idx = idx(ispositive(idx)); %just check perSession trials for now
[N,edges] = histcounts(idx,'BinMethod','integers');
trials = vr.poissonStimuli.perSession(2,N==1);

pSal = mean([trials.nSalient]==0);
pDis = mean([trials.nDistract]==0);