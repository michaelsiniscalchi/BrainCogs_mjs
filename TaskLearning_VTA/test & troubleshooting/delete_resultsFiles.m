function delete_resultsFiles( search_filter, options )

% Set path
dirs = getRoots();
addGitRepo(dirs,'General','iCorre-Registration','BrainCogs_mjs','TankMouseVR','U19-pipeline-matlab',...
    'datajoint-matlab','compareVersions','GHToolbox');
addpath(genpath(fullfile(dirs.code, 'mym', 'distribution', 'mexa64')));

% Session-specific metadata
[dirs, expData] = expData_Tactile2Visual_VTA(dirs);
expData = expData(contains({expData(:).sub_dir}', search_filter)); %Filter by data-directory name, etc.

% Set parameters for analysis
[calculate, ~, figures, mat_file, ~] = params_Tactile2Visual_VTA(dirs, expData);
expData = get_imgPaths(dirs, expData, calculate, figures); %Append additional paths for imaging data if required by 'calculate'


for i=1:numel(expData)
    if exist(mat_file.stack_info(i),"file") && options.stack_info
        disp(['Deleting ' mat_file.stack_info(i)]);
    end
    delete(mat_file.stack_info(i));
    
    if exist(mat_file.img_beh(i),"file") && options.img_beh
        disp(['Deleting ' mat_file.img_beh(i)]);
    end
    delete(mat_file.img_beh(i));

    if exist(mat_file.results.cellFluo(i),"file") && options.results
        disp(['Deleting ' mat_file.results.cellFluo(i)]);
    end
    delete(mat_file.results.cellFluo(i));

end