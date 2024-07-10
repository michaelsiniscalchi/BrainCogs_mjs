search_filter = '230922';

% Set path
dirs = getRoots();
addGitRepo(dirs,'General','iCorre-Registration','BrainCogs_mjs','TankMouseVR','U19-pipeline-matlab',...
    'datajoint-matlab','compareVersions','GHToolbox');
addpath(genpath(fullfile(dirs.code, 'mym', 'distribution', 'mexa64')));

% Session-specific metadata
[dirs, expData] = expData_Tactile2Visual_VTA(dirs);
expData = expData(contains({expData(:).sub_dir}', search_filter)); %Filter by data-directory name, etc.

% Set parameters for analysis
experiment = 'mjs_tactile2visual'; %If empty, fetch data from all experiments
[calculate, summarize, figures, mat_file, params] = params_Tactile2Visual_VTA(dirs, expData);
expData = get_imgPaths(dirs, expData, calculate, figures); %Append additional paths for imaging data if r

%Load behavioral data and metadata from image stacks
        expData.img_beh = load(mat_file.img_beh(1),...
            'ID','imageHeight','imageWidth','nFrames','trialData','trials','t'); %Load saved data

%Autocorrelogram of puff events vs. time lag (s)
%[acf,lags] = autocorr(y)
eventTimes = [expData.img_beh.trialData.eventTimes.puffs]';
eventTimes = eventTimes(~isnan(eventTimes)); %Exclude NaN
bins = round(eventTimes.*1000); %In 1 millisecond bins
on_times = repmat(bins,1,35)+(0:34); %Expand for 35 ms puff duration

idx = on_times(:); %Bin idx
ts = false(idx(end),1); %Initialize time series
ts(idx) = true; 

[acf,lags] = autocorr(double(ts),'NumLags',1000);

figure; 
plot(lags,acf);
xlabel('Time lag (ms)');
ylabel("Pearson's R");
axis square

%Autocorrelogram of puff events vs. position lag (cm)