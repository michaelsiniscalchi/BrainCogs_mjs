function syncedVars = getTrialDataByTime( trialData, time )

initCell = {cell(size(trialData.time))};
B = struct("time", initCell, "trialIdx", initCell ,...
    "position", initCell, "velocity", initCell);
fields = ["position","velocity"];
for i = 1:numel([trialData.eventTimes.start])
    for j = 1:numel(fields)
        %Initialize position/velocity to be indexed by session-time
        B.(fields(j)){i} = ...
            zeros(size(trialData.time{i},1), size(trialData.(fields(j)){i},2)); %Initialize cell as matrix of zeros, length nTimepoints
        B.(fields(j)){i}(1:size(trialData.(fields(j)){i},1),:) =...
            trialData.(fields(j)){i}; %Populate rows up to ITI
    end

    %Convert trial-relative time to session-time
    B.time{i} = trialData.time{i} + trialData.eventTimes(i).start;

    %Assign trial-wide variables
    B.trialIdx{i} = i * ones(size(trialData.time{i}));

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
    syncedVars.(f) = NaN(numel(time), size(B.(f), 2)); %Initialize
    syncedVars.(f) = B.(f)(syncIdx,:); %Populate
end

%------------------------------------------------------------------------------

%Get index into behavioral time for each imaging frame-time
function syncIdx = getSyncIdxParallel( beh_time, img_time )
parfor i = 1:numel(img_time)
    syncIdx(i) = sum(beh_time < img_time(i)); %Last VR time before imaging frame
end