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
%       'start', time when world becomes visible; logged start-time + 2 more iterations for setting visibility (i=2) and rendering (i=3)
%       'towers', struct containing fields, 'left','right','all'
%       'puffs', struct containing fields, 'left','right','all'
%       'outcome','cueEntry','turnEntry'
%
%---------------------------------------------------------------------------------------------------

function eventTimes = getTrialEventTimes(log, blockIdx)

trials = log.block(blockIdx).trial;
eventTimes(numel(trials),1) = struct(...
    'start',[],...
    'leftTowers',[],'rightTowers',[],'leftPuffs',[],'rightPuffs',[],...
    'firstTower',[],'lastTower',[],'firstPuff',[],'lastPuff',[],...
    'cueEntry',[],'turnEntry',[],'armEntry',[],...
    'choice',[],'outcome',[]); % Initialize

for i = 1:numel(trials)
    %Trial start times
    logStartTime = getTrialIterationTime(log, blockIdx, i, 1); %The first time entry in trial, measured from start of session; trial time vector is relative to this entry; needs correction in some cases because the reference time for trials(i).start changes after restarts, etc.
    eventTimes(i).start = getTrialIterationTime(log, blockIdx, i, 3); %Time when world becomes visible: time(3)

    %Visual and tactile cue onset times
    towerTimes = getCueOnsetTimes(trials(i).time, logStartTime, trials(i).cueOnset);
    eventTimes(i).towers = towerTimes.all;
    eventTimes(i).leftTowers = towerTimes.left;
    eventTimes(i).rightTowers = towerTimes.right;
    eventTimes(i).firstTower = towerTimes.all(1);
    eventTimes(i).lastTower = towerTimes.all(end);
    if isfield(trials,"puffOnset")
        puffTimes = getCueOnsetTimes(trials(i).time, logStartTime, trials(i).puffOnset);
        eventTimes(i).puffs = puffTimes.all;
        eventTimes(i).leftPuffs = puffTimes.left; %Superfluous unless AoE is used
        eventTimes(i).rightPuffs = puffTimes.right;
        eventTimes(i).firstPuff = puffTimes.all(1);
        eventTimes(i).lastPuff = puffTimes.all(end);
    end

    %Outcome onset times
    eventTimes(i).outcome =  logStartTime + trials(i).time(trials(i).iOutcome); %Timestamp is calculated at end of last iteration, just before reward delivery

    %Time of entry into cue region, turn region (easeway before arm entry), and arm region
    fields = ["iCueEntry","iTurnEntry","iArmEntry","iChoice","iOutcome"];
    for j = 1:numel(fields)
        eventTimes(i).([lower(fields{j}(2)) fields{j}(3:end)]) = NaN; %Initialize, eg 'eventTimes(i).turnEntry'
        if isfield(trials,fields(j)) && trials(i).(fields(j)) %If boundary crossed in current trial, else remains NaN
            eventTimes(i).([lower(fields{j}(2)) fields{j}(3:end)]) = ...
                logStartTime + trials(i).time(trials(i).(fields(j))); %Use eventTimes.start (corrected) rather than raw 'start' times
        end
    end
end

%FUTURE: add'l ARG for puff vs. tower once we sort out the exact time reference (towers should appear with 1-iter delay)
function cue_onset_times = getCueOnsetTimes( trial_times, trial_start_time, trial_cue_onsets )
    cue_onsets = cellfun(@(C) C(C>0), trial_cue_onsets, 'UniformOutput', false); %Remove zeros
    cueOnsets  = struct(...
        'left', cue_onsets{Choice.L},...
        'right', cue_onsets{Choice.R},...
        'all', [cue_onsets{:}]);
    fields = fieldnames(cueOnsets);
    for j = 1:numel(fields)
        if any(cueOnsets.(fields{j})>1) %If cues appear during run (rather than at start or not at all)
            %Get iteration assoc with cue onset as time index
            cue_onset_times.(fields{j}) = sort(trial_start_time... %Use eventTimes.start (corrected) rather than raw 'start' times
                + trial_times(cueOnsets.(fields{j})+1))'; %Towers appear on next iteration after being triggered; puffs occur immediately (so timestamp may be slightly off for puffs)
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