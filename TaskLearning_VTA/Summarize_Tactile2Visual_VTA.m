function Summarize_Tactile2Visual_VTA( subjectID, options )

%Handle input args
if nargin<2
    options = struct();
end

% Set paths
[dirs, hostname] = getRoots();

if strcmp(hostname, 'PNI-1S7LK74') %desktop
    addGitRepo(dirs,'General','iCorre-Registration','BrainCogs_mjs','TankMouseVR','U19-pipeline-matlab',...
        'datajoint-matlab','compareVersions','GHToolbox');
    addpath(genpath(fullfile('C:','Experiments','mym-mariadbconn','distribution','mexw64')));
else
    addGitRepo(dirs,'General','iCorre-Registration','BrainCogs_mjs','TankMouseVR','U19-pipeline-matlab',...
        'datajoint-matlab','compareVersions','GHToolbox');
    addpath(genpath(fullfile('/jukebox','braininit','Shared',...
        'mym-modified-linux-rhel9-compiled-globally', 'mym', 'distribution', 'mexa64')));
end

% Session-specific metadata
subjectID = string(subjectID);
[dirs, expData] = expData_Tactile2Visual_VTA(dirs);
expData = expData(contains({expData.sub_dir}, subjectID)); %Filter by subject

% Set parameters for analysis
[~, summarize, figures, mat_file, params] = params_Tactile2Visual_VTA(dirs, expData, options);

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

%Summarize Behavior by Subject
if summarize.imgBehavior
    for i = 1:numel(expData)
        load(mat_file.img_beh(i),'sessions');
        S(i) = sessions;
        clearvars sessions
    end
    [sessions, sessions_vect]  = filterImgSessions(S); %Structure containing stats vector as terminal fields, later with cellIDs and imaging stats
    save(mat_file.summary.imgBehavior(subjectID),"-struct","sessions_vect","-v7.3");
    save(mat_file.summary.imgBehavior(subjectID),"sessions","-v7.3");
    clearvars S sessions sessions_vect;
end

if summarize.allBehavior
    %Get all behavior sessions
    setupDataJoint_mjs();
    subject.ID = unique([expData(:).subjectID]);
    behavior = getRemoteVRData( subject, struct() );
    %Exclude warmup trials from stats for Main Mazes
    behavior = filterSessionStats(behavior, ["tactile","visual"], false);
    % idx = ismember([behavior.sessions.taskRule], ["visual","tactile"]); %Include only main rules (not shaping)
    %Logistic Regression to analyze strategy
    behavior = analyzeTaskStrategy(behavior, params.behavior.nBins_psychometric);
    % FUTURE: PsyTrack analysis

    %Save MAT file with all session data
    imgDates =  datetime(...
        string(cellfun(@(C) C(1:6), {expData.sub_dir}, 'UniformOutput', false)),...
        "InputFormat","yyMMdd");
    sessionIdx = ismember([behavior.sessions.session_date],imgDates);
    [behavior.sessions.isImgSession] = deal(false);
    [behavior.sessions(sessionIdx).isImgSession] = deal(true);
    save(mat_file.summary.behavior(subjectID),'-struct','behavior','-v7.3');
end

%Summarize Longitudinal Trial-Averaged Fluorescence by Subject
if summarize.trialAvgFluo
    for i = 1:numel(expData)
        % Beh(i) = load(mat_file.img_beh(i),'sessions','trialData','trials');
        Img(i) = load(mat_file.results.cellFluo(i));
    end
    S = aggregateTrialBoot(Img); %Structure containing bootAvg stats as terminal fields, with cellIDs and behavioral session stats
    save(mat_file.summary.trialAvgFluo(subjectID),"-struct","S","-v7.3");
    clearvars S;
end

%Save Psytrack results in MAT file
if summarize.pickle2mat
    pklfile_psytrack =...
        fullfile(dirs.summary,subjectID,[subjectID{1}(2:end),'_psytrack_all_sessions.pkl']);
    predictor_names = ["leftTowers", "rightTowers", "leftPuffs", "rightPuffs", "bias"];
    psyTrack = psytrack_pickle2Mat(pklfile_psytrack, predictor_names);

    %Verify that all imaging sessions are tracked
    behavior = load(mat_file.summary.behavior(subjectID),'sessions');
    imgIdx = [behavior.sessions.isImgSession];
    imgDate = [behavior.sessions(imgIdx).session_date];
    missing = imgDate(~ismember(imgDate, psyTrack.session_date));
    if ~isempty(missing)
        warning("No psytrack data for these sessions:")
        disp(missing);
    end
    
    %Append to behavior summary
    save(mat_file.summary.behavior(subjectID),'psyTrack','-append');

    %Append to imaging sessions
    load(mat_file.summary.imgBehavior(subjectID),'sessions');
    sessions = appendPsyTrackWeights(sessions, psyTrack);
    save(mat_file.summary.imgBehavior(subjectID),'sessions','-append');
end
clearvars sessions predictors S f

if summarize.encoding
    mdlNames = params.encoding.modelName;
    loadVars = {'session_date','coef','kernel','pValues','pSignificant','alpha',...
        'cellID','termIdx','eventVars','kinematicVars'};
    for i = 1:numel(mdlNames)
        for j = 1:numel(expData)
            sessions(j) = load(mat_file.results.encoding(j, mdlNames(i)), loadVars{:});
        end
        [cells, metaData] = summarize_sessions2cells(sessions);
        population = summarize_popBySession(sessions);

        save(mat_file.summary.encoding(subjectID, mdlNames(i)),'cells','population','metaData','-v7.3');
    end
end

if summarize.neuroBehCorr
    
    %Load summary data (add one more for trial avg fluo)
    load(mat_file.summary.imgBehavior(subjectID), 'sessions');
    mdlNames = params.encoding.modelName;

    %Hyperparams
    params.paramNames = ["meanCoef","AUC"]; %Scalar estimates from psytrack and encoding model
    params.behField = ... %TEMP***
        ["psyTrack_leftTowers_meanCoef","psyTrack_rightTowers_meanCoef",...
        "psyTrack_leftPuffs_meanCoef","psyTrack_rightPuffs_meanCoef",...
        "psyTrack_diffTowers_meanCoef","psyTrack_diffPuffs_meanCoef",...
        "psyTrack_bias_meanCoef",...
        "pCorrect", "pCorrect_congruent", "pCorrect_conflict",...
        "pLeftTowers","pLeftPuffs"];
    params.min_nSessions = 5;

    for i = 1:numel(mdlNames)
        load(mat_file.summary.encoding(subjectID, mdlNames(i)),'cells','metaData');    
        params.imgField = [metaData.cueVars', metaData.outcomeVars'];
        [nbCorr, cells] = calcNeuroBehCorr(cells, sessions, params);
        %***NEXT: Incorporate pSignificant into nbCorr***
        
        %Save correlation structures
        save(mat_file.summary.neuroBehCorr(subjectID, mdlNames(i)),'-struct','nbCorr','-v7.3');
        save(mat_file.summary.neuroBehCorr(subjectID, mdlNames(i)),'cells','-append');
    end
end
% clearvars -except img beh expData mat_file params summarize

%% Figures

if figures.summary_performance
    %Full performance data for each subject
    saveDir = fullfile(dirs.figures,'Performance');
    load(mat_file.summary.behavior(subjectID),'sessions');
    vars = {["pCorrect_congruent", "pCorrect_conflict"]}; %other fields from sessions struct can be included
    figParams = params.figs.summary_performance;
    for i = 1:numel(vars)
        %Indicating all imaging sessions
        figs(1) = fig_summary_performance(subjectID, sessions, vars{i}, figParams);
        for j = 1:numel(expData)
            figParams.sessionDate = datetime(expData(j).sub_dir(1:6),"InputFormat","yyMMdd");
            figs(j+1) = fig_summary_performance(subjectID, sessions, vars{i}, figParams);
        end
        save_multiplePlots(figs,saveDir);
        clearvars figs;
    end
end

%PsyTrack Weights Across All Sessions
if figures.summary_psyTrack
    save_dir = fullfile(dirs.figures,'PsyTrack');
    load(mat_file.summary.behavior(subjectID), 'psyTrack', 'sessions');
    fig = fig_summaryPsytrackBySession( psyTrack, sessions, subjectID, params.figs.all ); %
    save_multiplePlots(fig, save_dir); %save as FIG and PNG
end

if figures.summary_neuroBehCorr
    mdlNames = params.encoding.modelName;
    load(mat_file.summary.imgBehavior(subjectID),'sessions');
    for i = 1:numel(mdlNames)
        load(mat_file.summary.encoding(subjectID, mdlNames(i)),'cells','population');
        save_dir = fullfile(dirs.figures,'Neurobehavioral Summary', subjectID,  mdlNames(i));
        %Plot pSignificant for each variable, with session summary

        %Plot nSignificant vs session number as heatmap
        %ADD subjectID to sessions struct and figure name!!
        fig = fig_encodingPSignificantHeatmap(population, sessions, subjectID);
        save_multiplePlots(fig, save_dir); %save as FIG and PNG

        %Longitudinal Plot
        P = params.figs.summaryLongitudinalImgBeh;
        for j = 1:numel(P.panels)
            panelSpec = P.panels(j);
            P.mdlName = mdlNames(i);
            if isfield(cells(1).kernel, panelSpec.encVar(2)) ||...
                    isfield(cells(1).coef, panelSpec.encVar(2))
                %By Cell
                % figs = fig_summaryPsyTrackEncodingBySession(sessions, cells, panelSpec, P);
                % save_multiplePlots(figs, save_dir); %save as FIG and PNG
                
                %Proportion of cells significant
                if isfield(population.pSignificant, panelSpec.encVar(2))
                    fig = fig_summaryEncodingPSigBySession(sessions, population, panelSpec, P);
                    save_multiplePlots(fig, save_dir); %save as FIG and PNG
                end

            end
        end
    end

    %Next, for trial Averaged Fluo as well...
end

%**DEVO** (to be incorporated into prior block)
if figures.summary_population_nbCorr
    P = params.figs.summaryLongitudinalImgBeh;
    mdlNames = params.encoding.modelName;
    for i = 1:numel(mdlNames)
        load(mat_file.summary.neuroBehCorr(subjectID, mdlNames(i)), 'meanCoef_AUC');
        save_dir = fullfile(dirs.figures,'Neurobehavioral Summary', subjectID,  mdlNames(i));
        P.mdlName = mdlNames(i);

        %Summary histogram across cells (rho for each nb correlation)
        for j = 1:numel(P.panels)
            panelSpec = P.panels(j);
            if isfield(meanCoef_AUC, panelSpec.behVar) && isfield(meanCoef_AUC.(panelSpec.behVar), panelSpec.encVar(2))
                    figs = fig_populationNeuroBehCorr(meanCoef_AUC, panelSpec, P);
                save_multiplePlots(figs, save_dir); %save as FIG and PNG
            end
        end
    end
end


if figures.trial_avg_dFF

    %Load data from all sessions
    bootStruct = load(mat_file.summary.trialAvgFluo(subjectID));
    cellIDs = bootStruct.cellIDs;
    bootStruct = rmfield(bootStruct,'cellIDs');
    expIDs = string(cellfun(@(C) C(1:6),{expData.sub_dir},'UniformOutput',false));
    %Behavioral data for reference
    load(mat_file.summary.behavior(subjectID),'sessions');
    
    %Save directory
    save_dir = fullfile(dirs.figures,'Cellular fluorescence', subjectID);
    create_dirs(save_dir); %Create dir for these figures

    if figures.summary_bootAvg
        comparisons = unique([params.figs.summaryBootAvg.panels.comparison],'stable');
        % comparisons = ["cueRegion-zeroCues-cueType"];%DEVO

        for j = 1:numel(comparisons)

            %Isolate set of panels for each figure
            panelIdx = find([params.figs.summaryBootAvg.panels.comparison]==comparisons(j));
            event = [params.figs.summaryBootAvg.panels(panelIdx(1)).trigger]; %All panels in comparison need to have same trigger
            %Exclude panels with no signal (eg, nTrials==0)
            panelIdx = filterBootPanels(params.figs.summaryBootAvg.panels, panelIdx, bootStruct.(event));
            %Generate figures
            if ~isempty(panelIdx)
                %One or more figure per session (all cells)
                % for k = 1:numel(expData)
                %     figs = fig_trialAvgDFF_summaryBySession(  bootStruct.(event),...
                %         k, expData(k).sub_dir, cellIDs,...
                %         params.figs.summaryBootAvg.panels(panelIdx),...
                %         params.figs.summaryBootAvg);
                %     save_multiplePlots(figs, save_dir); %save as FIG and PNG
                %     clearvars figs
                % end

            end
        end
    end

    %One figure per cell (all sessions)
    if figures.summary_bootAvg_longitudinal
        %Save directory
        save_dir = fullfile(dirs.figures,'Cellular fluorescence', subjectID, 'By Cell Across Sessions');
        create_dirs(save_dir); %Create dir for these figures

        P = params.figs.summaryBootAvgLongitudinal;
        comparisons = unique([P.panels.comparison],'stable');
        % comparisons = ["cueRegion-zeroCues-cueType"];%DEVO

        for j = 1:numel(comparisons)

            %Isolate set of panels for each figure
            panelIdx = find([P.panels.comparison]==comparisons(j));
            event = [P.panels(panelIdx(1)).trigger]; %All panels in comparison need to have same trigger
            %Exclude panels with no signal (eg, nTrials==0)
            panelIdx = filterBootPanels(P.panels, panelIdx, bootStruct.(event));
            %Generate figures
            for k = 1:numel(panelIdx)
                for kk = 1:numel(cellIDs)
                    cellIdx = find(cellIDs==cellIDs(kk));
                    figs(kk) = fig_trialAvgDFF_summaryByCell(...
                        bootStruct.(event),...
                        cellIdx, cellIDs(kk),...
                        sessions,...
                        P.panels(panelIdx(k)),...
                        P);
                end
                save_multiplePlots(figs, save_dir); %save as FIG and PNG
                clearvars figs
            end
        end
    end
end

if figures.encoding_model
    %For each model
    mdlNames = params.encoding.modelName;
    for i = 1:numel(mdlNames)
        load(mat_file.summary.encoding(subjectID, mdlNames(i)),'cells','pSignificant','metaData');
        load(mat_file.summary.imgBehavior(subjectID), 'sessions');

        if figures.encoding_hypothesisTest
            
        end

        if figures.encoding_eventKernelsByPerformance
            varNames = string(fieldnames(cells(1).kernel));
            %Overlay session dates for all variables, sorted by pCorrect
            for j = 1:numel(varNames)
                disp(['Plotting response kernels for ' char(varNames(j))]);
                save_dir = fullfile(dirs.figures,strjoin(['Encoding model-', mdlNames(i)],''),...
                    subjectID, strjoin(['Response kernels--', varNames(j)],''));

                figs = plot_eventKernel_byPerformance(cells, sessions, varNames(j));
                save_multiplePlots(figs, save_dir);
            end
        end
        
        if figures.encoding_eventKernelsByPsyTrack
            encodingVars = metaData.cueVars';         
            psyVars = ["psyTrack_leftTowers_meanCoef","psyTrack_rightTowers_meanCoef",...
                "psyTrack_leftPuffs_meanCoef","psyTrack_rightPuffs_meanCoef","psyTrack_bias_meanCoef"];

            %Overlay session dates for all variables, sorted by pCorrect
            for j = 1:numel(encodingVars)
                disp(['Plotting response kernels for ' char(encodingVars(j))]);
                save_dir = fullfile(dirs.figures,strjoin(['Encoding model-', mdlNames(i)],''),...
                    subjectID, strjoin(['Response kernels--', encodingVars(j)],''));
                for sortBy = psyVars
                    figs = plot_eventKernel_byBehVar( cells, sessions, encodingVars(j), sortBy );
                    save_multiplePlots(figs, save_dir);
                end
            end
        end
    end
end