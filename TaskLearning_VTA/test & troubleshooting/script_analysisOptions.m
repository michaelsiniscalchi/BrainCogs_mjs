
options.figures = struct('FOV_mean_projection', false, 'session_summary', true, 'trial_average_dFF', false, 'encoding_model', false);
figures_Tactile2Visual_VTA('240222', options);

%%
options.figures = struct('FOV_mean_projection', false, 'session_summary', true, 'trial_average_dFF', false, 'encoding_model', false);
figures_Tactile2Visual_VTA('240222', options);

%%
search_filter ='018';
AnalysisNotebook_Tactile2Visual_behavior(search_filter);

%%

search_filter ='250212-m913-maze7';
% options.calculate = struct('align_signals', true, 'trial_average_dFF', true,'encoding_model', true);
options.calculate = struct('combined_data',true);
% options.figures.encoding_model = true;
Analyze_Tactile2Visual_VTA(search_filter, options);


%%
%Figures
search_filter ='250404';
options.figures.encoding_coefficients = true;
% options.figures.trial_average_dFF = true;
figures_Tactile2Visual_VTA(search_filter, options); %In a separate script for brevity.
