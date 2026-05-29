function fig = fig_plotAllTimeseries( img_beh, params )

setup_figprops(timeseries);

% Initialize figure
figName = img_beh.sessionID;
    ds_factor = 10; %Downsample factor; set to 1 for no DS
if isempty(params.cellIDs)
    fig = figure('Name',figName);
    fig.Position = [10 100 1900 800];
else
    fig = figure('Name',[figName ' -subset']);
    fig.Position = [10 100 1900 800];
end

fig.Visible = 'on';
color = params.Color; 

% Restrict cell IDs, if specified
cellIdx = true(numel(img_beh.cellID),1);
cellID = img_beh.cellID;
if ~isempty(params.cellIDs) && ~isempty(params.expIDs)
    expIdx = strcmp(params.expIDs,img_beh.sessionID);
    cellIdx = ismember(img_beh.cellID,params.cellIDs{expIdx});
    cellID = cellID(cellIdx);
elseif ~isempty(params.cellIDs)
    cellIdx = ismember(img_beh.cellID,params.cellIDs);
    cellID = cellID(cellIdx);
end

% Extract data for plot
nROIs = sum(cellIdx); %Number of cells to plot

timeIdx = 1:ds_factor:numel(img_beh.t);%Downsample for publications, etc.
t = (img_beh.t(timeIdx) ./ 60); %Unit: seconds->minutes
dFF = cellfun(@(C) C(timeIdx),img_beh.dFF(cellIdx),'UniformOutput',false);

startTimes = ([img_beh.trialData.eventTimes.logStart] ./ 60); %Unit: seconds->minutes
% trigTimes = (img_beh.trialData.(params.trigTimes) ./ 60); %'cueTimes' or 'responseTimes'

% Make color-coded backdrop for each rule block
spc = params.spacing; %Unit: sd
ymax = 0;
ymin = -spc*(nROIs+0.5); %Cell idx negated so cell 1 is on top
% Mark beginning of each trial, if desired
if params.trialMarkers
    c = cell(numel(startTimes),1);
    c(:) = {'w'};
    c(img_beh.trials.correct) = {color.correct};
    c(img_beh.trials.error) = {color.error};
    for i = 1:numel(startTimes)
        plot([startTimes(i),startTimes(i)],[ymin,ymax],'-','Color',c{i},'LineWidth',0.5);  hold on
    end
end

% Plot dF/F for all cells as z-score
for i = 1:nROIs
    Y = zscore(dFF{i}) - spc*i;
    plot(t,Y,'k','LineWidth',params.LineWidth); hold on
end

% Label y-axis
if params.ylabel_cellIDs
    ytick = -spc*numel(cellID):spc:-spc;
    yticklabel = cellID(end:-1:1);
else
    lowTick = -10*(mod(spc*nROIs/10,10) - spc*nROIs/10); %Bottom tick spacing value
    ytick = lowTick:spc*10:-spc; %Ticks at these spacing values
    yticklabel = -lowTick/10:10:-10; %Label from 10:10:nCells from top to bottom
end
set(gca,'YTick',ytick); %Ticks at these spacing values
set(gca,'YTickLabel',yticklabel);

title(img_beh.sessionID);
ylabel('Cell Identifier'); xlabel('Time (min)');
set(gca,'box','off');
axis tight;

end
