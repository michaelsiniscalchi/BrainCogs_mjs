function glm = encodingModel( img_beh, params )

%Unpack
t = img_beh.t; 
trialData = img_beh.trialData;
trials = img_beh.trials;
eventTimes = trialData.eventTimes;

dt = mean(diff(t),'omitnan'); %Use mean dt

%---FOR DEVO-----------------------------------------------------------
params.bSpline_nSamples = 60; %N time points for spline basis set
params.bSpline_degree = 3; %degree of each (Bernstein polynomial) term
params.bSpline_df = 7; %number of terms:= order + N internal knots
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%-------Predictor matrix and indices-------------------------------------------------

init.bin = false(size(img_beh.t));
init.num = NaN(size(img_beh.t));
init.event = NaN(size(img_beh.t,1), params.bSpline_df); %Matrix size nSamples x nSplineBases
init.cell = repmat({NaN},size(eventTimes));

%***Put this in getVRData()***--------------------------------------------
[eventTimes(:).reward] = init.cell{:};
[eventTimes(:).noReward] = init.cell{:};
[eventTimes(trials.correct).reward] = eventTimes(trials.correct).outcome;
[eventTimes(trials.error).noReward] = eventTimes(trials.error).outcome;
%---------------------------------------------------------------------------

%Time, Position, Velocity, Acceleration, Heading
predictors = getTrialDataByTime(trialData, t);
predictors.viewAngle = predictors.position(:,3); %rename
predictors.position = predictors.position(:,2); %restrict to Y-position
predictors.velocity = predictors.velocity(:,2); %restrict to Y-velocity
predictors.acceleration = cat(1,NaN,diff(predictors.velocity)); %restrict to Y-velocity

%Trial epoch (start, cue, turn, outcome)?

%Event Times as binary index (~impulse function)
eventNames = ["start","leftTowers","rightTowers",...
    "leftPuffs","rightPuffs","reward","noReward"];
for i = 1:numel(eventNames)
    impulse.(eventNames(i)) = init.bin; %initialize as false
    tempTimes = [eventTimes.(eventNames(i))]; %Aggregate all events within & across trials
    tempTimes = tempTimes(tempTimes>t(1)); %Restrict to events following first image frame
    %Index samples in 't' corresponding to event times
    idx = NaN(numel(tempTimes),1);
    parfor j = 1:numel(tempTimes)
        idx(j) = sum(t < tempTimes(j)) + 1; %First frame after event
    end
    impulse.(eventNames{i})(idx) = true;
end
clearvars idx;

%Events convolved with spline basis set
bSpline = makeBSpline(params.bSpline_degree, params.bSpline_df, params.bSpline_nSamples);
for i = 1:numel(eventNames)
    %Initialize predictor, one column per spline basis function
    predictors.(eventNames(i)) = ...
        NaN(length(impulse.(eventNames(i))) + length(bSpline)-1, params.bSpline_df); %Length of convolve =  nTimepoints + nTimepoints in basis function minus 1
    %Convolve impulse function with each spline basis function
    for j = 1:params.bSpline_df
        predictors.(eventNames(i))(:,j) =...
            conv(impulse.(eventNames(i)), bSpline(:,j));
    end
    %Truncate to numel(t)
    predictors.(eventNames(i)) = predictors.(eventNames(i))(1:numel(t),:);
end

%Restrict to forward trials
exclIdx = ismember(predictors.trialIdx, find(~trials.forward));
for f = string(fieldnames(predictors))'
    predictors.(f)(exclIdx,:) = NaN;
end

%-------Multiple Linear Regression Model------------------------------------------------

%Create Table of Regressors
fields = [eventNames,"viewAngle","position","velocity","acceleration"];
X = [];
[varNames, tempNames] = deal(string([]));

for f = fields
    nTerms = size(predictors.(f), 2);
    tempNames = f;
    if nTerms>1
        for i = 1:nTerms
            tempNames(i) = strjoin([f, num2str(i)],'');
        end
    end
    varNames = [varNames, tempNames];
    idx.(f) = 1 + size(X,2) + (1:nTerms); %1st term for intercept
    X = [X, predictors.(f)];
end

%Z-score the predictor matrix
X = (X - mean(X,1,'omitnan')) ./ std(X,0,1,"omitnan"); %MATLAB zscore() does not allow 'omitnan'

for i = 1:numel(img_beh.dFF)
    Y = img_beh.dFF{i}; %TEMP ()
    mdl = fitglm(X,Y,'PredictorVars',varNames);
    glm.model{i} = mdl;

    %Estimate response kernels for each event-related predictor
%     mdl.Coefficients.Estimate
%     mdl.Coefficients.SE
%     a = mdl.Fitted.Response;
%     glm.cells(i)
for varName = eventNames
    if size(predictors.(varName),2) > 1
        estimate = bSpline*mdl.Coefficients.Estimate(idx.(varName)); %(approx. resp func) = bSpline * Beta
        se = bSpline*mdl.Coefficients.SE(idx.(varName)); 
        se = estimate + [1,-1].*se; %Express as estimate +/- se
        glm.kernel(i).(varName).estimate = estimate'; %transpose for plotting
        glm.kernel(i).(varName).se = se'; %transpose for plotting
    end
end

end

%Metadata
glm.bSpline = bSpline;
glm.t = 0:dt:dt*(size(bSpline,1)-1);

