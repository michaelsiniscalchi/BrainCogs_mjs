function [ ax, leg ] = layout_trialAvgTimeseries( tiledLayoutObj, panels, titleCell, xLabel, yLabel, legend_loc, params )
%%% plot_trialAvgTimeseries
%PURPOSE:   Plot bootstrapped timeseries (eg cellular fluorescence) time-locked to behavioral event.
%
%AUTHORS:   MJ Siniscalchi 260728
%
%
%INPUT ARGUMENTS
%   panel:       Structure specified in params, containing fields:
%
%
%   titleStr:    Character array for figure title
%   xLabel:      Character array for x-axis label.
%   yLabel:      Character array for y-axis label.
%
%--------------------------------------------------------------------------

shadeAlpha = 0.2; %Transparency value for error shading
if isfield(params,'lineWidth') && ~isempty(params.lineWidth)
    lineWidth = params.lineWidth;
else
    lineWidth = get(groot,'DefaultAxesLineWidth');
end

%Plot each data series in separate panel 
leg = gobjects(numel(panels),1);
for i = 1:numel(panels)
    nSignals = numel(panels(i).signal);
    x = panels(i).x;       %Timepoints, etc. for aligned signal (can also be used for spatial-position series)
    
    ax(i) = nexttile(tiledLayoutObj); hold on;

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
            panels(i).lineStyle{j},...
            'LineWidth', lineWidth,...
            'Color',panels(i).color{j});
    end
    
    % Figure legend
    if legend_loc~="none"
        leg(i) = legend(hObj, panels(i).legend_names);
        leg(i).Location = legend_loc;
        leg(i).Box = 'off';
        leg(i).AutoUpdate = 'off';
        leg(i).Interpreter = 'none';
        % if legend_loc=="layout"
        %     leg(i).Layout.Tile = ...
        %         i+tiledLayoutObj.GridSize(1)*(tiledLayoutObj.GridSize(2)-1); %Last row of layout
        % end
    end
    
    % Axis labels & title
    ax(i).YAxis.TickLabelFormat = params.tickLabelFormat;
    ax(i).YAxis.Exponent = 0;
    if ~isempty(xLabel)
        xlabel(xLabel);
    end
    if ~isempty(titleCell)
        title(titleCell{i}); %Indexed in case of multiple panels in one row
    end
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
        plot(ax(i),[0 0],ax(i).YLim,'k:', 'LineWidth', lineWidth);
    end
end

% YLabel for panel 1
if ~isempty(yLabel)
    ax(1).YLabel.String = yLabel;
end