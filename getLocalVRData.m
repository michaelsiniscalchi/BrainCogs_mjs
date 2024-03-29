function subjects = getRemoteVRData( experiment, subjects )

if isempty(experiment)
    experiment = '';
end

%Aggregate log data into single struct by subject
%#ok<*AGROW>
for i = 1:numel(subjects)

    %Subject ID, ie DB key 'subject_fullname'
    subjectID = subjects(i).ID;

    %Get bucket paths
    key.subject_fullname = char(subjectID); %Must be char, even though annotation says 'string'
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
    trialData(numel(data_files),1) = struct('session_date', [],'start_time',[],...
        'duration',[],'response_time',[],...
        'position',[],'velocity',[],'mean_velocity',[],...
        'x_trajectory',[],'theta_trajectory',[],...
        'collision_locations',[],'pSkid',[],'stuck_locations',[],'stuck_time',[]);

    trials(numel(data_files),1) = ...
        struct('left',[],'right',[],'leftCue',[],'rightCue',[],... %logical
        'correct',[],'error',[],'omit',[],'congruent',[],'conflict',[],... %logical
        'forward',[],'stuck',[],'exclude',[],...  %logical
        'level',[],'blockIdx',[]); %unsigned integer

    sessions(numel(data_files),1) = struct(...
        'session_date', [], 'level', [], 'reward_scale', [],'maxSkidAngle', [],...
        'nTrials', [], 'nCompleted', [], 'nForward', [],...
        'pCorrect', [], 'pCorrect_congruent',[], 'pCorrect_conflict',[],...
        'pOmit', [], 'pStuck', [],...
        'maxCorrectMoving',NaN,'maxCorrectMoving_congruent',NaN,'maxCorrectMoving_conflict',NaN,...
        'median_velocity', [], 'median_pSkid',[],'median_stuckTime',[],...
        'bias', [],...
        'remote_path_behavior_file', []);

    %Load each matfile and aggregate into structure
    for j = 1:numel(data_files)
        disp(['Loading ' data_files(j).remote_path_behavior_file '...']);
        [ ~, logs ] = loadRemoteVRFile( subjectID, data_files(j).session_date);

        %Incorporate any new log variables created during experiment
        fields = fieldnames(logs);
        if isfield(subjects,'logs') && ~isempty(subjects(i).logs)
            newFields = fields(~ismember(fields,fieldnames(subjects(i).logs)));
            if ~isempty(newFields)
                for k = 1:numel(newFields)
                    [subjects(i).logs.(newFields{k})] = deal(struct); %Initialize new fields
                end
            end
        end
        %Store logs in structure
        subjects(i).logs(j,:) = logs;

        %---Trial Data--------------------------------------------------------------------

        %Anonymous functions for maze dimensions
        ver = @(blockIdx) logs.version(min(blockIdx,numel(logs.version)));
        maze = @(blockIdx) ver(blockIdx).mazes(logs.block(blockIdx).mazeID).variable; %May change based on maze level
        world = @(blockIdx) ver(blockIdx).variables; %Changes with protocol
        lTrack = @(blockIdx)...
            sum(double(string({maze(blockIdx).lCue, maze(blockIdx).lMemory})));
        wArm = @(blockIdx)...%Add width of arm minus out-of-range position "border"
            diff(double(string({world(blockIdx).armBorder, world(blockIdx).wArm})));
        lMaze = @(blockIdx) lTrack(blockIdx) + wArm(blockIdx);

        %Check for empty blocks or trials and remove (discuss with Alvaro!)
        logs = removeEmpty(logs,data_files(j).remote_path_behavior_file);
        logs = excludeBadBlocks(logs, experiment); %Edit function to exclude specific blocks
        if isempty(logs)
            continue
        end

        %Initialize trial variables aggregated from logs
        blockIdx = nan(1,numel([logs.block.trial]));
        [start_time, duration, response_time, pSkid, stuck_time] = deal(nan(numel(blockIdx),1));
        [position, velocity, collision_locations, stuck_locations] = deal(cell(numel(blockIdx),1));
        %Initialize as one cell per block
        [theta_trajectory, x_trajectory] = deal(cell(numel(logs.block),1)); %Matrices: nLocation x nTrial

        %Get maximum skid angle before engagement of friction
        maxSkidAngle = inf(1,numel(logs.block));
        if isfield(maze(1),'maxSkidAngle')
            maxSkidAngle = arrayfun(@(blockIdx) str2double(maze(blockIdx).maxSkidAngle), 1:numel(logs.block));
        end

        firstTrial = 1; %log.block(k).firstTrial cannot be used: empty trials were removed with removeEmpty()
        for k = 1:numel(logs.block)

            %Index for trials in current block
            Trials = logs.block(k).trial;
            lastTrial = firstTrial + numel(Trials) - 1;
            blockIdx(firstTrial:lastTrial) = k;
            start_time(blockIdx==k) = [Trials.start];

            %Time from trial start to choice & Duration including ITI
            response_time(blockIdx==k)  = arrayfun(@(idx) Trials(idx).time(Trials(idx).iterations), 1:numel(Trials));
            duration(blockIdx==k)  = [Trials.duration];

            %Running velocity and position
            velocity(blockIdx==k)  = cellfun(@double,{Trials.velocity},'UniformOutput',false); %Raw from sensors
            position(blockIdx==k)  = cellfun(@double,{Trials.position},'UniformOutput',false); %Derived from ViRMEn w/ collision detection, possible scaling, etc

            %X-position and view angle as matrices
            ySample = 1:lMaze(k);
            x_trajectory{k} = getTrialTrajectories({Trials.position}, 'x', ySample);
            theta_trajectory{k} = getTrialTrajectories({Trials.position}, 'theta', ySample);

            %Collision locations along main stem
            yLimits = [0, str2double(maze(k).lCue)];
            [ ~, collision_locations(blockIdx==k), pSkid(blockIdx==k) ] =...
                getCollisions({Trials.position}, {Trials.collision}, yLimits);

            %Collisions with engagement of "sticky walls"
            resolution = 5;
            if isfinite(maxSkidAngle(k)) && isfield(Trials,'frictionEngagedVec')
                stuck_time(blockIdx==k) = cellfun(@(pos,fric)...
                    sum(fric) / sum(pos(:,2) >= yLimits(1) & pos(:,2) < yLimits(2)),... Proportion of samples spent with friction engaged
                    {Trials.position},{Trials.frictionEngagedVec});
                stuck_locations(blockIdx==k) = cellfun(@(pos,fric) unique(pos(fric,1:2),'rows')',... Unique stuck locations per trial
                    {Trials.position},{Trials.frictionEngagedVec},'UniformOutput',false);
            elseif isfinite(maxSkidAngle(k))
                [stuck_locations(blockIdx==k), stuck_time(blockIdx==k)] = ...
                    getStuckCollisions({Trials.position}, {Trials.collision}, yLimits, maxSkidAngle(k),resolution);
            end

            %Increment trial Idx
            firstTrial = lastTrial+1;
        end

        %Concatenate as matrix if only one maze
        if numel(unique(cellfun(@(T) size(T,1),x_trajectory)))==1 &&...
                (numel([logs.block.mazeID])==1 || isequal(logs.block.mazeID))
            x_trajectory = [x_trajectory{:}];
            theta_trajectory = [theta_trajectory{:}];
        else
            x_trajectory = {x_trajectory};
            theta_trajectory = {theta_trajectory};
        end

        start_time = start_time-start_time(1); %Align to first trial

        trialData(j) = struct(...
            'session_date', datetime(data_files(j).session_date),...
            'start_time', start_time,...
            'duration', duration,...
            'response_time', response_time,...
            'position', {position},...
            'x_trajectory',x_trajectory,...
            'theta_trajectory',theta_trajectory,...
            'velocity', {velocity},...
            'collision_locations', {collision_locations},... %Unique X,Y locations of collisions at cm resolution (X simplified to -1,1 for L/R walls)
            'stuck_locations', {stuck_locations},...
            'stuck_time', stuck_time,... %Proportion of time stuck to sidewalls when "stickywalls" enforced
            'pSkid', pSkid,... %Proportion of maze in collision with sidewalls
            'mean_velocity', cell2mat(cellfun(@mean,velocity,'UniformOutput',false))); %Mean velocity across all iterations in trial (x,y,theta)

        %---Trial masks--------------------------------------------------------------------

        %Initialize
        [left, right, leftCue, rightCue,...
            correct, omit, congruent, conflict, forward, stuck] = deal(false(1,numel(blockIdx)));

        mazeLevel = [logs.block.mazeID];
        for k = 1:numel(logs.block)
            %Cues, choices, and outcomes
            Trials = logs.block(k).trial;
            leftCue(blockIdx==k) = cellfun(@(C) sum(C(1,:))>sum(C(2,:)),{Trials.cueCombo});
            rightCue(blockIdx==k) = cellfun(@(C) sum(C(1,:))<sum(C(2,:)),{Trials.cueCombo});
            left(blockIdx==k) = [Trials.choice]==Choice.L;
            right(blockIdx==k) = [Trials.choice]==Choice.R;
            correct(blockIdx==k) = [Trials.choice]==[Trials.trialType];
            omit(blockIdx==k) = [Trials.choice]==Choice.nil;
            %Trials where sensory and alternation rules agree or conflict
            congruent(blockIdx==k) = int8([Trials.trialType]) == int8(rightCue(blockIdx==k))+1; %L,R choice enumeration = 1,2
            conflict(blockIdx==k) = ~congruent(blockIdx==k); %R,L choice enumeration = 1,2
            %Trials where mouse turns greater than pi/2 rad L or R in cue or memory segment
            forward(blockIdx==k) = getStraightNarrowTrials({Trials.position},[0,lTrack(k)]);
            %Trials where mouse gets stuck after collision along cue segment
            stuck(blockIdx==k) = stuck_time(blockIdx==k)>0;
            %Maze level
            level(blockIdx==k) = mazeLevel(k);
        end
        forward = forward & ~omit; %Exclude forward trials exceedig time limit
        err = ~correct & ~omit;
        exclude = omit; %Exclusions as trial mask


        trials(j) = struct(...
            'left',left,'right',right,'leftCue',leftCue,'rightCue',rightCue,...
            'correct',correct,'error',err,'omit',omit,...
            'conflict',conflict,'congruent',congruent,...
            'forward',forward,'stuck',stuck,...
            'exclude',exclude,...
            'level',level,'blockIdx',blockIdx);

        %---Session data------------------------------------------------------------------

        %Block data

        [reward_scale, nTrials, nCompleted, nForward,...         %Initialize
            pCorrect, pCorrect_congruent, pCorrect_conflict, pOmit, pStuck,...
            median_velocity, median_pSkid, median_stuckTime] = deal([]);
        maxCorrectMoving = struct('all',[],'congruent',[],'conflict',[]);

        for k = 1:numel(logs.block)

            fwdIdx = forward & blockIdx==k;

            reward_scale(k) = [logs.block(k).trial(1).rewardScale];
            nTrials(k) = numel(logs.block(k).trial);
            nCompleted(k) = sum(~omit & blockIdx==k);
            nForward(k) = sum(fwdIdx);
            pCorrect(k) = mean(correct(~omit & blockIdx==k));
            pCorrect_congruent(k) = mean(correct(~omit & congruent & blockIdx==k));
            pCorrect_conflict(k) = mean(correct(~omit & conflict & blockIdx==k));
            pOmit(k) = mean(omit & blockIdx==k);
            pStuck(k) = mean(stuck(~omit & blockIdx==k));

            median_velocity(k) = median(trialData(j).mean_velocity(fwdIdx,2)); %Median velocity across all completed trials (x,y,theta)
            median_pSkid(k) = median(trialData(j).pSkid(fwdIdx)); %Median proportion of maze where mouse skidded along walls
            median_stuckTime(k) = median(trialData(j).stuck_time,'omitnan');
            
            %Choice bias
            leftError = sum(left(err & blockIdx==k))/sum(left(blockIdx==k));
            rightError = sum(right(err & blockIdx==k))/sum(right(blockIdx==k));
            bias(k) = rightError-leftError;

            %Moving average correct rate
            tempCorrect = double(correct(blockIdx==k));
            tempCongruent = congruent(blockIdx==k);
            hits = struct('all',tempCorrect,'congruent',tempCorrect,'conflict',tempCorrect);
            hits.congruent(~tempCongruent) = NaN;
            hits.conflict(tempCongruent) = NaN;
            for fields = ["all","congruent","conflict"]
                maxCorrectMoving(k).(fields) = max(movmean(hits.(fields),[99 0],'omitnan','Endpoints','discard'));
                if isempty(maxCorrectMoving(k).(fields))
                    maxCorrectMoving(k).(fields) = NaN;
                end
            end

        end

        %Store session data
        sessions(j) = struct(...
            'session_date', datetime(data_files(j).session_date),...
            'level', mazeLevel,...
            'reward_scale', reward_scale,...
            'maxSkidAngle', maxSkidAngle,...
            'nTrials', nTrials,...
            'nCompleted', nCompleted,...
            'nForward', nForward,...
            'pCorrect', pCorrect,...
            'pCorrect_congruent', pCorrect_congruent,...
            'pCorrect_conflict', pCorrect_conflict,...
            'pOmit', pOmit,...
            'pStuck', pStuck,...
            'maxCorrectMoving', [maxCorrectMoving.all],...
            'maxCorrectMoving_congruent', [maxCorrectMoving.congruent],...
            'maxCorrectMoving_conflict', [maxCorrectMoving.conflict],...
            'median_velocity', median_velocity,... %Mean velocity across all completed trials (x,y,theta)
            'median_pSkid', median_pSkid,... %Mean proportion of maze where mouse skidded along walls
            'median_stuckTime', median_stuckTime,...
            'bias', bias,...
            'remote_path_behavior_file', data_files(j).remote_path_behavior_file);
    end

    %Assign fields to current subject
    subjects(i).trials      = trials;
    subjects(i).trialData   = trialData;
    subjects(i).sessions    = sessions;

    %Remove excluded sessions
    fields = ["logs","trials","trialData","sessions"];
    exclSessionIdx = cellfun(@isempty,{subjects(i).sessions.session_date});
    for j=1:numel(fields)
        subjects(i).(fields(j)) = subjects(i).(fields(j))(~exclSessionIdx);
    end

    clearvars trials trialData sessions;
end



function log = removeEmpty(log, file_path)

[~, name, ext] = fileparts(file_path);
for i = 1:numel(log.block)
    if any(isnan([log.block(i).trial.duration]))
        warning('\n%s',...
            ['Problem with ' name ext],...
            ['Missing trial data in block ' num2str(i)],...
            ['Trials have been omitted.']);
        badTrials = isnan([log.block(i).trial.duration]);
        log.block(i).trial =...
            log.block(i).trial(~badTrials);
    end
end

badBlocks = cellfun(@isempty,{log.block.trial});
if any(badBlocks)
    warning('\n%s',...
        ['Problem with ' name ext]);
    for i = find(badBlocks)
        warning('\n%s',...
            ['Block ' num2str(i),' is empty.'],...
            ['Block has been omitted.']);
    end
    log.block = log.block(~badBlocks);
end
