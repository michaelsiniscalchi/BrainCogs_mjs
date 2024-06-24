function AnalysisNotebook_Tactile2Visual_behavior(search_filter)

if nargin<1
    search_filter = '';
end

%Set paths
experiment = 'mjs_tactile2visual'; %If empty, fetch data from all experiments

% dirs = getRoots();
% addGitRepo(dirs,'General','iCorre-Registration','BrainCogs_mjs','TankMouseVR','U19-pipeline-matlab',...
%     'datajoint-matlab','compareVersions','GHToolbox');
% addpath(genpath(fullfile(dirs.code, 'mym', 'distribution', 'mexa64')));
% 
% dirs.data = fullfile(dirs.root,'tactile2visual','data');
% dirs.results = fullfile(dirs.root,'tactile2visual','results',experiment);
% dirs.summary = fullfile(dirs.root,'tactile2visual','summary',experiment);
% dirs.intake = fullfile(dirs.root,'tactile2visual','results');
% 
% create_dirs(dirs.results, dirs.summary, dirs.intake);

dirs = getDirStruct(experiment);

matfiles = struct(...
    'behavioralData', @(SubjectID) fullfile(dirs.results, [SubjectID,'.mat']),... %Define function later
    'motorTrajectory', fullfile(dirs.summary,'Motor_Trajectory.mat'));

%Hyperparams
dataSource = struct(...
    'remoteLogData',        true,...
    'experimentData',       false,...
    'localLogData',         false,...
    'DataJoint',            false);
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
    
    subjects = struct(...
        'ID',       {...
        "mjs20_22","mjs20_23","mjs20_24",... %
        "mjs20_25","mjs20_26",...
        "mjs20_105",...
        "mjs20_018","mjs20_173","mjs20_175","mjs20_177"...
        "mjs20_569","mjs20_570","mjs20_571","mjs20_572"...
        },...
        'rigNum',   {...
        "Bezos2", "Bezos2","Bezos2",...
        "Bezos2", "Bezos2",...
        "Bezos2",...
        "Bezos2", "Bezos2","Bezos2", "Bezos2",...
        "Bezos2", "Bezos2","Bezos2", "Bezos2",...
        },...
        'startDate', datetime('16-May-2023'),...
        'experimenter', 'mjs20',...
        'waterType', 'sucrose');

    %Restrict to specified subject(s)
    subjects = subjects(contains([subjects.ID], search_filter));

    %For testing
    %dirs = getDirStruct('mjs_tactile2visual'); 
    %subjects = loadExperData("mjs20_24", dirs);

    %Switch data source
    if dataSource.remoteLogData && ~dataSource.experimentData
        setupDataJoint_mjs();
%         subjects = getRemoteVRData( experiment, subjects, struct('session_date','2024-06-20') );
        subjects = getRemoteVRData( experiment, subjects);
        %Append Labels for Session Types
        % subjects = getSessionLabels_TaskLearning_VTA(subjects);
        %Exclude warmup trials from correct rate for Main Mazes
        subjects = filterSessionStats(subjects);
    elseif dataSource.DataJoint && ~dataSource.experimentData
        setupDataJoint_mjs();
        for i = 1:numel(subjects)
            key = struct('subject_fullname',char(subjects(i).ID));
            djData = getDBData(key,experiment);
            fields = fieldnames(djData);
            for j=1:numel(fields)
                subjects(i).(fields{j}) = djData.(fields{j});
            end
        end

    elseif dataSource.experimentData
        subjects = loadExperData({subjects.ID},dirs);
    elseif dataSource.localLogData
    end
end

%Save Stats for View-Angle and X-Trajectories
if exe.motor_trajectory
    trajectories = getTrajectoryDist(subjects);
    save(matfiles.motorTrajectory,'-struct','trajectories');
end

if exe.model_strategy
    subjects = analyzeTaskStrategy2(subjects);
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
if plots.longitudinal_performance
    %Full performance data for each subject
    saveDir = fullfile(dirs.results,'Performance');
    vars = {...
        ["pCorrect_congruent", "pCorrect_conflict"],...
        ["pCorrect", "bias"],...
        ["pLeftCues", "bias"]};

    params = struct('colors', colors, 'lineWidth', 1.5,...
        'markerSize', 6,'omitShaping','true');
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

if plots.longitudinal_glm
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

