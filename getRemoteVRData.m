function subjects = getRemoteVRData( experiment, subjects )

if isempty(experiment)
    experiment = '';
end

%Aggregate log data into single struct by subject
for i = 1:numel(subjects)
    
    %Subject ID, ie DB key 'subject_fullname'
    subjectID = subjects(i).ID;
    
    %Get bucket paths
    key.subject_fullname = subjectID;
    data_files = fetch(acquisition.SessionStarted & key, 'remote_path_behavior_file');
    session_file = cell(numel(data_files),1);
    include = false(numel(data_files),1);
    for j = 1:numel(data_files)
        [~, session_file{j}] = lab.utils.get_path_from_official_dir(data_files(j).remote_path_behavior_file);
        include(j) = isfile(session_file{j});
    end
    
    %Filter by experiment
    include(~contains(session_file,experiment)) = false; %Exclude filenames that do not contain 'experiment'
    data_files = data_files(include);
    
    %Initialize output structures
    trials(numel(data_files),1) = struct('correct',[],'error',[],'omit',[],'exclude',[]);
    
    trialData(numel(data_files),1) = struct('session_date', [],'start_time',[],'duration',[]);
    
    sessions(numel(data_files),1) = struct(...
        'session_date', [], 'level', [], 'reward_scale', [],...
        'nTrials', [], 'nCompleted', [], 'pCorrect', [], 'pOmit', [],...
        'remote_path_behavior_file', []);
    
    %Load each matfile and aggregate into structure
    for j = 1:numel(data_files)
        disp(['Loading ' session_file{j} '...']);
        [ ~, log ] = loadRemoteVRFile( subjectID, data_files(j).session_date);
        subjects(i).logs(j,:) = log;
        
        %---Trial Data--------------------------------------------------------------------
        
        %Trial masks
        correct = []; omit = [];
        for k = 1:numel(log.block)
            correct = [correct,...
                strcmp({log.block(k).trial.choice},{log.block(k).trial.trialType})];
            omit = [omit,...
                strcmp({log.block(k).trial.choice},Choice.nil)];
        end
        error = ~correct & ~omit;
        
        exclude = omit; %Exclusions as trial mask
        
        trials(j) = struct('correct',correct,'error',error,'omit',omit,'exclude',exclude);
        
        %---Trial data--------------------------------------------------------------------
        start_time = []; duration = [];
        for k = 1:numel(log.block)
            start_time = [start_time, [log.block(k).trial.start]];
            duration = [duration, [log.block(k).trial.duration]];
        end
        start_time = start_time-start_time(1); %Align to first trial
        trialData(j) = struct(...
            'session_date', data_files(j).session_date,...
            'start_time', start_time,...
            'duration', duration);
        
        %---Session data------------------------------------------------------------------
        level = [log.block.mazeID];
        for k = 1:numel(log.block)
            reward_scale(k) = [log.block(k).trial(1).rewardScale];
            nTrials(k)  = numel(log.block(k).trial);
        end
        nCompleted = sum(~exclude);
        pCorrect = mean(correct(~exclude)); % all(exclude(trialIdx)==[trials(i).omit]) for now...
        pOmit = mean(omit);
        
        sessions(j) = struct(...
            'session_date', data_files(j).session_date,'level',level,'reward_scale',reward_scale,...
            'nTrials',nTrials,'nCompleted',nCompleted,'pCorrect',pCorrect,'pOmit',pOmit,...
            'remote_path_behavior_file',session_data(i).remote_path_behavior_file);
    end
    %Assign fields to current subject
    subjects(i).trials      = trials;
    subjects(i).trialData   = trialData;
    subjects(i).sessions    = sessions;
end