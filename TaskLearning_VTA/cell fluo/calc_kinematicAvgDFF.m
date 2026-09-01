function kinematicDFF = calc_kinematicAvgDFF( cells, trialData, trials, params )

%Get kinematic variables for each imaging time point
kinematics = getTrialDataByTime(trialData, cells.t, params.smoothing_window, @nan);

fields = ["heading","speed","acceleration"];
for f = fields

    %Exclude ITI for kinematic variables
    kinematics.(f)(kinematics.ITI==1,:) = NaN;
    
    %Exclude extreme values
    exclIdx = ...
        kinematics.(f)>prctile(kinematics.(f), params.extreme_cutoff, 1) |...
        kinematics.(f)<prctile(kinematics.(f), 100-params.extreme_cutoff, 1); %Exclude values > cutoff percentile (all dim for extreme velocity components)
    kinematics.(f)(exclIdx,:) = NaN;
    
    %Include only straight-and-narrow, completed trials
    exclIdx = ismember(kinematics.trialIdx, find(~trials.forward | trials.omit));
    kinematics.(f)(exclIdx,:) = NaN;

    %Discretize kinematic variables
    leadEdge = params.binWidth.(f)*(floor((min(kinematics.(f))/params.binWidth.(f))));
    trailEdge = params.binWidth.(f)*(floor((max(kinematics.(f))/params.binWidth.(f)))+1);
    edges = leadEdge:params.binWidth.(f):trailEdge;
    idx = discretize(kinematics.(f), edges);

    %Aggregate dF/F by bin
    binIdx = unique(idx(~isnan(idx)))'; %Leading edge of each bin
    kinematicDFF.(f).x = edges(binIdx); %Store domain, ie bins for speed or heading
    kinematicDFF.(f).mean = nan(numel(cells.dFF), numel(binIdx)); %initialize

    for i=1:numel(cells.dFF)
        for ii = binIdx
            kinematicDFF.(f).mean(i,ii)     = mean(cells.dFF{i}(idx==ii));
            kinematicDFF.(f).sd(i,ii)       = sqrt(var(cells.dFF{i}(idx==ii)));
            kinematicDFF.(f).CI{i}(:,ii)    = kinematicDFF.(f).mean(i,ii) + kinematicDFF.(f).sd(i,ii)*[-1;1]; %Upper and lower bounds
            kinematicDFF.(f).nSamples(i,ii) = numel(cells.dFF{i}(idx==ii));
        end
    end
end

%Mean Fluorescence across cells as function of running speed
% figure;
% dataX = edges(1:end-1); xlabel("speed (cm/s)");
% dataY = mean(kinematicDFF.speed.mean);  ylabel("Mean dF/F");
% stdY = dataY + std(kinematicDFF.speed.mean).*[-1;1]; 
% errorshade(dataX, stdY(1,:), stdY(2,:), 'm'); hold on
% plot(dataX,dataY);
% axis square;

%Scatter plot of raw speed vs. dF/F
% figure;
% dataX = kinematics.speed; xlabel("speed (cm/s)");
% dataY = cells.dFF{1};  ylabel("dF/F");
% scatter(dataX,dataY)
% axis square;

%Scatter plot of binned speed vs. dF/F
% figure;
% dataX = edges(idx(~isnan(idx))); xlabel("binned speed (cm/s)");
% dataY = cells.dFF{1}(~isnan(idx));  ylabel("dF/F");
% scatter(dataX,dataY)
% axis square;