
clearvars;
search_filter ='250905-m477-maze8';
options.calculate = struct('combined_data',true);

dirs = getRoots();
addGitRepo(dirs,'General','iCorre-Registration','BrainCogs_mjs','TankMouseVR','U19-pipeline-matlab',...
    'datajoint-matlab','compareVersions','GHToolbox');
addpath(genpath(fullfile(dirs.code, 'mym', 'distribution', 'mexa64')));

% Session-specific metadata
[dirs, expData] = expData_Tactile2Visual_VTA(dirs);
expData = expData(contains({expData(:).sub_dir}', search_filter)); %Filter by data-directory name, etc.

% Set parameters for analysis
experiment = 'mjs_tactile2visual'; %If empty, fetch data from all experiments
[calculate, summarize, figures, mat_file, params] = params_Tactile2Visual_VTA(dirs, expData, options);

%Check syncing of predictors with behavior times
load(mat_file.results.encoding(1,"FM_noAllCues"), 'X', 'predictorIdx');
load(mat_file.img_beh(1),'t','trialData');
idx = encodingModel.predictorIdx.start(1);
startTimes = trialData.eventTimes.start;

figure;
plot(t, X(:, idx)); hold on;
for i=1:numel(startTimes)
    plot([startTimes(i), startTimes(i)],ylim);
end

%Check syncing of predicted dFF with behavior times
disp();
