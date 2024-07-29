% For testing
dirs = getDirStruct('mjs_tactile2visual');
subjects = loadExperData("mjs20_572", dirs);

subIdx = subjects.ID=="mjs20_572";
sessionIdx = [subjects(subIdx).sessions.session_date]==datetime('16-Jul-2024');
S = subjects(subIdx);

sessions = S.sessions(sessionIdx);
trials = S.trials(sessionIdx); %unpack
trialData = S.trialData(sessionIdx); %unpack
trialSubset = true(size(trials.right));

%Get psychometric
nBins = 4;
sessions.psychometric.all = getPsychometricCurve( trialData, trials, trialSubset, nBins );

%Get psychometric from GLM
subject = struct('ID', S.ID, 'sessions', sessions,'trialData', trialData, 'trials', trials);
subject = analyzeTaskStrategy2(subject, nBins);

%Get Colors for Plotting
colors = setPlotColors('mjs_tactile2visual');

saveDir = fullfile(dirs.results,'session-summary');

figs = fig_session_summary( subject, 'glm2', colors );
save_multiplePlots(figs,saveDir);
%GLM1 towers_puffs_bias
saveDir = fullfile(dirs.results,'session-summary','glm1');
figs = fig_session_summary( subject, 'glm1', colors );
save_multiplePlots(figs,saveDir);
