function [matfiles, dirs, subjects] = AnalysisNotebook_Tactile2Visual_behavior( subjectID, sessionDate )

%Parse inputs
subject.ID = string(subjectID);
key = struct;
if exist("sessionDate","var")
    key.session_date = datestr(sessionDate,'yyyy-mm-dd');
end

%Set paths
experiment = 'mjs_tactile2visual'; %If empty, fetch data from all experiments

dirs = getDirStruct(experiment);

matfiles = struct(...
    'behavioralData', @(SubjectID) fullfile(dirs.results, [SubjectID,'.mat']),... %Define function later
    'motorTrajectory', fullfile(dirs.summary,'Motor_Trajectory.mat'));

%Hyperparams
dataSource = struct(...
    'remoteLogData',        true,...
    'experimentData',       false...
    );
exe = struct(...
    'reloadData',           true,...
    'updateExperData',      true,...
    'motor_trajectory',     false,...
    'model_strategy',       true);
plots = struct(...
    'motor_trajectory',                 false,...
    'collision_locations',              false,...
    'trial_duration',                   false,...
    'longitudinal_performance',         true,...
    'longitudinal_glm',                 true,...
    'session_summary',                  true,...
    'group_performance',                false);

%Subject info
if exe.reloadData
    clearvars subjects;
    
    %Switch data source
    if dataSource.remoteLogData && ~dataSource.experimentData
        setupDataJoint_mjs();
        subjects = getRemoteVRData( experiment, subject, key );
       
        %Exclude warmup trials from stats for Main Mazes
        subjects = filterSessionStats(subjects);

    elseif dataSource.experimentData
        subjects = loadExperData([subjects.ID],dirs);
    end
end

%Save Stats for View-Angle and X-Trajectories
if exe.motor_trajectory
    trajectories = getTrajectoryDist(subjects);
    save(matfiles.motorTrajectory,'-struct','trajectories');
end

if exe.model_strategy
    nBins_psychometric = 4;
    subjects = analyzeTaskStrategy2(subjects, nBins_psychometric);
end

%Save experimental data to matfiles by subject
if exe.updateExperData && ~dataSource.experimentData
    fnames = updateExperData(subjects, dirs);
end

%Get Colors for Plotting
colors = setPlotColors(experiment);

%Plot View-Angle and X-Trajectory for each session
if plots.motor_trajectory
    saveDir = fullfile(dirs.results,'Motor Trajectories');
    create_dirs(saveDir);
    if ~exist('trajectories','var')
        trajectories = load(matfiles.motorTrajectory);
    end
    params.annotation = true;
    figs = fig_motorTrajectory(trajectories,'fiveNumSummary',params);
    save_multiplePlots(figs, saveDir);
    clearvars figs;
end

if plots.collision_locations
    figs = fig_collision_locations(subjects);
    saveDir = fullfile(dirs.results,'Motor Trajectories');
    save_multiplePlots(figs,saveDir);
    clearvars figs;
end

%Plot Individual Longitudinal Performance
if plots.longitudinal_performance && numel(subjects.sessions)>1
    %Full performance data for each subject
    saveDir = fullfile(dirs.results,'Performance');

    params = struct('colors', colors, 'lineWidth', 1.5,...
        'markerSize', 6,'omitShaping','true');
    vars = {...
        ["pCorrect_congruent", "pCorrect_conflict"],... %for presentation
        ["pCorrect_congruent", "pCorrect_conflict", "bias"],... %for assessing criterion
        ["maxmeanAccuracy_congruent", "maxmeanAccuracy_conflict"]};
    for i = 1:numel(vars)
        figs = fig_longitudinal_performance(subjects,vars{i},params);
        save_multiplePlots(figs,saveDir);
        clearvars figs;
    end
end

if plots.session_summary
    saveDir = fullfile(dirs.results,'session-summary');
    for i = 1:numel(subjects)
        %GLM2
        %(nTowersLeft_nTowersRight_nPuffsLeft_nPuffsRight_priorChoice_bias)
        subject = loadExperData(subjects(i).ID, dirs);
        figs = fig_session_summary( subject, 'glm2', colors );
        save_multiplePlots(figs,saveDir);
        %GLM1 towers_puffs_bias
        saveDir = fullfile(dirs.results,'session-summary','glm1');
        subject = loadExperData(subjects(i).ID, dirs);
        figs = fig_session_summary( subject, 'glm1', colors );
        save_multiplePlots(figs,saveDir);
    end
end

if plots.longitudinal_glm && numel(subjects.sessions)>1
    saveDir = fullfile(dirs.results,'GLM_TowerSide_PuffSide');
    vars = {'towers','puffs','bias'};
    figs = fig_longitudinal_glm( subjects, vars, 'glm1', colors );
    save_multiplePlots(figs,saveDir);
% 
%     vars = {'towers','puffs','bias','priorChoice'};
%     figs = fig_longitudinal_glm( subjects, vars, 'glm1', colors );
%     save_multiplePlots(figs,saveDir);

    %All terms
    saveDir = fullfile(dirs.results,'GLM_nTowers_nPuffs');
    vars = {'nTowersLeft','nTowersRight','nPuffsLeft','nPuffsRight','bias'};
    figs = fig_longitudinal_glm( subjects, vars, 'glm2', colors );
    save_multiplePlots(figs,saveDir);

    %Towers/Puffs separately
    vars = {'nTowersLeft','nTowersRight','bias'};
    figs = fig_longitudinal_glm( subjects, vars, 'glm2', colors );
    save_multiplePlots(figs,saveDir);

    vars = {'nPuffsLeft','nPuffsRight','bias'};
    figs = fig_longitudinal_glm( subjects, vars, 'glm2', colors );
    save_multiplePlots(figs,saveDir);

    %Towers/Puffs separately (no priorChoice term)
%     saveDir = fullfile(dirs.results,'GLM_nTowers_nPuffs');
%     vars = {'nTowersLeft','nTowersRight','bias'};
%     figs = fig_longitudinal_glm( subjects, vars, 'glm3', colors );
%     save_multiplePlots(figs,saveDir);
% 
%     vars = {'nPuffsLeft','nPuffsRight','bias'};
%     figs = fig_longitudinal_glm( subjects, vars, 'glm3', colors );
%     save_multiplePlots(figs,saveDir);
end


% ------------- NOTES ------

