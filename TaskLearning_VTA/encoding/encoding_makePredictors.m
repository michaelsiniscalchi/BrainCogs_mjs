function [ predictors, encodingData ] = encoding_makePredictors( img_beh, params )

%Unpack
t = img_beh.t;
trialData = img_beh.trialData;
trials = img_beh.trials;
eventTimes = trialData.eventTimes;

%-------Predictor matrix and indices-------------------------------------------------

init.categorical = zeros(size(img_beh.t));
init.num = NaN(size(img_beh.t));
init.choice = zeros(size(img_beh.t));
init.event = NaN(size(img_beh.t,1), params.bSpline_df); %Matrix size nSamples x nSplineBases
init.cell = repmat({NaN},size(eventTimes));

%***Put this in getVRData()***--------------------------------------------
%Append choice and outcome-specific events
[eventTimes(trials.left).leftChoice]    = eventTimes(trials.left).turnEntry;
[eventTimes(trials.right).rightChoice]  = eventTimes(trials.right).turnEntry;
[eventTimes(trials.correct).reward]     = eventTimes(trials.correct).outcome;
[eventTimes(trials.error).noReward]     = eventTimes(trials.error).outcome;
%---------------------------------------------------------------------------

%Time, TrialIdx, ITI, Position, Velocity, Acceleration, Heading
predictors = getTrialDataByTime(trialData, t, params.initFcn_position);
predictors.position = predictors.position(:,2); %restrict to Y-position (later, b-spline transform)
predictors.velocity = predictors.velocity(:,2); %restrict to Y-velocity **Get velocity from "sensor dots"
predictors.acceleration = cat(1,NaN,diff(predictors.velocity)); %restrict to Y-velocity

%Trialwise predictors
%Accuracy, prior outcome, prior choice
[predictors.towerSide, predictors.puffSide] = deal(init.categorical); 
predictors.towerSide(ismember(predictors.trialIdx, find(trials.leftTowers)))  = -1;
predictors.towerSide(ismember(predictors.trialIdx, find(trials.rightTowers))) = 1;

predictors.puffSide(ismember(predictors.trialIdx, find(trials.leftPuffs)))    = -1;
predictors.puffSide(ismember(predictors.trialIdx, find(trials.rightPuffs)))   = 1;

predictors.accuracy = init.categorical;
predictors.accuracy(ismember(predictors.trialIdx, find(trials.correct))) = 1; %Image frames from correct trials

predictors.priorOutcome = init.categorical;
predictors.priorOutcome(ismember(predictors.trialIdx, find(trials.priorCorrect))) = 1; %Image frames from trials following correct choice

predictors.priorChoice = init.choice;
predictors.priorChoice(ismember(predictors.trialIdx, find(trials.priorRight))) = 1; %Frames from prior-right choice trials
predictors.priorChoice(ismember(predictors.trialIdx, find(trials.priorLeft))) = -1; %Prior left

%Event Times as binary index (~impulse function)
eventNames = ["start",...
    "leftTowers","rightTowers","leftPuffs","rightPuffs",...
    "reward","noReward"]; 

%For first puff or tower, event is not specified by side initially 
if any(ismember(params.predictorNames, ["firstLeftTower","firstRightPuff"]))
    eventNames = [eventNames,"firstTower","firstPuff"];
end

%Make impulse function for each event
for i = 1:numel(eventNames)
    impulse.(eventNames(i)) = init.categorical; %initialize as false
    tempTimes = [eventTimes.(eventNames(i))]; %Aggregate all events within & across trials
    tempTimes = tempTimes(tempTimes>t(1) & tempTimes<t(end)); %Restrict to events within time range of imaging data
    %Index samples in 't' corresponding to event times
    idx = NaN(numel(tempTimes),1);
    parfor j = 1:numel(tempTimes)
        idx(j) = sum(t < tempTimes(j)); %First frame after event
    end
    impulse.(eventNames{i})(idx) = true;
end
clearvars idx;

%Separately consider first and subsequent cues
if isfield(impulse,'firstPuff')
    for cue = {'Tower','Puff'}
        firstCueType = ['first', cue{:}];
        for side = {'left', 'right'}
            cueType = [side{:},cue{:},'s'];
            firstSideCueType = ['first',upper(side{:}(1)),side{:}(2:end),cue{:}];
            impulse.(firstSideCueType) = impulse.(cueType) & impulse.(firstCueType); %eg, impulse.firstRightPuff
            impulse.(cueType) = impulse.(cueType) & ~impulse.(firstCueType); %exclude first cue from unordered cue predictor
        end
        impulse = rmfield(impulse, firstCueType); %Remove extraneous firstCue event
    end
end

%Events convolved with spline basis set
bSpline = makeBSpline(params.bSpline_degree, params.bSpline_df, params.bSpline_nSamples);
for event = string(fieldnames(impulse))'
    %Initialize predictor, one column per spline basis function
    predictors.(event) = ...
        NaN(length(impulse.(event)) + length(bSpline)-1, params.bSpline_df); %Length of convolve =  nTimepoints + nTimepoints in basis function minus 1
    %Convolve impulse function with each spline basis function
    for j = 1:params.bSpline_df
        predictors.(event)(:,j) =...
            conv(impulse.(event), bSpline(:,j));
    end
    %Truncate to numel(t)
    predictors.(event) = predictors.(event)(1:numel(t),:);
end

%Position splines (alternative to linear position, for interactions)
bSpline_pos = NaN; %Basis funcs for position
binEdges = NaN; %Positions for domain of basis funcs
if params.positionSpline
    binEdges = trialData.positionRange(1):params.bSpline_position_binWidth:trialData.positionRange(2);
    predictors.position(predictors.position<trialData.positionRange(1)) =...
        trialData.positionRange(1); %Trials where mouse moves backward from start position will likely be excluded, but need idx for implementation of position splines
    posIdx = discretize(predictors.position, binEdges); %Index each cm across position range; with wider bins, use discretize()

    bSpline_pos = makeBSpline(params.bSpline_position_degree,...
        params.bSpline_position_df, numel(binEdges)-1);

    idx = ~isnan(posIdx);
    predictors.position = nan(size(predictors.position,1),size(bSpline_pos, 2)); %Re-initialize, one column per basis function
    predictors.position(idx,:) = bSpline_pos(posIdx(idx), :); %Populate basis f(x) columns with spline-transformed data
    predictors.position(predictors.ITI==1,:) = 0; %ITI set to 0:=baseline 

    for f = ["leftTowers","rightTowers","leftPuffs","rightPuffs"]
        pName = strjoin([f,"position"],'_'); %Predictor name, eg "leftPuffs_position"
        predictors.(pName) = zeros(size(predictors.position)); %Initialize as zeroes
        idx = ismember(predictors.trialIdx, find(trials.(f)));
        predictors.(pName)(idx,:) = predictors.position(idx,:);
    end

    %Cue-side x position
    predictors.towerSide_position = predictors.towerSide.*predictors.position; %Interaction: cue-side * position
    predictors.puffSide_position  = predictors.puffSide.*predictors.position;
end

%Restrict all predictors to forward trials
exclIdx = ismember(predictors.trialIdx, find(~trials.forward));
for P = string(fieldnames(predictors))'
    predictors.(P)(exclIdx,:) = NaN; %Exclude timepoints from regression
end

%Restrict to specified predictors
F = fieldnames(predictors); %Get all possible predictors generated by this function
F = F(~ismember(F, params.predictorNames)); %Get fields not specified in input arg
predictors = rmfield(predictors, F);
%Same for impulse
F = fieldnames(impulse); %Get all possible predictors generated by this function
F = F(~ismember(F, params.predictorNames)); %Get fields not specified in input arg
impulse = rmfield(impulse, F);

%Metadata & hyperparams
encodingData.session_date = img_beh.sessions.session_date;
encodingData.cellID = img_beh.cellID;
encodingData.dt = mean(diff(t),'omitnan'); %Use mean dt
for f = string(fieldnames(params))' %Store all input hyperparams
    encodingData.(f) = params.(f);
end
encodingData.impulse = impulse; %event-times as delta functions in imaging time frame
encodingData.bSpline = bSpline; %Store series of basis functions
encodingData.bSpline_pos = bSpline_pos; %Basis funcs for position
encodingData.position = binEdges(1:end-1); %Positions for domain of basis funcs


% for f = ["tower","puff"]
%     predictors.(strjoin([f,'Side'],'')) = init.categorical;
%     leftCues = strjoin(["left", upper(f{1}(1)),f{1}(2:end),"s"],'');
%     rightCues = strjoin(["right", upper(f{1}(1)),f{1}(2:end),"s"],'');
%     predictors.(strjoin([f,'Side'],''))...
%         (ismember(predictors.trialIdx, find(trials.(leftCues)))) = -1;
%     predictors.(strjoin([f,'Side'],''))...
%         (ismember(predictors.trialIdx, find(trials.(rightCues)))) = 1;
% end