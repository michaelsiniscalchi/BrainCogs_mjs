cd('/jukebox')

search_filter = '250117';

% Set path
dirs = getRoots();
addGitRepo(dirs,'General','iCorre-Registration','BrainCogs_mjs','TankMouseVR','U19-pipeline-matlab',...
    'datajoint-matlab','compareVersions','GHToolbox');
addpath(genpath(fullfile(dirs.code, 'mym', 'distribution', 'mexa64')));

% Session-specific metadata
[dirs, expData] = expData_Tactile2Visual_VTA(dirs);
expData = expData(contains({expData(:).sub_dir}', search_filter)); %Filter by data-directory name, etc.

sessionPath = fullfile(dirs.data, expData.sub_dir);
stackInfo = getRawStackInfo( sessionPath, [], true );

% for Scotty MATLAB script: 
cd('/jukebox/Bezos/michael/_code/General')
