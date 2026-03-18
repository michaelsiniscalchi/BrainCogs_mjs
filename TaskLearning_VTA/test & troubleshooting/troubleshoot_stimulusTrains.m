clearvars;
%Load log file
% fname = 'W:\RigData\training\rig2_188\behav\VRoser\data\vr2617_709\vmr_tactile2visual_NLight_vmr_T2V_DAKO_188-Rig2_vr2617_709_T_20250312.mat';
% fname = 'W:\Data\Raw\behavior\mjs20\mjs20_37\20260303_g0\mjs_tactile2visual_T2V_251027_170b-Rig1-I_mjs20_37_T_20260303_0.mat';
% fname = 'W:\Data\Raw\behavior\mjs20\mjs20_39\20260303_g0\mjs_tactile2visual_T2V_251027_170b-Rig1-I_mjs20_39_T_20260303_0.mat';
% fname = 'W:\Data\Raw\behavior\mjs20\mjs20_713\20250826_g0\mjs_tactile2visual_T2V_250613_170b-Rig1-I_mjs20_713_T_20250826_0.mat';

fname = 'W:\Data\Raw\behavior\mjs20\mjs20_37\20260120_g0\mjs_tactile2visual_T2V_251027_170b-Rig1-I_mjs20_37_T_20260120_0.mat';
% fname = 'W:\Data\Raw\behavior\mjs20\mjs20_37\20260121_g0\mjs_tactile2visual_T2V_251027_170b-Rig1-I_mjs20_37_T_20260121_0.mat';
% fname = 'W:\Data\Raw\behavior\mjs20\mjs20_37\20260122_g0\mjs_tactile2visual_T2V_251027_170b-Rig1-I_mjs20_37_T_20260122_0.mat';
% fname = 'W:\Data\Raw\behavior\mjs20\mjs20_37\20260123_g0\mjs_tactile2visual_T2V_251027_170b-Rig1-I_mjs20_37_T_20260123_0.mat';

load(fname, 'log');

% towerPos_37 = {log.block(2).trial(1:100).cuePos};
% puffPos_37 = {log.block(2).trial(1:100).puffPos};
% trialIDs_37 = [log.block(2).trial(1:100).trialID];

% towerPos_39 = {log.block(2).trial(1:100).cuePos};
% puffPos_39 = {log.block(2).trial(1:100).puffPos};
% trialIDs_39 = [log.block(2).trial(1:100).trialID];

subjectName = log.animal.name;
sessionDate = datetime(num2str(log.session.start(1:3),'%4u %02u %02u'),'InputFormat','yyyyMMdd');
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

% trialIDs = [log.block(2).trial.trialID];
% idx_perSession = ispositive(trialIDs);
% idx_panSession = ~idx_perSession;
% 
% towerPos(idx_perSession) = {poissonStimuli.perSession(2,trialIDs(idx_perSession)).cuePos};
% towerPos(idx_panSession) = {poissonStimuli.panSession(2,-1*trialIDs(idx_panSession)).cuePos}; %Flip sign on pan-session trialIDs (coded negative)
% numTowers = [cellfun(@(C) numel(C{1}), towerPos); cellfun(@(C) numel(C{2}), towerPos)]';


% idx = 1:length(poissonStimuli.perSession);
idx = 1:200;
cuePos = {poissonStimuli.perSession(end, idx).cuePos};
numCuesSalDist = [cellfun(@(C) numel(C{1}), cuePos); cellfun(@(C) numel(C{2}),cuePos)]';
nCues = numCuesSalDist(:,1);
nDistract = numCuesSalDist(:,2);
% nCues = [poissonStimuli.perSession(end,idx).nSalient]; %Alternate method: nSalient per trial
% nDistract = [poissonStimuli.perSession(end,idx).nDistract]; %Alternate method: nSalient per trial
pZeroCueTrials = [mean(nCues==0), mean(nDistract==0)]; %yields ~0.6, so checks out!

% 
% %After running NormalStimulusTrain_mjs to break at ln 190
% cuePos = {poissonStimuli.perSession(2,:).cuePos};
% numCuesSalDist = [cellfun(@(C) numel(C{1}),cuePos); cellfun(@(C) numel(C{2}),cuePos)]';
% nCues_sal = numCuesSalDist(:,1);
% nCues_dis = numCuesSalDist(:,2);
% pZeroCueTrials = sum(nCues_sal==0)/numel(nCues_sal); %yields ~0.6, so checks out!

%% Check out the trial duplication features
% Punchline: sessions are virtually identical sequences of trials (cue and distractor positions)
clearvars;
%Load log files

fname(1) = "W:\Data\Raw\behavior\mjs20\mjs20_37\20260120_g0\mjs_tactile2visual_T2V_251027_170b-Rig1-I_mjs20_37_T_20260120_0.mat";
fname(2) = "W:\Data\Raw\behavior\mjs20\mjs20_37\20260121_g0\mjs_tactile2visual_T2V_251027_170b-Rig1-I_mjs20_37_T_20260121_0.mat";
fname(3) = "W:\Data\Raw\behavior\mjs20\mjs20_37\20260122_g0\mjs_tactile2visual_T2V_251027_170b-Rig1-I_mjs20_37_T_20260122_0.mat";
fname(4) = "W:\Data\Raw\behavior\mjs20\mjs20_37\20260123_g0\mjs_tactile2visual_T2V_251027_170b-Rig1-I_mjs20_37_T_20260123_0.mat";

for i = 1:numel(fname)
    logs(i) = load(fname(i), 'log');
    trialIDs{i} = [logs(i).log.block(2).trial.trialID];
    nCues{i} = [cellfun(@(C) sum(C(1,:)),{logs(i).log.block(2).trial.cueCombo})]';    
    nDistractors{i} = [cellfun(@(C) sum(C(2,:)),{logs(i).log.block(2).trial.cueCombo})]'; 
end

%% Check new stimulus generator
load('C:\Users\mjs20\Documents\GitHub\ViRMEn\experiments\protocols\stimulus_trains_MJS_Tactile2Visual.mat')

P2 = poissonStimuli.perSession(2,:);
P3 = poissonStimuli.perSession(3,:);

%Levels 7 & 8: Check zero-cue and 0-0 trials
mean([P2.nDistract]<1)                   %0.0500
mean([P2.nSalient]<1)                    %0.0500
mean([P2.nSalient]<1 & [P2.nDistract]<1) %0.0030 %Looks good!

%Check dispersion of zero-cue trials
min(diff(find([P2.nDistract]<1))) %4
max(diff(find([P2.nDistract]<1))) %41  
min(diff(find([P2.nSalient]<1))) %3
max(diff(find([P2.nSalient]<1))) %40

%Levels 9 & 10 (unimodal): Check zero-cue and 0-0 trials
mean([P3.nDistract]<1) %0.5250
mean([P3.nSalient]<1)  %0.5250
mean([P3.nSalient]<1 & [P3.nDistract]<1) %0.0500 

%Check dispersion
min(diff(find([P3.nDistract]<1))) %1 nConsecutive no-distractor trials
max(diff(find([P3.nDistract]<1))) %4 
min(diff(find([P3.nSalient]<1))) %1 nConsecutive no-salient trials
max(diff(find([P3.nSalient]<1))) %4

max(diff(find(~[P3.nDistract]>0))) %4 max consecutive distractor trials
max(diff(find(~[P3.nSalient]>0))) %4 
