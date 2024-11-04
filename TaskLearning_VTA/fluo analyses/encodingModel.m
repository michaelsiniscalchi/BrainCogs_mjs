function glm = encodingModel( img_beh, params )

%Unpack
t = img_beh.t; 
trialData = img_beh.trialData;
trials = img_beh.trials;
eventTimes = trialData.eventTimes;

dt = mean(diff(t),'omitnan'); %Use mean dt

%-------Predictor matrix and indices-------------------------------------------------

init.bin = false(size(img_beh.t));
init.num = NaN(size(img_beh.t));
init.choice = zeros(size(img_beh.t));
init.event = NaN(size(img_beh.t,1), params.bSpline_df); %Matrix size nSamples x nSplineBases
init.cell = repmat({NaN},size(eventTimes));

%***Put this in getVRData()***--------------------------------------------
%Append choice and outcome-specific events
[eventTimes(trials.left).leftChoice] = eventTimes(trials.left).turnEntry;
[eventTimes(trials.right).rightChoice] = eventTimes(trials.right).turnEntry;
[eventTimes(trials.correct).reward] = eventTimes(trials.correct).outcome;
[eventTimes(trials.error).noReward] = eventTimes(trials.error).outcome;
%---------------------------------------------------------------------------

%Time, Position, Velocity, Acceleration, Heading
predictors = getTrialDataByTime(trialData, t);
predictors.viewAngle = predictors.position(:,3); %rename
predictors.position = predictors.position(:,2); %restrict to Y-position
predictors.velocity = predictors.velocity(:,2); %restrict to Y-velocity
predictors.acceleration = cat(1,NaN,diff(predictors.velocity)); %restrict to Y-velocity

%Trialwise predictors
%Choice, prior choice, accuracy
predictors.accuracy = init.bin;
predictors.accuracy(ismember(predictors.trialIdx, find(trials.correct))) = true; %Image frames from correct trials

predictors.priorOutcome = init.bin;
predictors.priorOutcome(ismember(predictors.trialIdx, find(trials.priorCorrect))) = true; %Image frames from correct trials

predictors.priorChoice = init.choice;
predictors.priorChoice(ismember(predictors.trialIdx, find(trials.priorLeft))) = -1; %Frames from prior-left choice trials
predictors.priorChoice(ismember(predictors.trialIdx, find(trials.priorRight))) = 1; %Prior right

%Event Times as binary index (~impulse function)
eventNames = ["start",...
    "leftTowers","rightTowers","firstTower",...
    "leftPuffs","rightPuffs","firstPuff",... 
    "leftChoice","rightChoice",...
    "reward","noReward"];

for i = 1:numel(eventNames)
    impulse.(eventNames(i)) = init.bin; %initialize as false
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

%-------Multiple Linear Regression Model------------------------------------------------

%Create Table of Regressors
eventNames = string(fieldnames(impulse))';
pNames = [eventNames,"viewAngle","position","velocity","acceleration"];
X = [];
varNames = string([]);

%Restrict all predictors to forward trials
exclIdx = ismember(predictors.trialIdx, find(~trials.forward));
for P = pNames
    predictors.(P)(exclIdx,:) = NaN;
end

%Name components of regression splines by number
for P = pNames
    nTerms = size(predictors.(P), 2);
    tempNames = P; %Initialize as predictor name, no numeric suffix
    if nTerms>1
        for i = 1:nTerms %Append term index for b-spline or higher order predictor (moments, etc.)  
            tempNames(i) = strjoin([P, num2str(i)],'');
        end
    end
    varNames = [varNames, tempNames]; %#ok<AGROW> 
    idx.(P) = 1 + size(X,2) + (1:nTerms); %1st term reserved for intercept
    X = [X, predictors.(P)]; %#ok<AGROW> 
end

%Z-score the predictor matrix
X = (X - mean(X,1,'omitnan')) ./ std(X,0,1,"omitnan"); %MATLAB zscore() does not allow 'omitnan'

for i = 1:numel(img_beh.dFF)
    Y = img_beh.dFF{i}; %TEMP ()
    mdl = fitglm(X,Y,'PredictorVars',varNames);
    glm.model{i} = mdl;

    %Estimate response kernels for each event-related predictor
for varName = eventNames
        estimate = bSpline*mdl.Coefficients.Estimate(idx.(varName)); %(approx. resp func) = bSpline * Beta
        se = bSpline*mdl.Coefficients.SE(idx.(varName)); 
        se = estimate + [1,-1].*se; %Express as estimate +/- se
        glm.kernel(i).(varName).estimate = estimate'; %transpose for plotting
        glm.kernel(i).(varName).se = se'; %transpose for plotting  
        glm.kernel(i).(varName).t = 0:dt:dt*(size(bSpline,1)-1);
end

%Predict full time series from model
glm.predictedDFF{i,:} = mdl.Fitted.Response;

end

%Metadata
glm.eventNames = eventNames;
glm.bSpline = bSpline;