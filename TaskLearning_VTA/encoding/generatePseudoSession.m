function [ X, trialIdx ] = generatePseudoSession(img_beh, params)

% Generate New Predictor Matrices from Shuffled and Concatenated Trials
nTrials = numel(img_beh.trialData.eventTimes);
    
%Get intervals between logStart times
startTimes = [img_beh.trialData.eventTimes.logStart]; %Initialize as copy; elements 2:end will change on every shuffle
durations = [img_beh.trialData.duration]; %Cross-checked against diff([img_beh.trialData.eventTimes.logStart]);
eventTimes = img_beh.trialData.eventTimes;

    %Generate random sequence of trial IDs
    trialIdx = randperm(nTrials);

    %Re-assign trial masks and non-event trialData
    for f = string(fieldnames(img_beh.trials))'
        trials.(f) = img_beh.trials.(f)(trialIdx); %re-assign with randomized trial idx
    end

    for f = ["time","duration","position","velocity","heading","speed"]
        trialData.(f) = img_beh.trialData.(f)(trialIdx);
    end

    % Re-assign event times 
    startTimes(2:end) = startTimes(1) + cumsum(durations(trialIdx(1:end-1)));
    for j = 1:nTrials
        for f = string(fieldnames(eventTimes))'
            idx = trialIdx(j); %Original trial index
            tempTimes = eventTimes(idx).(f) - eventTimes(idx).logStart; %recover relative times
            trialData.eventTimes(j).(f) = tempTimes + startTimes(j); %store as pseudo-session time
        end
    end
    %Include position range and session date
    trialData.positionRange = img_beh.trialData.positionRange;
    trialData.session_date = img_beh.trialData.session_date;

%Make Predictors
[ X, encodingData ] = encoding_makePredictors(trialData, trials, img_beh.t, params);

%Exclude any NaN rows (also excluded in the regression)
exclIdx = any(isnan(X),2); 
X = X(~exclIdx,:);
trialIdx = encodingData.trialIdx(~exclIdx);

%Circularly shift design matrix to decorrelate trial start-times from true and pseudo-sessions 
k = randi(sum(trialIdx==trialIdx(1))); %Number of elements to shift, drawn from Uniform()
X = circshift(X, k);
trialIdx = circshift(encodingData.trialIdx, k); %Also shift trial index to match
