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

%Summarize Longitudinal Trial-Averaged Data by Subject
if summarize.trialAvgFluo
    for i = 1:numel(expData)
        Beh(i) = load(mat_file.img_beh(i),'sessions','trialData','trials'); 
        Img(i) = load(mat_file.results.cellFluo(i));
    end
    S = aggregateTrialBoot(Img, Beh); %Structure containing bootAvg stats as terminal fields, with cellIDs and behavioral session stats
    create_dirs()
    save(mat_file.summary.trialAvgFluo(subjectID),"-struct","S","-v7.3");
    clearvars S;
end

%Save Psytrack results in MAT file
if summarize.pickle2mat
    pklfile_psytrack =...
        fullfile(dirs.summary,subjectID,[subjectID{1}(2:end),'_psytrack_all_sessions.pkl']);
    predictor_names = ["leftTowers","rightTowers","leftPuffs","rightPuffs"];
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
end
clearvars sessions predictors S f

if summarize.encoding
    fields = ["AUC","AUC_se","peak","peak_se","L2"];
    for i=1:numel(expData)
        sessions(i) = load(mat_file.results.encoding(i),...
            "session_date","cellID","kernel","coef");
    end
    cells = summarize_sessions2cells(sessions);
    save(mat_file.summary.encoding(subjectID),'cells','-v7.3');
end

if summarize.neuroBehCorr
    %Hyperparams
    params.paramNames = ["meanCoef","L2",]; %Scalar estimates from psytrack and encoding model
    params.psyField = ["leftTowers","rightTowers","leftPuffs","rightPuffs"];
    params.imgField = ...
        ["firstLeftTower", "firstRightTower", "firstLeftPuff", "firstRightPuff",...
        "leftTowers","rightTowers","leftPuffs","rightPuffs"];
    params.minN = 5;
    %Load summary data (add one more for trial avg fluo)
    encoding = load(mat_file.summary.encoding(subjectID),'cells');
    psyTrack = load(mat_file.summary.psyTrack(subjectID),...
        'meanCoef','se','session_date');
    [nbCorr, cells] = calcNeuroBehCorr(encoding, psyTrack, params);
    %Save correlation structures
    save(mat_file.summary.neuroBehCorr(subjectID),'-struct','nbCorr','-v7.3');
    save(mat_file.summary.neuroBehCorr(subjectID),'cells','-append');
end
% clearvars -except img beh expData mat_file params summarize

if figures.summary_neuroBehCorr

end