%%% ALL FIGURES FOR STUDY ON VTA-DA NEURONES IMAGED DURING FLEXIBLE SENSORIMOTOR BEHAVIOR
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
if ~exist('options','var')
    options = struct();
end
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
        % comparisons = "first-tower"; %TEMP
        for j = 1:numel(comparisons)
            panelIdx = find([params.figs.bootAvg.panels.comparison]==comparisons(j));
            event = [params.figs.bootAvg.panels(panelIdx(1)).trigger]; %All panels in comparison need to have same trigger
            figs = plot_trialAvgDFF(bootAvg.(event), cellID, expData(i).sub_dir,...
                params.figs.bootAvg.panels(panelIdx));
            save_multiplePlots(figs, save_dir); %save as FIG and PNG
        end
        clearvars figs
    end
end

%Encoding Model
if figures.encoding_model 
    for i = 1:numel(expData)
        %Load data 
        expID = expData(i).sub_dir;
        glm = load(fullfile(dirs.results,expData(i).sub_dir,...
            ['encodingMdl-', params.encoding.modelName]),...
            'modelName','bootAvg','kernel','sessionID','cellID','predictorIdx',...
            'lambda','conditionNum_trace','VIF_trace','corrMatrix');
        % glm = load(mat_file.results.encoding(i),'bootAvg','kernel','sessionID','cellID','predictorIdx');
        img = load(mat_file.results.cellFluo(i),'bootAvg');
        
        %Trial-averaged dF/F: observed vs. predicted
        if figures.encoding_observedVsPredicted
            save_dir = fullfile(dirs.figures,['Encoding model-',glm.modelName],...
                'Observed vs Predicted dFF', expID);
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
        end

        %Trial-averaged dF/F: predicted contrasts, etc
        if figures.encoding_predictedTrialAvg
            save_dir = fullfile(dirs.figures,['Encoding model-',glm.modelName],...
                'Predicted dFF', expData(i).sub_dir);
            comparisons = unique([params.figs.bootAvg.panels.comparison],'stable');
            for j = 1:numel(comparisons)
                panelIdx = find([params.figs.bootAvg.panels.comparison]==comparisons(j));
                event = [params.figs.bootAvg.panels(panelIdx(1)).trigger];
                figs = plot_trialAvgDFF(glm.bootAvg.(event), glm.cellID, glm.sessionID,...
                    params.figs.bootAvg.panels(panelIdx));
                save_multiplePlots(figs, save_dir); %save as FIG and PNG
            end
            clearvars figs
        end

        %Response Kernels
        if figures.encoding_eventKernels
            save_dir = fullfile(dirs.figures,['Encoding model-',glm.modelName],...
                'Response kernels', expID);   %Figures directory: single units
            create_dirs(save_dir); %Create dir for these figures
            panels = params.figs.encoding.panels_contrast;
            panels = panels(cellfun(@(C) ~isempty(C), {panels.varName})); %Remove non-event variables
            for j = 1:numel(panels)
                figs = plot_eventKernel(glm, panels(j));
                %Save by session
                save_multiplePlots(figs, save_dir); %save as FIG and PNG
            end
            clearvars figs
        end

        %All Regression Coefficients for each Session
        if figures.encoding_coefficients
            save_dir = fullfile(dirs.figures,['Encoding model-',glm.modelName],...
                'Session Coefficients', [expID, '-', params.encoding.modelName]);   %Figures directory: single units
            create_dirs(save_dir); %Create dir for these figures
            
            %Get predictors in model (possibly make function for this)
            allPredictors = string(fieldnames(glm.predictorIdx))';
            predictorNames = params.encoding.predictorNames; %To achieve desired order
            predictorNames = predictorNames(ismember(predictorNames, allPredictors)); %Remove predictors not included in model
            predictorNames = [predictorNames,...
                allPredictors(~ismember(allPredictors, predictorNames))]; %Append remaining predictors included in model
            
            figs = gobjects(numel(glm.cellID), 4); %Initialize graphics objects: one for each figure (All, Peak, AUC, Kinematics)
            for j = 1:numel(glm.cellID)
                S = load(fullfile(fileparts(mat_file.results.encoding(i)),...
                    ['encodingMdl_','cell', glm.cellID{j}]));
                figs(j,:) = fig_encodingMdlCoefs(glm, S.mdl, expID, glm.cellID, j, predictorNames, colors);
                save_multiplePlots(figs, save_dir); %save as FIG and PNG
                clearvars figs
            end
        end

        if figures.encoding_cv
            
            figs = gobjects(numel(glm.cellID)); %Initialize graphics objects: one for each figure (All, Peak, AUC, Kinematics)
            for j = 1:numel(glm.cellID)
                load(fullfile(dirs.results,expData(i).sub_dir,...
                    ['encodingMdl-', params.encoding.modelName, '-cell', glm.cellID{j}]),...
                    'mdl');

                figs(j) = fig_encodingMdlCV(glm, mdl, glm.cellID{j}, colors);
                
                save_dir = fullfile(dirs.figures,['Encoding model-',glm.modelName],...
                    'Cross Validation', [expID, '-', params.encoding.modelName]);   %Figures directory: single units
                create_dirs(save_dir); %Create dir for these figures
                save_multiplePlots(figs, save_dir); %save as FIG and PNG
                clearvars figs
            end
        end
    end
end

% Heatmap of selectivity traces: one figure each for choice, outcome, and rule

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