%Helper function to exclude panels where there's nothing to plot
function panelIdx = filterBootPanels(panels, panelIdx, bootAvg_event)

deletePanel = false(numel(panelIdx),1);
for k = 1:numel(panelIdx)
    clearvars nanSignal
    vars = panels(panelIdx(k)).trialType;
    for kk = 1:numel(vars)
        nanSignal(kk) = all(isnan([bootAvg_event.(vars(kk)).cells.signal]));
    end
    %Omit panelIdx if signal is absent (eg, nTrials==0)
    if all(nanSignal)
        deletePanel(k) = true; 
    end
end
panelIdx(deletePanel) = [];
