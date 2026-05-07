function dirs = getDirStruct(experiment) 

%Add Git repositories
[dirs, host] = getRoots();
addGitRepo(dirs,'General','iCorre-Registration','BrainCogs_mjs','TankMouseVR','U19-pipeline-matlab',...
    'datajoint-matlab','compareVersions','GHToolbox');

%Add path to appropriate mym distribution
if any(strcmp(host, {'spockmk2', 'scotty.pni.princeton.edu'})) %Linux
    % addpath(genpath(fullfile(dirs.code, 'mym', 'distribution', 'mexa64')));
    addpath(genpath(fullfile('/jukebox','braininit','Shared',...
    'mym-modified-linux-rhel9-compiled-globally', 'mym', 'distribution', 'mexa64')));
else %Windows
    addpath(genpath(fullfile('C:','Experiments', 'mym-mariadbconn', 'distribution', 'mexw64'))); %Hard path for now...
    addpath(genpath(fullfile(dirs.code, 'mym', 'distribution', 'mexw64')));
end

dirs.data = fullfile(dirs.root,experiment,'data');
dirs.results = fullfile(dirs.root,experiment,'results');
dirs.summary = fullfile(dirs.root,experiment,'summary');
dirs.intake = fullfile(dirs.root,experiment,'results');

create_dirs(dirs.results, dirs.summary, dirs.intake);