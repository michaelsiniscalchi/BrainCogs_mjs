%Set paths
close all;
experiment = 'mjs_tactile2visual'; %If empty, fetch data from all experiments

dirs = addGitRepo(getRoots(),'General','TankMouseVR','U19-pipeline-matlab','BrainCogs_mjs');
dirs.data = fullfile(dirs.root,'tactile2visual','data');
dirs.results = fullfile(dirs.root,'tactile2visual','results',experiment);
dirs.summary = fullfile(dirs.root,'tactile2visual','summary',experiment);
dirs.intake = fullfile(dirs.root,'tactile2visual','results');

create_dirs(dirs.results, dirs.summary, dirs.intake);

matfiles = struct(...
    'behavioralData', @(SubjectID) fullfile(dirs.results, [SubjectID,'.mat']),... %Define function later
    'motorTrajectory', fullfile(dirs.summary,'Motor_Trajectory.mat'));

%Hyperparams
dataSource = struct(...
    'remoteLogData',        false,...
    'experimentData',      true,...
    'localLogData',         false,...
    'DataJoint',            false);
exe = struct(...
    'reloadData',           true,...
    'updateExperData',      false,...
    'motor_trajectory',     false,...
    'model_strategy',       false);
plots = struct(...
    'motor_trajectory',                 false,...
    'collision_locations',              false,...
    'trial_duration',                   false,...
    'longitudinal_performance',         false,...
    'longitudinal_glm',                 false,...
    'group_performance',                false);

%Subject info
if exe.reloadData
    clearvars subjects;
    subjects = struct(...
        'ID',       {...
        "mjs20_22","mjs20_23","mjs20_24",... %
        "mjs20_25","mjs20_26",...
        "mjs20_103","mjs20_105"...
        },...
        'rigNum',   {...
        "Bezos2", "Bezos2","Bezos2",...
        "Bezos2", "Bezos2"...
        "Bezos2", "Bezos2",...
        },...
        'startDate', datetime('16-May-2023'),...
        'experimenter', 'mjs20',...
        'waterType', 'Milk');

    %Switch data source
    if dataSource.remoteLogData && ~dataSource.experimentData
        setupDataJoint_mjs();
        subjects = getRemoteVRData( experiment, subjects );
        %Append Labels for Session Types
        % subjects = getSessionLabels_TaskLearning_VTA(subjects);
        %Exclude warmup trials from correct rate for Sensory and Alternation Mazes
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



%Save experimental data to matfiles by subject
if exe.updateExperData && ~dataSource.experimentData
    fnames = updateExperData(subjects,dirs);
end

%Save Stats for View-Angle and X-Trajectories
if exe.motor_trajectory
    trajectories = getTrajectoryDist(subjects);
    save(matfiles.motorTrajectory,'-struct','trajectories');
end

if exe.model_strategy
    subjects = analyzeTaskStrategy(subjects);
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

if plots.trial_duration
    saveDir = fullfile(dirs.results,'Trial Duration');
    figs = fig_longitudinal_trialDuration( subjects,experiment );
    save_multiplePlots(figs,saveDir);
    clearvars figs;
end

%Plot Individual Longitudinal Performance
if plots.longitudinal_performance
    %Full performance data for each subject
    saveDir = fullfile(dirs.results,'Performance');
    vars = {{'pCorrect_congruent','pCorrect_conflict'},...
        {'pCorrect','bias'},...
        {'maxCorrectMoving_congruent','maxCorrectMoving_conflict'},...
        {'median_velocity','pOmit'},{'pStuck','median_pSkid'}};
    for i = 1:numel(vars)
        figs = fig_longitudinal_performance(subjects,vars{i},colors);
        save_multiplePlots(figs,saveDir);
        clearvars figs;
    end
end

if plots.longitudinal_glm
    %Longitudinal
    saveDir = fullfile(dirs.results,'GLM_TowerSide_PuffSide');
    vars = {'towers','puffs','bias'};
    figs = fig_longitudinal_glm( subjects, vars, 'glm1', colors );
    save_multiplePlots(figs,saveDir);

    %     saveDir = fullfile(dirs.results,'GLM_TowerSide_PuffSide_priorChoice');
    %     vars = {'towers','puffs','priorChoice','bias'};
    %     figs = fig_longitudinal_glm( subjects, vars, 'glm2', colors );
    %     save_multiplePlots(figs,saveDir);
    %
    %     saveDir = fullfile(dirs.results,'GLM_TowerSide_PuffSide_priorChoice');
    %     vars = {'towers','puffs','priorRewChoice','priorUnrewChoice','bias'};
    %     figs = fig_longitudinal_glm( subjects, vars, 'glm3', colors );
    %     save_multiplePlots(figs,saveDir);
    %     clearvars figs;
end

%Plot Group Learning Curve
if plots.group_performance
    saveDir = fullfile(dirs.results,'Group Performance');
    figs = fig_periswitch_sensory(subjects, 'pCorrect');
    save_multiplePlots(figs,saveDir);
    clearvars figs;
    vars = ["pCorrect","pCorrect_conflict","maxCorrectMoving_conflict"];
    params = struct('nSensory',4,'nAlternation','min','colors',colors);
    for i = 1:numel(vars)
        figs(i) = fig_periswitch_alternation(subjects,vars(i),params);
    end
    save_multiplePlots(figs,saveDir);
    clearvars figs;
end

% ------------- NOTES ------
% 230727 Began using 35 psi for M102 to help with ball control
% 230731 Same for M105
% 230801 Same for All
%
%230905 Cleaned up BehavioralState flow

