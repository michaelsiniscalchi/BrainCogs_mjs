clearvars;

%Get the Duration of the ITI Preceeding a Given Trial

%Load logfile for example session
fname =...
    fullfile('W:','Data','Raw','behavior','mjs20',...
    'mjs20_913','20250214_g0','mjs_tactile2visual_T2Vtest_170b-Rig1-I_mjs20_913_T_20250214_0.mat');
load(fname); %Load log structure into workspace

%Example trial and block indices
trialIdx = 3;
blockIdx = 2;

%Current and previous trial start-time
priorTrial = log.block(blockIdx).trial(trialIdx-1); %Data struct for prior trial
currTrial = log.block(blockIdx).trial(trialIdx); %Data struct for current trial

%Previous trial end-time (VR iteration following reward, when VR goes blank)
priorTrialEndIter = priorTrial.iterations; %Index of last VR iteration in prior trial
priorTrialEndTime = priorTrial.start + priorTrial.time(priorTrialEndIter); %Index last iteration into time vector and add trial start time to get session-time

%ITI is the time elapsed between prior trial end and current trial start
ITI = currTrial.start - priorTrialEndTime;

