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
%       'logStart', time of first virmen iteration for trial(i)
%       'start', time when world becomes visible; logged start-time + 1 more iteration for: setting visibility (i=1) and rendering (i=2)
%       'towers', struct containing fields, 'left','right','all'
%       'puffs', struct containing fields, 'left','right','all'
%       'outcome','cueEntry','turnEntry'
%
%---------------------------------------------------------------------------------------------------

function eventTimes = getTrialEventTimes(log, blockIdx)

trials = log.block(blockIdx).trial;
eventTimes(numel(trials),1) = struct(...
    'logStart',[],'start',[],...
    'leftTowers',[],'rightTowers',[],'leftPuffs',[],'rightPuffs',[],...
    'firstTower',[],'lastTower',[],'firstPuff',[],'lastPuff',[],...
    'cueEntry',[],'turnEntry',[],'armEntry',[],...
    'choice',[],'outcome',[]); % Initialize

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
    if isfield(trials,"puffOnset")
        puffTimes = getCueOnsetTimes(trials(i).time, logStartTime, trials(i).puffOnset, 'puffs');
        eventTimes(i).puffs = puffTimes.all;
        eventTimes(i).leftPuffs = puffTimes.left; %Superfluous unless AoE is used
        eventTimes(i).rightPuffs = puffTimes.right;
        eventTimes(i).firstPuff = puffTimes.all(1);
        eventTimes(i).lastPuff = puffTimes.all(end);
    end

    %Time of entry into cue region, turn region (easeway before arm entry), and arm region
    fields = ["iCueEntry","iTurnEntry","iArmEntry","iChoice","iOutcome"];
    for j = 1:numel(fields)
        eventTimes(i).([lower(fields{j}(2)) fields{j}(3:end)]) = NaN; %Initialize, eg 'eventTimes(i).turnEntry'
        if isfield(trials,fields(j)) && trials(i).(fields(j)) %If boundary crossed in current trial, else remains NaN
            eventTimes(i).([lower(fields{j}(2)) fields{j}(3:end)]) = ...
                logStartTime + trials(i).time(trials(i).(fields(j))+1); %Timestamp for i+1 is calculated before iteration(i), so add (+1) offset
        end
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