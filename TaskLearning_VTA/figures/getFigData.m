function figData = getFigData( dirs, expData, mat_file, figID, params )

switch figID
    
    case 'FOV_mean_projections'
       
        % Initialize file
        fname = mat_file.figData.fovProj(expData.sub_dir);
        if ~exist(fname,'file')
            figData.meanProj    = []; %One cell for each session
            figData.roi_dir     = [];
            save(fname,'-struct','figData');
        else
            figData = load(mat_file.figData.fovProj(expData.sub_dir));
        end
        
        % Calculate or re-calculate mean projection from substacks
        if params.figs.fovProj.calcProj
           % Get path to required data
           [figData.meanProj, figData.varProj] = calc_meanProj(expData.reg_path);
           figData.roi_dir = fullfile(dirs.data, expData.sub_dir, expData.roi_dir);
           save(fname,'-struct','figData','-append'); %Save mean projection, etc. for later use
        end    
end