% load('W:\Data\Raw\behavior\mjs20\mjs20_37\20260414_g0\mjs_tactile2visual_T2V_251027_170b-Rig1-I_mjs20_37_T_20260414_0.mat'); %Old world
% load('W:\Data\Raw\behavior\mjs20\mjs20_37\20260415_g0\mjs_tactile2visual_T2V_251027_170b-Rig1-I_mjs20_37_T_20260415_0.mat'); %Modified to include fewer total triangles
load('W:\Data\Raw\behavior\mjs20\mjs20_05\20260415_g0\mjs_tactile2visual_T2V_260318_170b-Rig1-I_mjs20_05_T_20260415_0.mat'); %shaping level 6

frameRate = arrayfun(@(idx) 1/mean(diff(log.block(1).trial(idx).time)), 1:numel(log.block(1).trial));
towersTrial = arrayfun(@(idx) ~isempty([log.block(1).trial(idx).cuePos{:}]), 1:numel(log.block(1).trial));

frameHz.towers = mean(frameRate(towersTrial));
frameHz.puffs = mean(frameRate(~towersTrial));

figure; 
plot(frameRate); hold on;
ylim([0, 70]);
xlim([0,numel(log.block(1).trial)+1]);
xlabel('Trial number');
ylabel('Frame rate (Hz)')
title('m37-260415');

