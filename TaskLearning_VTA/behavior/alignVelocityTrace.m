function aligned = alignVelocityTrace( position, velocity, speed, time, eventTimes, eventNames, window )

edges = window(1):0.1:window(2);
initMat = NaN(numel(time), numel(edges)-1); %nTrials x nBins
aligned.t = edges(1:end-1); %t assigned as left edge of bin

for f = eventNames
    aligned.(f) = struct('xPosition', initMat, 'yPosition', initMat,...
        'heading', initMat, 'xVelocity', initMat, 'yVelocity', initMat,...
        'speed', initMat);
    for i = 1:numel(eventTimes)
        if ~isnan(eventTimes(i).(f))
            %Get trial time relative to event
            trialEventTime = eventTimes(i).(f) - eventTimes(i).logStart; %Trial-relative event time
            t = time{i}-trialEventTime; %Trial-time vector relative to the event
           
            %Bin time values
            idx = discretize(t, edges);

            %Pad position & velocity trace with NaNs (shorter than time vector)
            pos = position{i};
            pos(end+1:length(t),:) = NaN;
            v = velocity{i};
            v(end+1:length(t),:) = NaN;
            
            %Average the velo/speed within each time bin
            binIdx = unique(idx(~isnan(idx)));
            for j = binIdx'
                aligned.(f).xPosition(i,j) = mean(pos(idx==j, 1)); %X-component (VR)
                aligned.(f).yPosition(i,j) = mean(pos(idx==j, 2)); %Y-component (VR)
                
                aligned.(f).heading(i,j)   = mean(pos(idx==j, 3)); %theta-component (VR)
                
                aligned.(f).xVelocity(i,j) = mean(v(idx==j, 1)); %X-component (VR)
                aligned.(f).yVelocity(i,j) = mean(v(idx==j, 2)); %Y-component (VR)
                aligned.(f).speed(i,j)     = mean(speed{i}(idx==j)); %L2 norm of kinematic velo (directly from sensor dots) **Calc must be wrong--FIX UPSTREAM
            end
        end
    end
end

% figure;
% plot(aligned.t, mean(aligned.(f).speed,1, 'omitmissing'))
% hold on;
% plot(aligned.t, mean(aligned.(f).yVelocity,1, 'omitmissing'))
% plot(aligned.t, mean(aligned.(f).xVelocity,1, 'omitmissing'))
