
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

%Synchronize imaging frames with behavioral time basis
i=1;
        %Load stackInfo from file
            stackInfo = load(fullfile(dirs.data, expData(i).sub_dir,'stack_info.mat'));


        %Run basic behavioral processing for each imaging session
        subject.ID = expData(i).subjectID;
        key.session_date = datestr(stackInfo.startTime,'yyyy-mm-dd');
        if isfield(expData,'session_number') && ~isempty([expData.session_number])
            key.session_number = expData.session_number;
        end
        %Extract basic behavioral data
        behavior = getRemoteVRData( experiment, subject, key );

        %Restrict stats to main maze and exclude specified blocks
        behavior = restrictImgTrials(behavior, expData(i).mainMaze, expData(i).excludeBlock);
        behavior = filterSessionStats(behavior);
        
        %Logistic regression
        behavior = analyzeTaskStrategy2(behavior, params.behavior.nBins_psychometric);

        %Append behavior data to stackInfo
        stackInfo = syncImagingBehavior(stackInfo, behavior);