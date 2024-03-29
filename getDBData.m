function struct_out = getDBData( key, experiment, varargin )

% Restrict query if desired
exe = struct('performance',true,'intake',true);
if nargin>2
    exe.performance = ismember('performance',varargin);
    exe.intake = ismember('intake',varargin);
end

if exe.performance
    %Get session dates and restrict to specified experiment
    % session_date = unique({trial_data.session_date}');
    [trial_data, block_data, session_data] = fetchPerfData(key);
    
    sessionIdx = contains({session_data.remote_path_behavior_file}, experiment);
    session_date = {session_data(sessionIdx).session_date}';
    session_date = session_date(ismember(session_date,unique({trial_data.session_date}'))); %Restrict to sessions with behavior data
    
    %Initialize output structures
    trials(numel(session_date),1) = struct('correct',[],'error',[],'omit',[]);
    
    trialData(numel(session_date),1) = struct('session_date', [],'start_time',[],'duration',[]);
    
    sessions(numel(session_date),1) = struct(...
        'session_date', [], 'level', [], 'reward_scale', [], 'nTrials', [], 'nCompleted', [],...
        'pCorrect', [], 'pOmit', [], 'remote_path_behavior_file', []);
    
    %Trial exclusions: omission trials
    exclude = @(trialIdx) strcmp({trial_data(trialIdx).choice}, Choice.nil);
    
    %Compute Results for each Session
    for i = 1:numel(session_date)
        
        trialIdx = strcmp({trial_data.session_date},session_date(i));
        blockIdx = strcmp({block_data.session_date},session_date(i));
        
        %---Trial Data--------------------------------------------------------------------
        
        %Trial masks
        correct = strcmp({trial_data(trialIdx).choice},{trial_data(trialIdx).trial_type});
        omit = strcmp({trial_data(trialIdx).choice},Choice.nil);
        error = ~correct & ~omit;
        trials(i) = struct('correct',correct,'error',error,'omit',omit);
        
        %---Trial data--------------------------------------------------------------------
        t0 = trial_data(find(trialIdx,1,'first')).trial_abs_start;
        trialData(i) = struct(...
            'session_date', session_date{i},...
            'start_time', [trial_data(trialIdx).trial_abs_start]-t0,...
            'duration', [trial_data(trialIdx).trial_duration]);
        
        %---Session data------------------------------------------------------------------
        level = [block_data(blockIdx).level];
        reward_scale = [block_data(blockIdx).reward_scale];
        nTrials = sum(trialIdx);
        nCompleted = sum(~exclude(trialIdx));
        pCorrect = mean(correct(~exclude(trialIdx))); % all(exclude(trialIdx)==[trials(i).omit]) for now...
        pOmit = mean(omit);
        
        sessions(i) = struct(...
            'session_date', session_date{i},'level',level,'reward_scale',reward_scale,...
            'nTrials',nTrials,'nCompleted',nCompleted,'pCorrect',pCorrect,'pOmit',pOmit,...
            'remote_path_behavior_file',session_data(i).remote_path_behavior_file);

    end
    struct_out = struct('sessions',sessions,'trialData',trialData,'trials',trials);
end

if exe.intake
    if ~exist('block_data','var')
        [weigh_data, block_data] = fetchIntakeData(key);
    else
        weigh_data = fetchIntakeData(key);
    end

    blockDate = datetime({block_data.session_date})';
    sessionDate = unique(blockDate);
    rewEarned = cell(numel(sessionDate),1);
    for i = 1:numel(sessionDate)
        idx = blockDate==sessionDate(i);
        rewEarned{i} = sum([block_data(idx).reward_mil]);
    end
            
    %Populate output field
    struct_out.intake = struct('session_date',sessionDate,'earned',rewEarned);
    struct_out.weighData = weigh_data;
end



%% Fetch Data
function [ trial_data, block_data, session_data ] = fetchPerfData( key )
trial_data = fetch(behavior.TowersBlockTrial & key,...
    'trial_type', 'choice', 'trial_abs_start', 'trial_duration', 'position', 'velocity'); % 'iterations'
block_data = fetch(behavior.TowersBlock & key,...
    'task', 'level', 'reward_scale', 'reward_mil');
session_data = fetch(acquisition.SessionStarted & key, 'remote_path_behavior_file');

function [intake_data, block_data] = fetchIntakeData( key )
query = proj(...
    action.Weighing, 'date(weighing_time)->administration_date', 'weight', 'weigh_person')...
    * action.WaterAdministration & key;
intake_data = fetch(query,'*');
block_data = fetch(behavior.TowersBlock & key,'reward_mil');