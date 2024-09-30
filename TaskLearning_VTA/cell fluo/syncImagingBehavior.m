function stackInfo = syncImagingBehavior(stackInfo, behavior)

%% Obtain ViRMEN time for each I2C packet

%Construct vector of VR times from I2C packets
vrTime = zeros(numel(stackInfo.I2C.iteration),1); %ViRMEn time stamps
for i = 1:numel(vrTime)
    %Extract block/trial/iteration idxs from I2C packets
    blockIdx = stackInfo.I2C.blockIdx(i);
    trialIdx = stackInfo.I2C.trialIdx(i);
    iter = stackInfo.I2C.iteration(i);
    vrTime(i) = getTrialIterationTime( behavior.logs, blockIdx, trialIdx, iter );
    if isnan(vrTime(i))
    disp();
    end
end

%Method 2: gives slightly different values (on order of 10e-4 s)
% sessionTimeMat = get_trial_iteration_time_matrix(behavior.logs); %Session time matrix from U19 Pipeline; Columns are Time, Block, Trial, Iteration
% for i = 1:numel(vrTime)
%     vrTimeMask = ... %Seems very time-consuming
%         all(sessionTimeMat(:,2:4) == [blockIdx trialIdx iter], 2);
%     vrTime(i) = sessionTimeMat(vrTimeMask, 1);
% end

%% Assign one timestamp to each frame
%Initialize
frameNum = unique(stackInfo.I2C.frameNumber); %Unique frame numbers
meanTime = zeros(size(frameNum)); %ViRMEn time
stackInfo.t = zeros(sum(stackInfo.nFrames),1); %Iterpolated ViRMEn time for each frame in stack

%Assign mean value of multiple timestamps per frame figure; plot(vrTime==vrTime2);
for i = 1:numel(frameNum)
    frIdx = stackInfo.I2C.frameNumber==frameNum(i);
        meanTime(i) = mean(vrTime(frIdx)); %Assign using mean time value from multiple packets
end

% %Diagnostic plot 1
% nanTime = NaN(sum(stackInfo.nFrames),1);
% nanTime(frameNum) = meanTime;
% figure; plot(1:length(nanTime),nanTime,'.');
% ylabel('Time (s)');
% xlabel('Frame number');

%Remove timestamps preceeded by missing values
%   Rationale: Each timestamp contains an error equal to the duration of the associated iteration;
%       accordingly, "long" iterations > 1 frame in duration are unreliable for sychronization
missing = ~ismember(1:sum(stackInfo.nFrames),frameNum); %Idxs of frames missing I2C data
missing(end) = 0; %Assign last frame as end of run in case session ends with missing frames
priorMissIdx = find(diff([0,missing])==-1); %First frame following each run of missing data
exclIdx = ismember(frameNum,priorMissIdx); %Idx for time values to exclude
frameNum = frameNum(~exclIdx);
meanTime = meanTime(~exclIdx);

% %Diagnostic plot 2
% nanTime = NaN(sum(stackInfo.nFrames),1);
% nanTime(frameNum) = meanTime;
% figure; plot(1:length(nanTime),nanTime,'.');
% ylabel('Time (s)');
% xlabel('Frame number');

%Interpolate missing time values
% stackInfo.t = interp1(frameNum, meanTime, frameNum(1):frameNum(1)+sum(stackInfo.nFrames)-1);
stackInfo.t = interp1(frameNum, meanTime, frameNum(1):frameNum(end),...
    'linear')'; %Truncate to avoid extrapolation


% %Troubleshooting plot 3
% missing(priorMissIdx) = true;
% figure; plot(t); hold on; plot(find(missing),t(missing),'*');
% ylabel('Time (s)');
% xlabel('Frame number');
% legend({'VR Time','Missing Data'})

% --- Notes --------------------
%  [stackInfo.I2C.frameNumber(1:20) stackInfo.I2C.iteration(1:20)]
%       -often, multiple iterations per frame...with ViRMEn running @100-120Hz, there should be ~3-4
%       -also, many gaps where no I2C data are sent:
%           K>> unique(diff(frameNum))'
%           ans =
%               1     2     3     4    13    14    15    16    22    23    41
%
% %Diagnostic plot 4
% for i = 1:numel(priorMissIdx)
%     idx = find(stackInfo.I2C.frameNumber==priorMissIdx(i),1,'last');
%     bkIdx = stackInfo.I2C.blockIdx(idx);
%     trIdx = stackInfo.I2C.trialIdx(idx);
%     iter = stackInfo.I2C.iteration(idx);
%     trial(i) = behavior.logs.block(bkIdx).trial(trIdx);
%     virmenTime(i) = trial(i).start + trial(i).time(iter);
%     endTime(i) = trial(i).start + trial(i).time(end);
% end
% figure; scatter(virmenTime,endTime); hold on;
% plot([endTime(1),endTime(end)],[endTime(1),endTime(end)]);
% xlabel('ViRMEn time (s)');
% ylabel('End time (s)');
