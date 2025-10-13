function [ dirs, expData, calculate, summarize, figures, mat_file, params ] =...
    getAnalysisParams_T2V( subjectID, options )

%Handle input args
if nargin<2
    options = struct();
end

% Set path
dirs = getRoots();
addGitRepo(dirs,'General','iCorre-Registration','BrainCogs_mjs','TankMouseVR','U19-pipeline-matlab',...
    'datajoint-matlab','compareVersions','GHToolbox');
addpath(genpath(fullfile(dirs.code, 'mym', 'distribution', 'mexa64')));

% Session-specific metadata
[dirs, expData] = expData_Tactile2Visual_VTA(dirs);
expData = expData(contains({expData.sub_dir}, subjectID)); %Filter by subject

% Set parameters for analysis
[calculate, summarize, figures, mat_file, params] = params_Tactile2Visual_VTA(dirs, expData, options);

% Generate directory structure
create_dirs(dirs.summary, dirs.figures, fullfile(dirs.summary,subjectID)); %subject-specific summary dir

% Begin logging processes
diary(fullfile(dirs.results,['procLog' datestr(datetime,'yymmdd')]));
diary on;
disp(datetime);

%% SETUP PARALLEL POOL FOR FASTER PROCESSING
if isempty(gcp('nocreate'))
    try
        parpool([1 128])
    catch err
        warning(err.message);
    end
end