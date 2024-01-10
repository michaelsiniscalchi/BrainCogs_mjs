%%% getTrialEventTimes(trials)
%
%PURPOSE: To extract the timing of key events in each trial of a ViRMEn maze-based task.
%
%AUTHOR: MJ Siniscalchi, Princeton Neuroscience Institute, 220415
%   revised for tactile stimuli, 230608 & 240108
%
%INPUT ARGUMENTS:
%   Structure array 'trials', containing fields:
%       'start', time at the start of each trial relative to ViRMEn startup
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
%       'start',
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
    'outcome',[],...
    'cueEntry',[],'turnEntry',[],'armEntry',[]); % Initialize

for i = 1:numel(trials)
    %Trial start times
    eventTimes(i).start = getTrialIterationTime(log, blockIdx, i, 1); %Time of first iteration; needs correction in some cases because the reference time for trials(i).start changes after restarts, etc.

    %Visual and tactile cue onset times
    towerTimes = getCueOnsetTimes(trials(i).time, eventTimes(i).start, trials(i).cueOnset);
    eventTimes(i).towers = towerTimes.all;
    eventTimes(i).leftTowers = towerTimes.left;
    eventTimes(i).rightTowers = towerTimes.right;
    eventTimes(i).firstTower = towerTimes.all(1);
    eventTimes(i).lastTower = towerTimes.all(end);
    if isfield(trials,"puffOnset")
        puffTimes = getCueOnsetTimes(trials(i).time, eventTimes(i).start, trials(i).puffOnset);
        eventTimes(i).puffs = puffTimes.all;
        eventTimes(i).leftPuffs = puffTimes.left; %Superfluous unless AoE is used
        eventTimes(i).rightPuffs = puffTimes.right;
        eventTimes(i).firstPuff = puffTimes.all(1);
        eventTimes(i).lastPuff = puffTimes.all(end);
    end

    %Outcome onset times
    eventTimes(i).outcome =  eventTimes(i).start + trials(i).time(trials(i).iterations); %Use eventTimes.start (corrected) rather than raw 'start' times

    %Time of entry into cue region, turn region (easeway before arm entry), and arm region
    fields = ["iCueEntry","iTurnEntry","iArmEntry"];
    for j = 1:numel(fields)
        eventTimes(i).([lower(fields{j}(2)) fields{j}(3:end)]) = NaN; %Initialize, eg 'eventTimes(i).turnEntry'
        if trials(i).(fields(j)) %If boundary crossed in current trial
            eventTimes(i).([lower(fields{j}(2)) fields{j}(3:end)]) = ...
                eventTimes(i).start + trials(i).time(trials(i).(fields(j))); %Use eventTimes.start (corrected) rather than raw 'start' times
        end
    end
end

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
                + trial_times(cueOnsets.(fields{j})))';
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