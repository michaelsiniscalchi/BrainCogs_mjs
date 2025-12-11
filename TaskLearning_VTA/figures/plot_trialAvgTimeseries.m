function fig = plot_trialAvgTimeseries(panels,ax_titles,xLabel,yLabel,legend_loc)
%%% plot_trialAvgTimeseries
%PURPOSE:   Plot bootstrapped timeseries (eg cellular fluorescence) time-locked to behavioral event.
%
%AUTHORS:   MJ Siniscalchi & AC Kwan 190912
%
%
%INPUT ARGUMENTS
%   panels:       Structure specified in params, containing fields:
%
%
%   fig_title:    Character array for figure title
%   xLabel:       Character array for x-axis label.
%   yLabel:       Character array for y-axis label.
%
%--------------------------------------------------------------------------
nPanels=numel(panels);  %Number of panels

fig = figure;
ax = gobjects(nPanels,1);
if legend_loc=="layout"
    tiledlayout(2, nPanels);
else
    tiledlayout(1, nPanels);
end

shadeAlpha = 0.2; %Transparency value for error shading

%Plot each data series in separate panel 
for i = 1:nPanels
    nSignals = numel(panels(i).signal);
    x = panels(i).x;       %Timepoints, etc. for aligned signal (can also be used for spatial-position series)
    
    ax(i) = nexttile(i); hold on;

    % Fill area representing confidence intervals
    if isfield(panels(i),'CI')
        for j = 1:nSignals
            errorshade(x,panels(i).CI{j}(1,:),...
                panels(i).CI{j}(2,:),panels(i).color{j},shadeAlpha);
        end
    end
    
    % Plot mean signals
    hObj = gobjects(nSignals,1);
    for j = 1:nSignals
        %Plot signal
        hObj(j) = plot(x,panels(i).signal{j},...
            panels(i).lineStyle{j},'Color',panels(i).color{j});
    end
    
    % Figure legend
    leg = legend(hObj,panels(i).legend_names);
    leg.FontSize = 14;
    
    if legend_loc=="layout"
        leg.Layout.Tile = nPanels + i;
        leg.NumColumns = ceil(nSignals/5);
    else
        leg.Location = legend_loc;
    end

    leg.Box = 'off';
    leg.AutoUpdate = 'off';
    
    % Axis label & title
    xlabel(xLabel);
    title(ax_titles{i});    
    axis square tight;
end

% Standardize scale of axes
for i=1:numel(panels) %Exclude nan series
    idx(i) = ~all(isnan([panels(i).signal{:}]));
end
[yLow,yHigh] = bounds([ax(idx).YLim]);
[x_Low,x_High] = bounds([ax(idx).XLim]);
for i=1:numel(panels)
    ax(i).YLim = [yLow - 0.1*range([yLow;yHigh]),...
        yHigh + 0.1*range([yLow;yHigh])]; 
    ax(i).XLim = [x_Low, x_High];
    %Dotted line at X=0
    if x_Low<0
        plot(ax(i),[0 0],ax(i).YLim,'k:','LineWidth',get(groot,'DefaultAxesLineWidth'));
    end
end

% YLabel for panel 1
ax(1).YLabel.String = yLabel;