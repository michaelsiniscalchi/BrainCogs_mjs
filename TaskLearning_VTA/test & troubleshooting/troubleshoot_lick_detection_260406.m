%Logfile
fname = 'W:\Data\Raw\behavior\mjs20\mjs20_9\20260407_g0\mjs_tactile2visual_T2V_260318_170b-Rig1-I_mjs20_9_T_20260407_0.mat';
load(fname);

blk=1;
i=10;
licks = {log.block(blk).trial(i).licks};
