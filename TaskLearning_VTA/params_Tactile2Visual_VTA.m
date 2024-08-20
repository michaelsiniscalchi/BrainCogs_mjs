function [ calculate, summarize, figures, mat_file, params ] = params_Tactile2Visual_VTA( dirs, expData, options )

%Handle input args
if nargin<3
    options = struct();
end

%% CALCULATE OR RE-CALCULATE RESULTS
calculate.combined_data             = false;  %Combine relevant behavioral and imaging data in one MAT file ; truncate if necessary
calculate.cellF                     = false; %Extract cellf and neuropilf from ROIs, excluding overlapping regions and extremes of the FOV
calculate.dFF                       = false; %Calculate dF/F, with optional neuropil subtraction
calculate.align_signals             = false; %Interpolate dF/F and align to behavioral events
calculate.trial_average_dFF         = false; %dF/F averaged over specified subsets of trials
calculate.encoding_model            = true; %Encoding model


%% SUMMARIZE RESULTS
summarize.trialDFF              = false;
summarize.imaging               = false;
summarize.selectivity           = false;

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
figures.trial_average_dFF               = true;  %Overlay traces for distinct choices, outcomes, and rules (CO&R)
figures.time_average_dFF                = false;  %Overlay traces for distinct choices, outcomes, and rules (CO&R)
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

if isfield(options, 'figures') %For setting params from SLURM, etc.
    for f = string(fieldnames(options.figures))'
        figures.(f) = options.figures.(f);
    end
end

calculate.fluorescence = false;
if any([calculate.cellF, calculate.dFF,... 
        calculate.align_signals,...
        calculate.trial_average_dFF,...
		calculate.encoding_model])
	calculate.fluorescence = true;
end

%% PATHS TO SAVED DATA
%By experiment
mat_file.stack_info     = @(idx) fullfile(dirs.data,expData(idx).sub_dir,'stack_info.mat');
mat_file.img_beh        = @(idx) fullfile(dirs.results,expData(idx).sub_dir,'img_beh.mat');
mat_file.results        = @(idx) fullfile(dirs.results,expData(idx).sub_dir,'results.mat');
%Aggregated
mat_file.summary.behavior       = fullfile(dirs.summary,'behavior.mat');
mat_file.summary.imaging        = fullfile(dirs.summary,'imaging.mat');
mat_file.summary.trialAvgDFF    = fullfile(dirs.summary,'trialAvgDFF.mat');
mat_file.summary.selectivity    = fullfile(dirs.summary,'selectivity.mat');
mat_file.stats                  = fullfile(dirs.summary,'summary_stats.mat');
mat_file.validation             = fullfile(dirs.summary,'validation.mat');
%Figure Data
mat_file.figData.fovProj        = fullfile(dirs.figures,'FOV mean projections','figData.mat'); %Directory created in code block for figure

%% HYPERPARAMETERS FOR ANALYSIS

% Behavior
params.behavior.nBins_psychometric = 4;

% Cellular fluorescence calculations
params.fluo.exclBorderWidth     = 10; %For calc_cellF: n-pixel border of FOV to be excluded from analysis

% Interpolation and alignment
params.align.timeWindow     = [-1 5]; %Also used for bootavg, etc.
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
params.bootAvg   = specBootAvgParams(params.bootAvg); %params.bootAvg.trigger(1:3) = "start","firstcue","outcome", etc...

% Encoding model
params.encoding.dsFactor         = 1; %Downsample from interpolated rate of 1/params.interdt

% ------- Single-unit decoding -------
% params.decode.decode_type     = ...
%     {'choice_sound','choice_action','prior_choice','prior_choice_action',...
%     'outcome','prior_outcome','rule_SL','rule_SR'}; %MUST have same number of elements as rows in trialSpec. Eg, = {'choice','outcome','rule_SL','rule_SR'}
% params.decode.trialSpec       = params.bootAvg.trialSpec; %Spec for each trial subset for comparison (conjunction of N fields from 'trials' structure.)

% [p.decodeType, p.trialSpec]    = list_trialSpecs('bootAvg'); %Spec for each trial subset for comparison (conjunction of N fields from 'trials' structure.)
% p.dsFactor        = params.bootAvg.dsFactor; %Downsample from interpolated rate of 1/params.interdt
% p.nReps           = params.bootAvg.nReps; %Number of bootstrap replicates
% p.nShuffle        = 1000; %Number of shuffled replicates
% p.CI              = 95; %params.bootAvg.CI; %Confidence interval as percentage
% p.sig_method      = 'shuffle';  %Method for determining chance-level: 'bootstrap' or 'shuffle'
% p.sig_duration    = 1;  %Number of consecutive seconds exceeding chance-level
% p.t0              = 0; %params.behavior.timeWindow(1);  %Use eg params.behavior.timeWindow(1), or 0 for trigger time
% params.decode = p;
% clearvars p;

%% SUMMARY STATISTICS
colors = getFigColors();
params.summary.trialAvg = specSummaryTrialAvgParams(colors);

%% GLOBAL SETTINGS
params.figs.all.colors = colors;

%% FIGURE: MEAN PROJECTION FROM EACH FIELD-OF-VIEW
params.figs.fovProj.calcProj        = true; %Calculate or re-calculate projection from substacks for each trial (time consuming).
params.figs.fovProj.blackLevel      = 30; %As percentile 20
params.figs.fovProj.whiteLevel      = 99.7; %As percentile 99.7
c = [zeros(256,1) linspace(0,1,256)' zeros(256,1)];
params.figs.fovProj.colormap        = c;
params.figs.fovProj.overlay_ROIs    = true; %Overlay outlines of ROIs
params.figs.fovProj.overlay_npMasks = false; %Overlay outlines of neuropil masks
% params.figs.fovProj.expIDs          = [];
% params.figs.fovProj.expIDs = {...
%     '220404 M411 T7 1Chan';...
%     };
% 
% % For plotting only selected cells
% % params.figs.fovProj.cellIDs{numel(expData)} = []; %Initialize
% params.figs.fovProj.cellIDs(restrictExpIdx({expData.sub_dir},params.figs.fovProj.expIDs)) = {... % One {} per session, containing cellIDs
%     {'001','002','003','004'};...
%     };

% %% FIGURE: RAW BEHAVIOR
% params.figs.behavior.window = params.behavior.timeWindow; 
% params.figs.behavior.colors = struct('red',cbrew.red,'blue',cbrew.blue,'green',cbrew.green);

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

%% FIGURE: TIME-AVERAGED CELLULAR FLUORESCENCE (CO-PLOT SPECIFIED CELLS)

% -------Trial Averaging: All trials performed-------------------------------------------------
params.figs.timeAvg = params.figs.timeseries;
%params.figs.timeAvg.expIDs              = [];
params.figs.timeAvg.cellIDs             = [];
params.figs.timeAvg.colors              = colors; %Choice: left/hit/sound vs right/hit/sound
params.figs.timeAvg.verboseLegend       = false;
params.figs.timeAvg.panels              = [];
params.figs.timeAvg.panels.title        = 'All Trials Performed';
params.figs.timeAvg.panels.lineStyle    = {'-'};

%% FIGURE: MODULATION INDEX: CHOICE, OUTCOME, AND RULE

% % Single-unit plots
% p                       = params.figs.all; %Get global colors, etc.
% p.fig_type              = 'singleUnit';
% [p.decodeType, p.trialSpec]    = list_trialSpecs('bootAvg');
% p.panels = list_panelSpecs('bootAvg',params); %Get variables and plotting params for each figure panel
% [p.expIDs,p.cellIDs]    = list_exampleCells('bootAvg'); %Same cells used for trial average and decode
% % p.expIDs = []
% % p.cellIDs = [];
% p.shading               = 'bootstrap'; %'shuffle' or 'bootstrap'
% p.CI                    = params.bootAvg.CI; 
% 
% params.figs.decode_single_units = p;
% clearvars p ax;

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
