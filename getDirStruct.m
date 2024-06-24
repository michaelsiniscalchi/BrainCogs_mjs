function dirs = getDirStruct(experiment) 

dirs = getRoots();
addGitRepo(dirs,'General','iCorre-Registration','BrainCogs_mjs','TankMouseVR','U19-pipeline-matlab',...
    'datajoint-matlab','compareVersions','GHToolbox');
addpath(genpath(fullfile(dirs.code, 'mym', 'distribution', 'mexa64')));

dirs.data = fullfile(dirs.root,experiment,'data');
dirs.results = fullfile(dirs.root,experiment,'results');
dirs.summary = fullfile(dirs.root,experiment,'summary');
dirs.intake = fullfile(dirs.root,experiment,'results');

create_dirs(dirs.results, dirs.summary, dirs.intake);