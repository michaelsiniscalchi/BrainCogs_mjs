%% align2Event()
%
% PURPOSE: To align cellular fluorescence to a specified behavioral/physiological
%               event repeated within an imaging session.
%
% AUTHOR: MJ Siniscalchi, 190910
%
% INPUT ARGS:
%           struct 'cells', containing fields 'dFF' and 't'.
%
% OUTPUTS:
%           struct 'aligned, containing fields:
%                   -'(params.trigTimes).dFF', a cell array (nCells x 1) containing aligned
%                       cellular fluorescence as a matrix (nTriggers x nTimepoints).
%                   -'t', a vector representing time relative to the specified event.
%
%--------------------------------------------------------------------------

function aligned = alignCellFluo( cells, eventTimes, params )

% Get nearest time index for each event time
dFF = cell2mat(cells.dFF');
t = cells.t; %Abbreviate
dt = mean(diff(t),'omitnan'); %Use mean dt
rel_idx = round(params.timeWindow(1)/dt) : round(params.timeWindow(end)/dt); %In number of samples

events = fieldnames(eventTimes);
for i = 1:numel(events)
    event_times = [eventTimes.(events{i})];
    idx = NaN(numel(event_times),numel(rel_idx));
    for j = 1:numel(event_times)
        idx_t0 = find(t >= event_times(j)-dt/1.999 & t <= event_times(j)+dt/1.999,1,'first'); %Occasionally, exactly centered event_times(i) yield null set or two results with threshold set to dt/2
        if ~isempty(idx_t0)
            idx(j,:) = idx_t0 + rel_idx;
        end
    end

    % Handle idxs for out-of-range timepoints
    nanIdx = idx < 1 | idx > numel(t) | isnan(idx); %Idx for out-of-range timepoints
    idx(idx < 1 | isnan(idx)) = 1;
    idx(idx > numel(t)) = numel(t);

    % Align signals
    aligned.(events{i}) = cell(numel(cells.dFF),1); %Initialize
    for j = 1:numel(cells.dFF)
        %Populate matrix of dimensions nEvents  x nTimepoints
        cell_dFF = dFF(:,j);
        aligned.(events{i}){j} = cell_dFF(idx);  
        aligned.(events{i}){j}(nanIdx) = NaN; %Exclude out-of-range timepoints
        
        %Split rows into trial-wise cell arrays if multiple instances per trial
        if numel(event_times) > numel(eventTimes)
            nEvents = cellfun(@numel,{eventTimes.(events{i})}); %Number of events in each trial
            aligned.(events{i}){j} = mat2cell(aligned.(events{i}){j},nEvents);   
        end
    end
end
aligned.t = rel_idx * dt; %Time relative to specified event
