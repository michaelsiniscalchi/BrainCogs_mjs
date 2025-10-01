function [ calculate, summarize, figures, mat_file, params ] = params_Tactile2Visual_VTA( dirs, expData, options )

%Handle input args
if nargin<3
    options = struct();
end

%% CALCULATE OR RE-CALCULATE RESULTS
% calculate.behavior                  = true;
calculate.combined_data             = false;  %Combine relevant behavioral and imaging data in one MAT file ; truncate if necessary
calculate.cellF                     = false; %Extract cellf and neuropilf from ROIs, excluding overlapping regions and extremes of the FOV
calculate.dFF                       = false; %Calculate dF/F, with optional neuropil subtraction
calculate.align_signals             = false; %Interpolate dF/F and align to behavioral events
calculate.trial_average_dFF         = false; %dF/F averaged over specified subsets of trials
calculate.encoding_model            = false; %Encoding model


%% SUMMARIZE RESULTS
summarize.trialAvgFluo              = true;
summarize.selectivity               = false;
summarize.stats                     = false; %Descriptive stats; needed for all summary plots
summarize.table_experiments         = false;
summarize.table_descriptive_stats   = false;
summarize.table_comparative_stats   = false;

%% PLOT RESULTS

% Behavior
figures.session_summary                 = false;
% Imaging 
figures.FOV_mean_projection             = false;
figures.timeseries                      = false; %Plot all timeseries for each session
% Combined
figures.trial_average_dFF               = false;  %Overlay traces for distinct choices, outcomes, and rules (CO&R)

figures.encoding_observedVsPredicted    = false;   %Stimulus kernel estimates, observed vs. predicted dFF, etc.
figures.encoding_predictedTrialAvg      = false;   %Stimulus kernel estimates, observed vs. predicted dFF, etc.
figures.encoding_eventKernels           = false;   %Stimulus kernel estimates, observed vs. predicted dFF, etc.
figures.encoding_coefficients           = false;   %Stimulus kernel estimates, observed vs. predicted dFF, etc.

figures.heatmap_modulation_idx          = false;  %Heatmap of selectivity idxs for COR for each session

% Summary
figures.summary_behavior                = false;    %Summary of descriptive stats, eg, nTrials and {trials2crit, pErr, oErr} for each rule
figures.summary_selectivity_heatmap     = false;     %Heatmap of time- or position-locked selectivity
figures.summary_selectivity_histogram   = false;     %Histogram of time-locked selectivity
figures.summary_modulation				= false;    %Box/line plots of selectivity results grouped by rule/learning stage for comparison

% Validation
figures.validation_ROIs                 = false;
figures.validation_alignment            = false;

%Amend params based on input options
if isfield(options, 'calculate') %For setting params from SLURM, etc.
    for f = string(fieldnames(options.calculate))'
        calculate.(f) = options.calculate.(f);
    end
end

%Amend params based on input options
if isfield(options, 'summarize') %For setting params from SLURM, etc.
    for f = string(fieldnames(options.summarize))'
        summarize.(f) = options.summarize.(f);
    end
end

if isfield(options, 'figures') %For setting params from SLURM, etc.
    for f = string(fieldnames(options.figures))'
        figures.(f) = options.figures.(f);
    end
end

%General data for cellular fluorescence 
calculate.fluorescence = false;
if any([calculate.cellF, calculate.dFF,... 
        calculate.align_signals,...
        calculate.trial_average_dFF,...
		calculate.encoding_model])
	calculate.fluorescence = true;
end

%Load data for main figures
figures.encoding_model = false;
if any([figures.encoding_observedVsPredicted,... 
        figures.encoding_predictedTrialAvg,...
        figures.encoding_eventKernels,...
		figures.encoding_coefficients])
	figures.encoding_model = true;
end

%% PATHS TO SAVED DATA
%By experiment
mat_file.stack_info         = @(idx) fullfile(dirs.data,expData(idx).sub_dir,'stack_info.mat');
mat_file.img_beh            = @(idx) fullfile(dirs.results,expData(idx).sub_dir,'img_beh.mat');
mat_file.results.cellFluo   = @(idx) fullfile(dirs.results,expData(idx).sub_dir,'results.mat');
mat_file.results.encoding   = @(idx) fullfile(dirs.results,expData(idx).sub_dir,'encoding.mat');
%Aggregated by subject
mat_file.summary.trialAvgFluo    = @(subjID) fullfile(dirs.summary, subjID, 'trialAvgFluo.mat');
mat_file.summary.psyTrack        = @(subjID) fullfile(dirs.summary, subjID, 'psyTrack.mat');
mat_file.summary.encoding        = @(subjID) fullfile(dirs.summary, subjID, 'encoding.mat');

%Aggregated across subjects
mat_file.summary.behavior       = fullfile(dirs.summary,'behavior.mat');
mat_file.summary.imaging        = fullfile(dirs.summary,'imaging.mat');
mat_file.summary.selectivity    = fullfile(dirs.summary,'selectivity.mat');
mat_file.stats                  = fullfile(dirs.summary,'summary_stats.mat');
mat_file.validation             = fullfile(dirs.summary,'validation.mat');
%Figure Data
mat_file.figData.fovProj        = @(sessionID) fullfile(dirs.figures,'FOV projections',['figData-',sessionID,'.mat']); %Directory created in code block for figure

%% HYPERPARAMETERS FOR ANALYSIS

% Behavior
params.behavior.nBins_psychometric = 4; %number of bins (+1 for 0-cues)

% Cellular fluorescence calculations
params.fluo.exclBorderWidth     = 10; %For calc_cellF: n-pixel border of FOV to be excluded from analysis

% Interpolation and alignment
params.align.timeWindow     = [-3 7]; %Also used for bootavg, etc.
params.align.positionWindow = [-30 300]; %Also used for bootavg, etc.
params.align.interdt        = []; %Query intervals for interpolation in seconds (must be <0.5x original dt; preferably much smaller.)
params.align.binWidth       = 10; %Spatial bins in cm

% Trial averaging
params.bootAvg.timeWindow       = params.align.timeWindow; %Also used for bootavg, etc.
params.bootAvg.positionWindow   = params.align.positionWindow; %Also used for bootavg, etc.
params.bootAvg.dsFactor         = 1; %Downsample from interpolated rate of 1/params.interdt
params.bootAvg.nReps            = 1000; %Number of bootstrap replicates
params.bootAvg.CI               = 90; %Confidence interval as decimal
params.bootAvg.subtractBaseline = false;
params.bootAvg.smoothWin        = 6; %Smoothing window in samples for peak finding, averaging, etc.
params.bootAvg.avgWin           = 2; %Time interval (s) post-cue, or surrounding peak, for averaging
params.bootAvg   = specBootAvgParams(params.bootAvg); %params.bootAvg.trigger(1:3) = "start","firstcue","outcome", etc...

% Encoding model
params.encoding.dsFactor            = 1; %Downsample from interpolated rate of 1/params.interdt
params.encoding.bSpline_nSamples    = 150; %N time points for spline basis set
params.encoding.bSpline_degree      = 3; %degree of each (Bernstein polynomial) term
params.encoding.bSpline_df          = 21; %number of terms:= order + N internal knots

params.encoding.bSpline_position_binWidth   = 1; %bin width in cm
params.encoding.bSpline_position_degree     = 3; %degree for position splines
params.encoding.bSpline_position_df         = 5; %number of terms for position splines

params.encoding.modelName           = 'FM';
params.encoding                     = specEncodingParams(params.encoding);

%% SUMMARY STATISTICS
colors = getFigColors();
params.summary.trialAvg = specSummaryTrialAvgParams(colors);

%% GLOBAL SETTINGS
params.figs.all.colors = colors;

%% FIGURE: MEAN PROJECTION FROM EACH FIELD-OF-VIEW
params.figs.fovProj.projType        = 'varProj'; %'meanProj' or 'varProj'
params.figs.fovProj.calcProj        = true; %Calculate or re-calculate projection from substacks for each trial (time consuming).
params.figs.fovProj.blackLevel      = 20; %As percentile 20
params.figs.fovProj.whiteLevel      = 97; %As percentile 99.7
c = [zeros(256,1) linspace(0,1,256)' zeros(256,1)];
params.figs.fovProj.colormap        = c;
params.figs.fovProj.overlay_ROIs    = true; %Overlay outlines of ROIs
params.figs.fovProj.overlay_npMasks = false; %Overlay outlines of neuropil masks

%% FIGURE: CELLULAR FLUORESCENCE TIMESERIES FOR ALL NEURONS
p = params.figs.all; %Global figure settings: colors structure, etc.
% [p.expIDs, p.cellIDs] = list_exampleCells('timeseries');
p.expIDs           = [];
p.cellIDs          = [];
p.trialMarkers     = true;
p.trigTimes        = 'cueTimes'; %'cueTimes' or 'responseTimes'
p.ylabel_cellIDs   = true;
p.spacing          = 10; %Spacing between traces in SD 
p.FaceAlpha        = 0.2; %Transparency for rule patches
p.LineWidth        = 1; %LineWidth for dF/F
p.Color            = struct('correct',colors.correct, 'error', colors.err); %Revise with params.figs.all.colors

params.figs.timeseries = p;
clearvars p;
%% FIGURE: TRIAL-AVERAGED CELLULAR FLUORESCENCE

% -------Trial Averaging: choice, outcome, and rule-------------------------------------------------
% [p.expIDs, p.cellIDs] = list_exampleCells('bootAvg');
p.expIDs     = [];
p.cellIDs    = [];
p.panels = specBootAvgPanels( params.figs );

params.figs.bootAvg = p;
clearvars p

%% FIGURE: Single-unit encoding model

params.figs.encoding.panels = specEncodingPanels( params.figs );
params.figs.encoding.panels_contrast = specEncodingPanels_contrast( params.figs );

%% FIGURE: MODULATION INDEX: CHOICE, OUTCOME, AND RULE

% Heatmaps
params.figs.mod_heatmap.fig_type        = 'heatmap';
params.figs.mod_heatmap.xLabel          = 'Time from sound cue (s)';  % XLabel
params.figs.mod_heatmap.yLabel          = 'Cell ID (sorted)';
params.figs.mod_heatmap.datatips        = true;  %Draw line with datatips for cell/exp ID

params.figs.mod_heatmap.choice_sound.cmap     = flipud(cbrewer('div', 'RdBu', 256));  %[colormap]=cbrewer(ctype, cname, ncol, interp_method)
params.figs.mod_heatmap.choice_sound.color    = c(4,:);  %[colormap]=cbrewer(ctype, cname, ncol, interp_method)

params.figs.mod_heatmap.choice_action.cmap     = flipud(cbrewer('div', 'RdBu', 256));  %[colormap]=cbrewer(ctype, cname, ncol, interp_method)
params.figs.mod_heatmap.choice_action.color    = c(4,:);  %[colormap]=cbrewer(ctype, cname, ncol, interp_method)

params.figs.mod_heatmap.prior_choice.cmap     = flipud(cbrewer('div', 'RdBu', 256));  %[colormap]=cbrewer(ctype, cname, ncol, interp_method)
params.figs.mod_heatmap.prior_choice.color    = c(4,:);  %[colormap]=cbrewer(ctype, cname, ncol, interp_method)

params.figs.mod_heatmap.outcome.cmap    = cbrewer('div', 'PiYG', 256);
params.figs.mod_heatmap.outcome.color   = c(3,:);

params.figs.mod_heatmap.prior_outcome.cmap    = cbrewer('div', 'PiYG', 256);
params.figs.mod_heatmap.prior_outcome.color   = c(3,:);

params.figs.mod_heatmap.rule_SL.cmap    = [flipud(cbrewer('seq','Reds',128));cbrewer('seq','Greys',128)];
params.figs.mod_heatmap.rule_SL.color   = c(1,:);

params.figs.mod_heatmap.rule_SR.cmap    = [flipud(cbrewer('seq','Blues',128));cbrewer('seq','Greys',128)];
params.figs.mod_heatmap.rule_SR.color   = c(2,:);




