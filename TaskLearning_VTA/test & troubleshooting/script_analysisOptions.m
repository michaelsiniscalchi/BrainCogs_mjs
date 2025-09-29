
options.figures = struct('FOV_mean_projection', false, 'session_summary', true, 'trial_average_dFF', false, 'encoding_model', false);
figures_Tactile2Visual_VTA('240222', options);

%%
options.figures = struct('FOV_mean_projection', false, 'session_summary', true, 'trial_average_dFF', false, 'encoding_model', false);
figures_Tactile2Visual_VTA('240222', options);

%%
subjectID ='mjs20_25';
% sessionDate = '2023-06-08';
% AnalysisNotebook_Tactile2Visual_behavior( subjectID, sessionDate );
AnalysisNotebook_Tactile2Visual_behavior( subjectID );

%%

search_filter ='m33'; %m42 m517 m477 m478 m650
options.calculate = struct('align_signals', true, 'trial_average_dFF', true,'encoding_model', false);
% options.summarize = struct('trialDFF', true);
% options.figures.encoding_model = true;
Analyze_Tactile2Visual_VTA(search_filter, options);

%%
% search_filter ='250702-m713-maze7';
search_filter ='250212-m913-maze7';
options.calculate = struct('align_signals', false, 'trial_average_dFF',  false,'encoding_model', true);
% options.summarize = struct('trialDFF', true);
% options.figures.encoding_model = true;
Analyze_Tactile2Visual_VTA(search_filter, options);

%%
%Figures
search_filter ='250212-m913-maze7';
options.figures=struct('encoding_eventKernels',false,'encoding_coefficients', true);
figures_Tactile2Visual_VTA(search_filter, options); %In a separate script for brevity.

%% Summary
subjectID = "mjs20_913";
options.summarize = struct();
Summarize_Tactile2Visual_VTA( subjectID, options )

%% Psytrack
pklfile_psytrack = 'X:\michael\tactile2visual-vta\summary\913_psytrack_all_sessions.pkl';
predictor_names = ["leftTowers","rightTowers","leftPuffs","rightPuffs"];
struct_out = psytrack_pickle2Mat(pklfile_psytrack, predictor_names);