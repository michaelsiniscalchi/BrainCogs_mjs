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
if summarize.behavior
    for i = 1:numel(expData)
        load(mat_file.img_beh(i),'sessions');
        S(i) = sessions;
        clearvars sessions
    end
    [sessions, sessions_vect]  = filterImgSessions(S); %Structure containing bootAvg stats as terminal fields, with cellIDs and behavioral session stats
    save(mat_file.summary.behavior(subjectID),"-struct","sessions_vect","-v7.3");
    save(mat_file.summary.behavior(subjectID),"sessions","-v7.3");
    clearvars S sessions sessions_vect;
end

%Summarize Longitudinal Trial-Averaged Data by Subject
if summarize.trialAvgFluo
    for i = 1:numel(expData)
        Beh(i) = load(mat_file.img_beh(i),'sessions','trialData','trials');
        Img(i) = load(mat_file.results.cellFluo(i));
    end
    S = aggregateTrialBoot(Img, Beh); %Structure containing bootAvg stats as terminal fields, with cellIDs and behavioral session stats
    save(mat_file.summary.trialAvgFluo(subjectID),"-struct","S","-v7.3");
    clearvars S;
end

%Save Psytrack results in MAT file
if summarize.pickle2mat
    pklfile_psytrack =...
        fullfile(dirs.summary,subjectID,[subjectID{1}(2:end),'_psytrack_all_sessions.pkl']);
    predictor_names = ["leftTowers", "rightTowers", "leftPuffs", "rightPuffs", "bias"];
    psyStruct = psytrack_pickle2Mat(pklfile_psytrack, predictor_names);
    for i=1:numel(expData)
        S = load(mat_file.img_beh(i),'sessions');
        img_date(i) = S.sessions.session_date;
    end

    %Verify that all imaging sessions are tracked
    missing = img_date(~ismember(img_date,psyStruct.session_date));
    if ~isempty(missing)
        warning("No psytrack data for these sessions:")
        disp(missing);
    end
    save(mat_file.summary.psyTrack(subjectID),'-struct','psyStruct','-v7.3');

    %Append to session data
    load(mat_file.summary.behavior(subjectID),'sessions');
    sessions = appendPsyTrackWeights(sessions, psyStruct);
    save(mat_file.summary.behavior(subjectID),'sessions','-append');
end
clearvars sessions predictors S f

if summarize.encoding
    fields = ["AUC","AUC_se","peak","peak_se","L2"];
    mdlNames = params.encoding.modelName;
    for i = 1:numel(mdlNames)
        for j = 1:numel(expData)
            sessions(j) = load(mat_file.results.encoding(j, mdlNames(i)));
        end
        [cells, metaData] = summarize_sessions2cells(sessions);
        save(mat_file.summary.encoding(subjectID, mdlNames(i)),'cells','metaData','-v7.3');
    end
end

if summarize.neuroBehCorr
    
    %Load summary data (add one more for trial avg fluo)
    load(mat_file.summary.behavior(subjectID), 'sessions');
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
        
        %Save correlation structures
        save(mat_file.summary.neuroBehCorr(subjectID, mdlNames(i)),'-struct','nbCorr','-v7.3');
        save(mat_file.summary.neuroBehCorr(subjectID, mdlNames(i)),'cells','-append');
    end
end
% clearvars -except img beh expData mat_file params summarize

if figures.summary_neuroBehCorr
    mdlNames = params.encoding.modelName;
    for i = 1:numel(mdlNames)
        load(mat_file.summary.behavior(subjectID),'sessions');
        load(mat_file.summary.encoding(subjectID, mdlNames(i)),'cells');
        save_dir = fullfile(dirs.figures,'Neurobehavioral Summary', subjectID,  mdlNames(i));
        %Longitudinal Plot
        P = params.figs.summaryLongitudinalImgBeh;
        for j = 1:numel(P.panels)
            panelSpec = P.panels(j);
            P.mdlName = mdlNames(i);
            if isfield(cells(1).kernel, panelSpec.encVar(2)) ||...
                    isfield(cells(1).coef, panelSpec.encVar(2))
                figs = fig_summaryPsyTrackEncodingBySession(sessions, cells, panelSpec, P);
                save_multiplePlots(figs, save_dir); %save as FIG and PNG
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

if figures.encoding_model
    %For each model
    mdlNames = params.encoding.modelName;
    for i = 1:numel(mdlNames)
        load(mat_file.summary.encoding(subjectID, mdlNames(i)),'cells','metaData');
        load(mat_file.summary.behavior(subjectID), 'sessions');

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