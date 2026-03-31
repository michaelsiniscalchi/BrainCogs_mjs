
options.figures = struct('FOV_mean_projection', false, 'session_summary', true, 'trial_average_dFF', false, 'encoding_model', false);
figures_Tactile2Visual_VTA('240222', options);

%%
options.figures = struct('FOV_mean_projection', false, 'session_summary', true, 'trial_average_dFF', true, 'encoding_model', false);
figures_Tactile2Visual_VTA('240222', options);

%%
clearvars
subjectID ='mjs20_39'; %'250212-m913-maze7'
sessionDate = '2026-03-12';
% AnalysisNotebook_Tactile2Visual_behavior(subjectID);
AnalysisNotebook_Tactile2Visual_behavior(subjectID, sessionDate);

%%
clearvars;
% search_filter ='250206-m913-maze7';
%search_filter ='240305-m175-maze7';
search_filter ='260312-m39-maze10';
options.calculate = struct('combined_data',false,'align_signals', false,...
    'trial_average_dFF', false, 'encoding_model', false, 'encoding_stats', false);
options.figures = struct('FOV_mean_projection', false, 'session_summary', false,...
    'trial_average_dFF', true, 'encoding_predictedTrialAvg', false,...
    'encoding_coefficients',false,...
    'encoding_eventKernels',false, 'encoding_cv', false);

% Analyze_Tactile2Visual_VTA(search_filter, options);
figures_Tactile2Visual_VTA(search_filter, options);

%% Sync Test
clearvars;
search_filter ='250905-m477-maze8';
options.calculate = struct('combined_data',false,'dFF',false,'align_signals', false,...
    'trial_average_dFF', false,'encoding_model', false);
Analyze_Tactile2Visual_VTA(search_filter, options);

options.figures = struct('trial_average_dFF', true,'encoding_eventKernels', false,...
    'encoding_coefficients', false, 'encoding_cv', false);
figures_Tactile2Visual_VTA(search_filter, options); %In a separate script for brevity.

%%
%Figures
clearvars;
search_filter ='240305-m175-maze7';
options.figures=struct('encoding_eventKernels', true,...
    'encoding_coefficients', false, 'encoding_cv', false);
figures_Tactile2Visual_VTA(search_filter, options); %In a separate script for brevity.

%%
clearvars;
search_filter ='250905-m477-maze8';
options.figures=struct('encoding_eventKernels', false,...
    'encoding_coefficients', false, 'encoding_cv', true);
figures_Tactile2Visual_VTA(search_filter, options); %In a separate script for brevity.



%% Summary
clearvars
% subjectID = "m713";
subjectID = "m913";
options.summarize = struct(...
    "behavior", false, "trialAvgFluo", false, "pickle2mat", false,...
    "encoding", false, "neuroBehCorr", false);
options.figures = struct(...
    "summary_neuroBehCorr", true,...
    "encoding_eventKernelsByPerformance", false,... 
    "encoding_eventKernelsByPsyTrack", false,...
    "summary_population_nbCorr", false);

Summarize_Tactile2Visual_VTA( subjectID, options )

%NEXT: plot pSignificant against session number and/or perf/psytrack
%variable

%% Psytrack
pklfile_psytrack = 'X:\michael\tactile2visual-vta\summary\913_psytrack_all_sessions.pkl';

predictor_names = ["leftTowers","rightTowers","leftPuffs","rightPuffs"];
struct_out = psytrack_pickle2Mat(pklfile_psytrack, predictor_names);

