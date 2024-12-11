%%% ALL FIGURES FOR STUDY ON CELL TYPES RECORDED DURING FLEXIBLE SENSORIMOTOR BEHAVIOR
%
% AUTHOR: MJ Siniscalchi 190701; separated from 'analyze_RuleSwitching.m' 200213
%
% NOTE: Use header only if run independently of 'analyze_RuleSwitching.m'
%
%---------------------------------------------------------------------------------------------------
function figures_Tactile2Visual_VTA( search_filter, options )

% Set path
dirs = getRoots();
addGitRepo(dirs,'General','iCorre-Registration','BrainCogs_mjs','TankMouseVR','U19-pipeline-matlab',...
    'datajoint-matlab','compareVersions','GHToolbox');
addpath(genpath(fullfile(dirs.code, 'mym', 'distribution', 'mexa64'))); %For DataJoint

% Session-specific metadata
[dirs, expData] = expData_Tactile2Visual_VTA(dirs);
expData = expData(contains({expData(:).sub_dir}', search_filter)); %Filter by data-directory name, etc.

% Set parameters for analysis
[calculate, ~, figures, mat_file, params] = params_Tactile2Visual_VTA(dirs, expData, options);
expData = get_imgPaths(dirs, expData, calculate, figures); %Append additional paths for imaging data if required by 'calculate'

colors = getFigColors();

%% FIGURES - BEHAVIOR

if figures.session_summary
    saveDir = fullfile(dirs.figures,'session-summary');
    for i = 1:numel(expData)
        subject = load(mat_file.img_beh(i), 'ID', 'sessions', 'trialData', 'trials'); %Leave out logs
        figs = fig_session_summary( subject, 'glm2', colors );
        save_multiplePlots(figs,saveDir);

         %GLM1 towers_puffs_bias
        figs = fig_session_summary( subject, 'glm1', colors );
        save_multiplePlots(figs, saveDir);
    end
end

%% FIGURES - IMAGING

% Generate Mean Projection Image for each field-of-view
if figures.FOV_mean_projection
    save_dir = fullfile(dirs.figures,'FOV projections');   %Figures directory: cellular fluorescence
    create_dirs(save_dir); %Create dir for these figures
    
    % Calculate or re-calculate mean projection from substacks
    figData = getFigData(dirs, expData, mat_file,'FOV_projections',params);
    figData.roi_dir = fullfile(dirs.data, expData.sub_dir, expData.roi_dir);

    % Generate figures: mean projection with optional ROI and/or neuropil masks
    figs = gobjects(numel(expData),1); %Initialize figures
    for i = 1:numel(expData)
        figs(i) = fig_meanProj(figData, params.figs.fovProj); %***WIP***
        figs(i).Name = [expData(i).sub_dir, '-', params.figs.fovProj.projType];
        if isfield(params.figs.fovProj, "cellIDs") && ~isempty(params.figs.fovProj.cellIDs)
            figs(i).Name = [figs(i).Name,'-ROIs'];
        end
    end
    save_multiplePlots(figs,save_dir,'pdf'); %Save figure
end

% Plot all timeseries from each experiment
if figures.timeseries
    %Initialize graphics array and create directories
    expIdx = restrictExpIdx({expData.sub_dir},params.figs.timeseries.expIDs); %Restrict to specific sessions, if desired
    save_dir = fullfile(dirs.figures,'Cellular fluorescence');   %Figures directory: cellular fluorescence
    create_dirs(save_dir); %Create dir for these figures
    figs = gobjects(numel(expIdx),1); %Initialize figures
    %Generate figures
    for i = 1:numel(expIdx)
        imgBeh = load(mat_file.img_beh(expIdx(i)),'dFF','t','trials','trialData','cellID'); %Load data
        imgBeh.sessionID = expData(i).sub_dir;
        %         params.figs.timeseries.cellIDs = ["001","005","006","008"];
        figs(i) = fig_plotAllTimeseries(imgBeh,params.figs.timeseries);         %Generate fig
    end
    %Save batch as FIG, PNG, and SVG
    save_multiplePlots(figs,save_dir,'pdf');
    clearvars figs;
end

%% FIGURES - SINGLE UNIT ANALYSES

% Plot trial-averaged dF/F
if figures.trial_average_dFF
    for i = 1:numel(expData)
        %Load data
        load(mat_file.results.cellFluo(i),'bootAvg','cellID');
        save_dir = fullfile(dirs.figures,'Cellular fluorescence', expData(i).sub_dir);   %Figures directory: single units
        create_dirs(save_dir); %Create dir for these figures
        %Save figure for each cell plotting all combinations of choice x outcome
        comparisons = unique([params.figs.bootAvg.panels.comparison],'stable');

        for j = 1:numel(comparisons)
            panelIdx = find([params.figs.bootAvg.panels.comparison]==comparisons(j));
            event = [params.figs.bootAvg.panels(panelIdx(1)).trigger];
            figs = plot_trialAvgDFF(bootAvg.(event), cellID, expData(i).sub_dir,...
                params.figs.bootAvg.panels(panelIdx));
            save_multiplePlots(figs, save_dir); %save as FIG and PNG
        end
        clearvars figs
    end
end

% Plot encoding model results
if figures.encoding_model
    for i = 1:numel(expData)
        %Load data
        expID = expData(i).sub_dir;
        glm = load(mat_file.results.encoding(i),'bootAvg','kernel','session','cellID');
        img = load(mat_file.results.cellFluo(i),'bootAvg');
        save_dir = fullfile(dirs.figures,'Encoding model', 'Observed vs Predicted dFF', expID);
        comparisons = unique([params.figs.encoding.panels.comparison],'stable');
        for j = 1:numel(comparisons)
            panelIdx = find([params.figs.encoding.panels.comparison]==comparisons(j));
            panels = params.figs.encoding.panels(panelIdx);
            trigger = [params.figs.encoding.panels(panelIdx(1)).trigger];
            figs = fig_observedVsPredictedDFF(...
                img.bootAvg.(trigger), glm.bootAvg.(trigger), glm.cellID, expID, panels);
            save_multiplePlots(figs, save_dir); %save as FIG and PNG
        end
        clearvars figs

        save_dir = fullfile(dirs.figures,'Encoding model', 'Predicted dFF', expData(i).sub_dir);
        comparisons = unique([params.figs.bootAvg.panels.comparison],'stable');
        for j = 1:numel(comparisons)
            panelIdx = find([params.figs.bootAvg.panels.comparison]==comparisons(j));
            event = [params.figs.bootAvg.panels(panelIdx(1)).trigger];
            figs = plot_trialAvgDFF(glm.bootAvg.(event), glm.cellID, glm.session,...
                params.figs.bootAvg.panels(panelIdx));
            save_multiplePlots(figs, save_dir); %save as FIG and PNG
        end
        clearvars figs

        %Plot Response Kernels
        save_dir = fullfile(dirs.figures,'Encoding model', 'Response kernels', expID);   %Figures directory: single units
        create_dirs(save_dir); %Create dir for these figures
        panels = params.figs.encoding.panels;
        panels = panels(cellfun(@(C) ~isempty(C), {panels.varName})); %Remove non-event variables
        for j = 1:numel(panels)
            figs = plot_eventKernel(glm, panels(j));
            save_multiplePlots(figs, save_dir); %save as FIG and PNG
        end
        clearvars figs

    end
end

% Heatmap of selectivity traces: one figure each for choice, outcome, and rule
if figures.summary_selectivity_heatmap
    %Load data
    S = load(mat_file.summary.selectivity);
    for rule = ["sensory","alternation"]
        figs = heatmap_summarySelectivity(S.(rule), join(["selectivity-heatmap-" rule],''), params.summary.trialAvg);
        save_multiplePlots(figs,save_dir); %save as FIG and PNG
        clearvars figs;
    end
end

% Histogram of trial-wise selectivity: one figure per session
if figures.summary_selectivity_histogram
    %Figures directory: selectivity
    save_dir = fullfile(dirs.figures,'Selectivity');
    %Load data
    S = load(mat_file.summary.selectivity);
    for rule = ["sensory","alternation"]
        for field = ["meanSelectivity","meanPreference"]
            figs = histogram_summaryPreference(S.(rule), field,... histogram_summaryPreference(selectivity_struct, field, figName, params)
                join([field  rule "histogram"],'-'), ["all", "last"], params.summary.trialAvg);
            save_multiplePlots(figs,save_dir); %save as FIG and PNG
            clearvars figs;
        end
    end
end