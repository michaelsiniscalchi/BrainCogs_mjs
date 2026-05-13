%%% getTrialEventTimes(trials)
%
%PURPOSE: To extract the timing of key events in each trial of a ViRMEn maze-based task.
%
%AUTHOR: MJ Siniscalchi, Princeton Neuroscience Institute, 220415
%   revised for tactile stimuli, 230608 & 240108
%
%INPUT ARGUMENTS:
%   Structure array 'trials', containing fields:
%       'start', time at the start of each trial relative to ViRMEn startup; calculated during BehavioralState.InitializeTrial
%       'position', an Nx3 matrix of virtual position in X, Y, and theta
%       'cuePos', a 1x2 cell array containing the y-position of left and right towers, respectively
%       'PuffPos', a 1x2 cell array containing the y-position of left and right puffs, respectively
%       'time', time of each iteration relative to startup
%       'iterations', total number of iterations from start to outcome in each trial
%       'iCueEntry', the iteration corresponding to entry into the cue region
%       'iTurnEntry', the iteration corresponding to entry into the turn region
%       'iArmEntry', the iteration corresponding to entry into the arm region
%   Note: all fields logged in ViRMEn under the struct 'behavior.logs.block.trial'
%
%OUTPUTS:
%   Struct array 'eventTimes', of length equal to the number of trials and containing fields:
%       'logStart', reference time for trial(i); note that all times(i) are calculated at beginning of iteration(i-1), so 1-iteration (negative) offset in time vector  
%       'start', time when world becomes visible; logged start-time + 2 more iterations for: setting visibility (i=1) and rendering (i=2)
%       'towers', struct containing fields, 'left','right','all'; note that towers appear an additional 1-iteration following visibility command. So, time(i+2)
%       'puffs', struct containing fields, 'left','right','all'; note: presented at time(i+2)
%       'outcome','cueEntry','turnEntry'
%
%---------------------------------------------------------------------------------------------------

function eventTimes = getTrialEventTimes(log, blockIdx)

trials = log.block(blockIdx).trial;
[eventTimes(1:numel(trials))] = struct(...
    'logStart',deal(NaN),'start',deal(NaN),...
    'leftTowers',deal(NaN),'rightTowers',deal(NaN),'leftPuffs',deal(NaN),'rightPuffs',deal(NaN),...
    'firstTower',deal(NaN),'lastTower',deal(NaN),'firstPuff',deal(NaN),'lastPuff',deal(NaN),...
    'firstCue',deal(NaN),...
    'cueEntry',deal(NaN),'turnEntry',deal(NaN),'armEntry',deal(NaN),...
    'licks',deal(NaN),...
    'choice',deal(NaN),'outcome',deal(NaN)); % Initialize

for i = 1:numel(trials)
    %Trial start times
    logStartTime = getTrialIterationTime(log, blockIdx, i, 1); %The first time entry in trial, measured from start of session; trial time vector is relative to this entry; needs correction in some cases because the reference time for trials(i).start changes after restarts, etc.
    eventTimes(i).logStart = logStartTime; %Time when world becomes visible: time(2)
    eventTimes(i).start = getTrialIterationTime(log, blockIdx, i, 3); %Time when world becomes visible: recorded as time(3)-- time(1), t0, initialize trial; time(2), issue command to make world visible; i=3, world becomes visible

    %Visual and tactile cue onset times
    towerTimes = getCueOnsetTimes(trials(i).time, logStartTime, trials(i).cueOnset, 'towers');
    eventTimes(i).towers = towerTimes.all;
    eventTimes(i).leftTowers = towerTimes.left;
    eventTimes(i).rightTowers = towerTimes.right;
    eventTimes(i).firstTower = towerTimes.all(1);
    eventTimes(i).lastTower = towerTimes.all(end);

    puffTimes = getCueOnsetTimes(trials(i).time, logStartTime, trials(i).puffOnset, 'puffs');
    eventTimes(i).puffs = puffTimes.all;
    eventTimes(i).leftPuffs = puffTimes.left; %Superfluous unless AoE is used
    eventTimes(i).rightPuffs = puffTimes.right;
    eventTimes(i).firstPuff = puffTimes.all(1);
    eventTimes(i).lastPuff = puffTimes.all(end);

    %First cue, agnostic of sensory modality
    firstCue = [towerTimes.all(1), puffTimes.all(1)];
    if ~all(isnan(firstCue))
        eventTimes(i).firstCue = firstCue(firstCue==min(firstCue));
    else
        eventTimes(i).firstCue = NaN;
    end

    %Time of entry into cue region, turn region (easeway before arm entry), and arm region
    fields = ["iCueEntry","iTurnEntry","iArmEntry","iChoice","iOutcome"];
    for j = 1:numel(fields)
        eventTimes(i).([lower(fields{j}(2)) fields{j}(3:end)]) = NaN; %Initialize, eg 'eventTimes(i).turnEntry' ***MAY BE SUPERFLUOUS after changing method of struct initialization (with deal(NaN)) 
        if isfield(trials,fields(j)) && trials(i).(fields(j)) %If boundary crossed in current trial, else remains NaN
            eventTimes(i).([lower(fields{j}(2)) fields{j}(3:end)]) = ...
                logStartTime + trials(i).time(trials(i).(fields(j))+1); %Timestamp for i+1 is calculated before iteration(i), so add (+1) offset
        end
    end

    %Lick times, if available
    if isfield(trials,"licks") && ~any(isnan(trials(i).licks(:)))
        %Timestamp for i+1 is measured before iteration(i),
        %  with i+1 recorded as lick index (so no extra +1 needed here);
        %  however, *if* using the NI-Daq counter function,
        %  licks occurred during interval between reads, so t0 should be
        %  last iteration time before the read = iteration(i)
        licks = trials(i).licks(:,trials(i).licks(1,:)>1); %Exclude any entries registered to first iteration (from ITI)
        iter = licks(1,:) - 1; %(See explanation above: counter function used starting ~5/1/2026)
        eventTimes(i).licks = getTrialIterationTime(log, blockIdx, i, iter)';
        
        %Interpolate additional lick times from iterations with >1 lick
        nLicks = licks(2,:); %Number of licks in each read
        xLickIdx = find(nLicks>1); %Reads with multiple licks
        if any(xLickIdx)
            iterDurations = diff(trials(i).time); %Durations of all iterations in trial
            xLickTimes = []; %Additional lick times to append
            for k = xLickIdx %Loop through each read with multiple licks and
                dt = iterDurations(iter(k))/double(nLicks(k)); %Total iteration duration/number of licks
                t0 = eventTimes(i).licks(k); %Time of first lick in current iteration
                xLickTimes = [xLickTimes, t0 + (dt:dt:dt*double(nLicks(k)-1))]; %Infer extra licktimes based on number and duration of iteration
            end
            eventTimes(i).licks = sort([eventTimes(i).licks, xLickTimes]); %Append extra licktimes
        end

        % figure; %Overlay raw vs. remaining events
        %plot(eventTimes(i).licks,zeros(1,numel(eventTimes(i).licks)),'|','LineStyle','none'); hold on
        %Filter doublets with lick frequencies > 10 Hz
        while any(diff(eventTimes(i).licks)<0.1)
            idx = find(diff(eventTimes(i).licks)<0.1, 1, 'first') + 1; %Find doublet 
            eventTimes(i).licks(idx) = []; %Remove second lick
        end
        % plot(eventTimes(i).licks, zeros(1,numel(eventTimes(i).licks)),'|','LineStyle','none');
    end
    
    
end

%FUTURE: could clean up to only include 2 input args: time and {'cueOnset' or 'puffOnset'}
function cue_onset_times = getCueOnsetTimes( trial_times, trial_start_time, trial_cue_onsets, cue_type )

    cue_onsets = cellfun(@(C) C(C>0), trial_cue_onsets, 'UniformOutput', false); %Remove zeros
    cueOnsets  = struct(...
        'left', cue_onsets{Choice.L},...
        'right', cue_onsets{Choice.R},...
        'all', [cue_onsets{:}]);
    cueDelay = struct('towers', 2, 'puffs', 1); %Normal offset for puffs: time(i) assigned before iteration(i-1); extra iteration for towers (virmin graphics rendering is between iterations)

    fields = fieldnames(cueOnsets);
    for j = 1:numel(fields)
        if any(cueOnsets.(fields{j})>1) %If cues appear during run (rather than at start or not at all)
            %Get iteration assoc with cue onset as time index
            idx = cueOnsets.(fields{j}) + cueDelay.(cue_type);
            cue_onset_times.(fields{j}) = sort(trial_start_time + trial_times(idx))'; 
        else
            cue_onset_times.(fields{j}) = NaN;
        end
    end

% --- Notes -------

%Alternative approach to Cue onset times, etc.
%     yPos = trials(i).position(:,2); %Y-position of mouse in ViRMEn, one entry per iteration
%     cueIter = arrayfun(@(P) find(yPos>P,1,"first"), [trials(i).cuePos{:}]); %First iteration after passing each cue position
%     cueTimes = sort(eventTimes(i).start + trials(i).time(cueIter))'; %trials(i).cueCombo sorted in ViRMEn but not cuePos!
% **Remember to account for cueVisibleAt!**