
options.figures = struct('FOV_mean_projection', false, 'session_summary', true, 'trial_average_dFF', false, 'encoding_model', false);
figures_Tactile2Visual_VTA('240222', options);

%%
options.figures = struct('FOV_mean_projection', false, 'session_summary', true, 'trial_average_dFF', false, 'encoding_model', false);
figures_Tactile2Visual_VTA('240222', options);

%%
subjectID ='mjs20_913'; %'250212-m913-maze7'
sessionDate = '2025-02-12';
AnalysisNotebook_Tactile2Visual_behavior(subjectID, sessionDate);

%%
% search_filter ='250702-m713-maze7';
% search_filter ='250206-m913-maze7';
clearvars;
search_filter ='250212-m913-maze7';
options.calculate = struct('combined_data',false,'align_signals', false,...
    'trial_average_dFF', false,'encoding_model', true);
options.figures = struct('encoding_coefficients',true, 'encoding_cv', true);
Analyze_Tactile2Visual_VTA(search_filter, options);

%%
clearvars;
search_filter ='250905-m477-maze8';
options.calculate = struct('combined_data',false,'dFF',false,'align_signals', true,...
    'trial_average_dFF', false,'encoding_model', false);
Analyze_Tactile2Visual_VTA(search_filter, options);

options.figures=struct('encoding_eventKernels', false,...
    'encoding_coefficients', false, 'encoding_cv', true);
figures_Tactile2Visual_VTA(search_filter, options); %In a separate script for brevity.

%%
clearvars;
search_filter ='250905-m477-maze8';
options.figures=struct('encoding_eventKernels', false,...
    'encoding_coefficients', false, 'encoding_cv', true);
figures_Tactile2Visual_VTA(search_filter, options); %In a separate script for brevity.

%%
%Figures
clearvars;
search_filter ='250212-m913-maze7';
options.figures=struct('encoding_eventKernels', false,...
    'encoding_coefficients', false, 'encoding_cv', true);
figures_Tactile2Visual_VTA(search_filter, options); %In a separate script for brevity.

%% Summary
subjectID = "m913";
options.summarize = struct(...
    "behavior",false,"trialAvgFluo",false,"pickle2mat",false,...
    "encoding",true,"neuroBehCorr",false);
options.figures = struct(...
    "summary_neuroBehCorr", false, "encoding_eventKernelsByCell", true);

Summarize_Tactile2Visual_VTA( subjectID, options )

%% Psytrack
pklfile_psytrack = 'X:\michael\tactile2visual-vta\summary\913_psytrack_all_sessions.pkl';

predictor_names = ["leftTowers","rightTowers","leftPuffs","rightPuffs"];
struct_out = psytrack_pickle2Mat(pklfile_psytrack, predictor_names);