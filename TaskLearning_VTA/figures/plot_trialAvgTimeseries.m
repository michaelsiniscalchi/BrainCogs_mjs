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
tiledlayout(1,nPanels);
shadeAlpha = 0.2; %Transparency value for error shading
for i = 1:nPanels
    nSignals = numel(panels(i).signal);
    x = panels(i).x;       %Timepoints, etc. for aligned signal (can also be used for spatial-position series)

    %     ax(i) = subplot(1,nPanels,i); hold on;
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
    leg.Location = legend_loc;
    leg.Box = 'off';
    leg.AutoUpdate = 'off';
    
    % Axis title
    title(ax_titles{i});    
    axis square tight;
end

% Standardize scale of axes
[low,high] = bounds([ax(:).YLim]);
for i=1:numel(panels)
    ax(i).YLim = [nanmin(low) - 0.1*range([low;high]),...
        nanmax(high)+ 0.1*range([low;high])]; %Disable
    plot(ax(i),[0 0],ax(i).YLim,'k:','LineWidth',get(groot,'DefaultAxesLineWidth'));
    xlabel(ax(i),xLabel);
end

% YLabel for panel 1
ax(1).YLabel.String = yLabel;