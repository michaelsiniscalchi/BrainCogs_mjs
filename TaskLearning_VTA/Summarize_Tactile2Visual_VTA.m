function Summarize_Tactile2Visual_VTA( subjectID, options )

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
expData = expData([expData.subjectID]==subjectID); %Filter by subject

% Set parameters for analysis
[~, summarize, figures, mat_file, params] = params_Tactile2Visual_VTA(dirs, expData, options);

% Generate directory structure
create_dirs(dirs.summary,dirs.figures);

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

%Summarize Longitudinal Trial-Averaged Data by Subject
if summarize.trialAvgFluo
   
    for i = 1:numel(expData)
        Beh(i) = load(mat_file.img_beh(i),'sessions','trialData','trials'); 
        Img(i) = load(mat_file.results.cellFluo(i));
        S = load(mat_file.results.cellFluo(i));
    end
    S = aggregateTrialBoot(Img, Beh);
    
    save(mat_file.summary.trialAvgFluo(subjectID),"-struct","S");
    clearvars S;
end