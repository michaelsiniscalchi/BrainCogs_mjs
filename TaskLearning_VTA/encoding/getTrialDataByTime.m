function syncedVars = getTrialDataByTime( trialData, time, smooth_window, pos_initFcn )

initCell = {cell(size(trialData.time))};
initKinematicVar = @(varName, trialIdx)...
    pos_initFcn(size(trialData.time{trialIdx},1), size(trialData.(varName){trialIdx},2))...
    .*trialData.(varName){trialIdx}(end,:); %equal to final value if init_fcn is @ones; NaN if @nan

B = struct("time", initCell, "trialIdx", initCell, "ITI", initCell,...
    "position", initCell, "heading", initCell,...
    "speed", initCell,"acceleration", initCell,...
    "velocity", initCell);

fields = ["position", "heading", "speed", "velocity"];
for i = 1:numel([trialData.eventTimes.logStart])
    for j = 1:numel(fields)
        %Initialize position/velocity to be indexed by session-time
        switch fields(j)
            case "position"
                %Initialize
                data = trialData.(fields(j)){i};
                B.(fields(j)){i} = initKinematicVar(fields(j), i);
            case {"velocity", "heading", "speed"}
                %Apply smoothing
                data = smoothdata(trialData.(fields(j)){i}, 1, "gaussian", smooth_window);
                %Initialize
                B.(fields(j)){i} = ...
                    zeros(size(trialData.time{i},1), size(trialData.(fields(j)){i},2)); %Initialize cell as matrix of zeros, length nTimepoints
        end      
        B.(fields(j)){i}(1:size(data, 1),:) = data; %Populate rows (only upto ITI for most variables)
    end

    %Convert trial-relative time to session-time
    B.time{i} = trialData.time{i} + trialData.eventTimes(i).logStart;

    %Calculate Acceleration from Running Speed
    B.acceleration{i} = [0; diff(B.speed{i})]./median(diff(B.time{i})); %Scale by the virmen frame rate to convert to seconds

    %Assign trial-wide variables: trial idx for each frame
    B.trialIdx{i} = i * ones(size(trialData.time{i}));

    %ITI indicator variable
    itiStart = trialData.eventTimes(i).outcome; %ITI spans time of outcome to start of next trial
    itiEnd = trialData.eventTimes(i).start; %End of ITI from previous trial; due to an error in virmen iteration indexing/timing in the ITI, the actual start-time of trial is on iteration 3
    % B.ITI{i} = double(B.time{i}>itiStart); %Convert to double; model requires NaN for excluded time points
    B.ITI{i} = double(B.time{i}>=itiStart | B.time{i}<itiEnd); %Convert to double; model requires NaN for excluded time points


end

%Convert trial data from trialwise cells to matrix
for f = string(fieldnames(B))'
    B.(f) = cell2mat(B.(f)); %Convert to matrix
end

%Get iteration corresponding to each frame-time
syncIdx = getSyncIdxParallel(B.time, time);

%Populate with rows corresponding to each frame-time
for f = string(fieldnames(B))'
    %Initialize output field nTime x nDataColumns
    syncedVars.(f) = NaN(numel(time), size(B.(f), 2)); %Initialize as NaN
    idx = syncIdx>0; %Exclude non-valid indices; NaNs will be excluded from regression
    syncedVars.(f)(idx,:) = B.(f)(syncIdx(idx),:); %Populate
end

%------------------------------------------------------------------------------

%Get index into behavioral time for each imaging frame-time
function syncIdx = getSyncIdxParallel( beh_time, img_time )
parfor i = 1:numel(img_time)
    syncIdx(i) = sum(beh_time < img_time(i)); %Last VR time before imaging frame
end