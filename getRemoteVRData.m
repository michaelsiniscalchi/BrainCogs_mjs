function subjects = getRemoteVRData( experiment, subjects, key )

if isempty(experiment)
    experiment = '';
end

%Aggregate log data into single struct by subject
%#ok<*AGROW>
for i = 1:numel(subjects)

    %Subject ID, ie DB key 'subject_fullname'
    subjectID = subjects(i).ID;

    %Get paths on cup.princeton.edu
    key.subject_fullname = char(subjectID); %Must be char, even though annotation says 'string'
    data_files = fetch(acquisition.SessionStarted & key, 'new_remote_path_behavior_file');
    session_file = cell(numel(data_files),1);
    include = false(numel(data_files),1);
    for j = 1:numel(data_files)
        [~, session_file{j}] = lab.utils.get_path_from_official_dir(data_files(j).new_remote_path_behavior_file);
        include(j) = isfile(session_file{j});
    end
    data_files = data_files(include);
    if isempty(data_files)
        continue
    end

    %Load each matfile and aggregate into structure
    sessionDate = string(unique({data_files(:).session_date}));
    for j = 1:numel(sessionDate)
        key.session_date   = char(sessionDate(j)); %Can also include key fields in ARG #3 for loading individual sessions
        [ dataPath, logs ] = loadRemoteVRFile(key);
        key = rmfield(key,"session_date"); %remove session_date; else constrains fetch for next subject
        if isempty(logs)
            continue
        end

        %Remove empty or short sessions
        logs = logs(~cellfun(@isempty,{logs.numTrials}));
        logDuration = arrayfun(@(idx)...
            datetime(logs(idx).session.end) - datetime(logs(idx).session.start), 1:numel(logs));
        logs = logs(logDuration > minutes(10));
        if all(isempty(logs))
            continue
        end

        %Simplify logs and combine sessions from same date (functionalize)
        newlog.animal = logs(1).animal;
        fields = ["session", "block", "version"];
        for k = 1:numel(fields)
            newlog.(fields{k}) = [logs.(fields{k})];
        end
        logs = newlog;

        %Initialize output structures
        trialData(numel(sessionDate),1) = struct(...
            'session_date', [], 'eventTimes', struct(),...
            'towerPositions', [], 'puffPositions', [],...
            'nTowers', [],'nPuffs', [],...
            'duration', [],'response_time', [],'response_delay', [],...
            'time', [], 'position', [],'velocity', [],'mean_velocity', [],...
            'x_trajectory', [],'theta_trajectory', [],'time_trajectory', [],'positionRange', [],...
            'collision_locations', [],'pSkid', [],'stuck_locations', [],'stuck_time', []);

        trials(numel(sessionDate),1) = ...
            struct('left',[],'right',[],... %logical
            'leftTowers',[],'rightTowers',[],'leftPuffs',[],'rightPuffs',[],...%logical
            'leftCues',[],'rightCues',[],... %logical
            'visualRule',[],'tactileRule',[],'forcedChoice',[],... %logical
            'correct',[],'error',[],'omit',[],'congruent',[],'conflict',[],... %logical
            'priorLeft',[],'priorRight',[],'priorCorrect',[],'priorError',[],... %logical
            'forward',[],'stuck',[],'exclude',[],...  %logical
            'level',[],'blockIdx',[]); %unsigned integer

        sessions(numel(sessionDate),1) = struct(...
            'session_date', [], 'level', [], 'taskRule', [], 'reward_scale', [], 'maxSkidAngle', [],...
            'lCue', [], 'lMem', [], 'lMaze', [],...
            'nTrials', [], 'nCompleted', [], 'nForward', [],...
            'pCorrect', [], 'pCorrect_congruent',[], 'pCorrect_conflict', [], 'pOmit', [],...
            'pLeftTowers', [], 'pLeftPuffs', [], 'pLeftCues', [],...
            'pStuck', [],...
            'movmeanAccuracy',struct(),...
            'maxmeanAccuracy',NaN,'maxmeanAccuracy_congruent',NaN,'maxmeanAccuracy_conflict',NaN,...
            'median_velocity', [], 'median_response_delay', [], 'median_delay_bias', [],...
            'median_pSkid',[],'median_stuckTime',[],...
            'bias', [],...
            'psychometric', struct('congruent',struct(),'conflict',struct(),'all',struct()),...
            'cueHistogram', struct('towers',struct(),'puffs',struct(),'cueCounts',[]),...
            'excludeBlocks', [],...
            'new_remote_path_behavior_file', []);

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
        lStart = @(blockIdx) str2double(maze(blockIdx).lStart);
        lCue = @(blockIdx) str2double(maze(blockIdx).lCue);
        lMem = @(blockIdx) str2double(maze(blockIdx).lMemory);
        wArm = @(blockIdx)...%Add width of arm minus out-of-range position "border"
            diff(double(string({world(blockIdx).armBorder, world(blockIdx).wArm})));
        lMaze = @(blockIdx) lCue(blockIdx) + lMem(blockIdx) + wArm(blockIdx);

        %Check for empty blocks or trials and remove
        [logs, excludeBlocks] = excludeBadBlocks(logs); %Edit function to exclude specific blocks
        if isempty(logs) || isempty(logs.block)
            continue
        end

        %Initialize trial variables aggregated from logs
        blockIdx = nan(1,numel([logs.block.trial])); %Row vector
        [duration, response_time, response_delay, pSkid, stuck_time] = deal(nan(numel(blockIdx),1)); %Column vectors
        [time, position, velocity,...
            towerPositions, puffPositions,...
            collision_locations, stuck_locations] = deal(cell(numel(blockIdx),1)); %Cell arrays

        %Initialize as one cell per block
        [theta_trajectory, x_trajectory, time_trajectory, positionRange] =...
            deal(cell(numel(logs.block),1)); %Matrices: nLocation x nTrial

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

            %Event times
            eventTimes(blockIdx==k,1) = getTrialEventTimes(logs, k); %Need logs and block idx for time, because restarts/new blocks cause divergent time references

            %Cue positions and number on each side
            [towerPositions(blockIdx==k,1), puffPositions(blockIdx==k,1)] = getCuePositions(logs, k);

            nTowers(blockIdx==k,:) = [...
                arrayfun(@(idx) numel(towerPositions{idx}{1}), find(blockIdx==k)'),... %Left cues
                arrayfun(@(idx) numel(towerPositions{idx}{2}), find(blockIdx==k))']; %Right cues

            nPuffs(blockIdx==k,:) = [...
                arrayfun(@(idx) numel(puffPositions{idx}{1}), find(blockIdx==k)'),... %Left cues
                arrayfun(@(idx) numel(puffPositions{idx}{2}), find(blockIdx==k))']; %Right cues

            %Response time from trial start to choice (modified after generating trial masks)
            response_time(blockIdx==k)  = arrayfun(@(idx) Trials(idx).time(Trials(idx).iterations), 1:numel(Trials));

            %Duration including ITI
            duration(blockIdx==k)  = [Trials.duration];

            %Running velocity, time, and position
            velocity(blockIdx==k)  = cellfun(@double,{Trials.velocity},'UniformOutput',false); %Raw from sensors
            position(blockIdx==k)  = cellfun(@double,{Trials.position},'UniformOutput',false); %Derived from ViRMEn w/ collision detection, possible scaling, etc
            time(blockIdx==k)  = cellfun(@double,{Trials.time},'UniformOutput',false);

            %X-position and view angle as matrices
            queryPts = -lStart(k):lMaze(k);
            x_trajectory{k} = getTrialTrajectories({Trials.position}, 'x', queryPts);
            theta_trajectory{k} = getTrialTrajectories({Trials.position}, 'theta', queryPts);

            %Time at first crossing of each Y-position
            time_trajectory{k} = getTimebyPosition(Trials, eventTimes(blockIdx==k), queryPts);
            positionRange{k} = queryPts([1,end])';

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
        if numel(unique(cellfun(@(T) size(T,1),x_trajectory)))==1
            x_trajectory = [x_trajectory{:}];
            theta_trajectory = [theta_trajectory{:}];
            time_trajectory = [time_trajectory{:}];
            positionRange = positionRange{1};
        else
            x_trajectory = {x_trajectory};
            theta_trajectory = {theta_trajectory};
            time_trajectory = {time_trajectory};
            positionRange = {positionRange};
        end

        trialData(j) = struct(...
            'session_date', datetime(sessionDate(j)),...
            'eventTimes', eventTimes,...
            'towerPositions', {towerPositions},...
            'puffPositions', {puffPositions},...
            'nTowers', nTowers,...
            'nPuffs', nPuffs,...
            'duration', duration,...
            'response_time', response_time,...
            'response_delay', response_delay,... %Time from entry into turn region to choice entry
            'time', {time},...
            'position', {position},...
            'x_trajectory',x_trajectory,...
            'theta_trajectory',theta_trajectory,...
            'time_trajectory',time_trajectory,...
            'positionRange', positionRange,...
            'velocity', {velocity},...
            'collision_locations', {collision_locations},... %Unique X,Y locations of collisions at cm resolution (X simplified to -1,1 for L/R walls)
            'stuck_locations', {stuck_locations},...
            'stuck_time', stuck_time,... %Proportion of time stuck to sidewalls when "stickywalls" enforced
            'pSkid', pSkid,... %Proportion of maze in collision with sidewalls
            'mean_velocity', cell2mat(cellfun(@mean,velocity,'UniformOutput',false))); %Mean velocity across all iterations in trial (x,y,theta)

        %---Trial masks--------------------------------------------------------------------

        %Initialize
        [left, right, leftTowers, rightTowers, leftPuffs, rightPuffs,...
            tactileRule, visualRule, forcedChoice,...
            correct, omit, congruent, conflict, forward, stuck] = deal(false(1,numel(blockIdx)));
        level = nan(1,numel(blockIdx));
        mazeLevel = [logs.block.mazeID];
        for k = 1:numel(logs.block)
            %Cues, choices, and outcomes
            Trials = logs.block(k).trial;

            %Visual cues
            %             nTowers = cellfun(@numel,reshape([Trials.cuePos],2,numel(Trials)))';
            nTowers = trialData(j).nTowers(blockIdx==k,:); %temp
            leftTowers(blockIdx==k) = nTowers(:,1) > nTowers(:,2); %Trials where towers rule instructs left (ie, nLeft>nRight)
            rightTowers(blockIdx==k) = nTowers(:,1) < nTowers(:,2);%Towers rule indicates "right"

            %Tactile cues
            if isfield(Trials,"puffPos") && any(~cellfun(@isempty,[Trials.puffPos]))
                %                 nPuffs = cellfun(@numel,reshape([Trials.puffPos],2,numel(Trials)))';
                nPuffs = trialData(j).nPuffs(blockIdx==k,:); %temp
                leftPuffs(blockIdx==k) = nPuffs(:,1) > nPuffs(:,2);
                rightPuffs(blockIdx==k) = nPuffs(:,1) < nPuffs(:,2);
            end

            %Sensory rule
            if isfield(Trials,"visualRule")
                forcedChoice(blockIdx==k) = [Trials.forcedChoice];
                visualRule(blockIdx==k) = [Trials.visualRule];
                tactileRule(blockIdx==k) = [Trials.tactileRule];
            end

            %Choices
            left(blockIdx==k) = [Trials.choice]==Choice.L;
            right(blockIdx==k) = [Trials.choice]==Choice.R;

            %Outcomes
            correct(blockIdx==k) = [Trials.choice]==[Trials.trialType];
            omit(blockIdx==k) = [Trials.choice]==Choice.nil;

            %Trials where alternative rules agree or conflict
            if isfield(Trials,"visualRule")...
                    && ~any([Trials.forcedChoice])... %Visual or Tactile rule
                    && any([leftPuffs(blockIdx==k), rightPuffs(blockIdx==k)])... %Block has both Visual and Tactile cues
                    && any([leftTowers(blockIdx==k), rightTowers(blockIdx==k)])
                congruent(blockIdx==k) = ...
                    (leftPuffs(blockIdx==k)==leftTowers(blockIdx==k)) &...
                    (rightPuffs(blockIdx==k)==rightTowers(blockIdx==k)); %Towers and puffs on same side of maze
            elseif isfield(maze(k),"alternateTrials")...  %references logs because rulewas not included as a variable in cfg.trialData
                    && str2double(maze(k).alternateTrials)
                congruent(blockIdx==k) =...
                    int8([Trials.trialType])-1 == int8(rightTowers(blockIdx==k)); %L,R choice enumeration = 1,2
            else %Sensory rule (vs Alternation) or forced choice
                congruent(blockIdx==k) = true;
            end
            conflict(blockIdx==k) = ~congruent(blockIdx==k);

            %Trials where mouse turns greater than pi/2 rad L or R in cue or memory segment
            forward(blockIdx==k) = getStraightNarrowTrials({Trials.position},[0, lCue(k)]);
            %Trials where mouse gets stuck after collision along cue segment
            stuck(blockIdx==k) = stuck_time(blockIdx==k)>0;
            %Maze level
            level(blockIdx==k) = mazeLevel(k);
        end

        %Derived trial masks
        leftCues = (leftTowers & visualRule) | (leftPuffs & tactileRule); %Relevant cue
        rightCues = (rightTowers & visualRule) | (rightPuffs & tactileRule); %Relevant cue

        forward = forward & ~omit; %Exclude forward trials exceeding time limit
        err = ~correct & ~omit;

        exclude = omit | ~forward; %Additions made downstream, eg for warm-up blocks, etc
        exclude(ismember(blockIdx, excludeBlocks)) = true; %Exclude trials from blocks specified in excludeBadBlocks()

        %Save to struct
        trials(j) = struct(...
            'left',left,'right',right,...
            'leftTowers',leftTowers,'rightTowers',rightTowers,...
            'leftPuffs',leftPuffs,'rightPuffs',rightPuffs,...
            'leftCues',leftCues,'rightCues',rightCues,...
            'visualRule',visualRule,'tactileRule',tactileRule,'forcedChoice',forcedChoice,...
            'correct',correct,'error',err,'omit',omit,...
            'priorLeft',[0, left(1:end-1)],'priorRight',[0, right(1:end-1)],...
            'priorCorrect',[0, correct(1:end-1)],'priorError',[0, err(1:end-1)],...
            'conflict',conflict,'congruent',congruent,...
            'forward',forward,'stuck',stuck,...
            'exclude',exclude,...
            'level',level,...
            'blockIdx',blockIdx);

        %--- Modify trialData based on trials (trial masks) ----------------------------------------

        %Response time
        trialData(j).response_time(~forward | omit) = NaN;

        %Response delay (latency from turn-entry to choice)
        if any([trialData(j).eventTimes.turnEntry])
            turnTime = [trialData(j).eventTimes.turnEntry]-[trialData(j).eventTimes.start];
            trialData(j).response_delay = trialData(j).response_time - turnTime';
        end

        %--- Session data ------------------------------------------------------------------

        %Block data
        [reward_scale, nTrials, nCompleted, nForward,...         %Initialize
            pCorrect, pCorrect_congruent, pCorrect_conflict, pOmit,...
            pLeftTowers, pLeftPuffs, pLeftCues, pStuck,...
            median_velocity, median_pSkid, median_stuckTime] = deal([]);
        movmeanAccuracy = struct('all',[],'congruent',[],'conflict',[]);
        maxmeanAccuracy = struct('all',[],'congruent',[],'conflict',[]);

        ruleNames = ["forcedChoice","visualRule","tactileRule","alternateTrials"];
        rule = strings(1,numel(logs.block));
        for k = 1:numel(logs.block)
            %Task rule: tactile/visual task
            for kk = 1:numel(ruleNames)
                if isfield(maze(k),ruleNames(kk)) && logical(str2double(maze(k).(ruleNames(kk))))
                    rule(k) = ruleNames(kk);
                    break
                end
            end

            if isfield(maze(k),"alternateTrials") && isempty(rule(k))
                rule(k) = "sensory";
            elseif rule(k)=="alternateTrials"
                rule(k) = "alternation";
            elseif rule(k)=="visualRule"
                rule(k) = "visual";
            elseif rule(k)=="tactileRule"
                rule(k) = "tactile";
            end

            reward_scale(k) = [logs.block(k).trial(1).rewardScale];

            %Block statistics
            fwdIdx = forward & blockIdx==k; %Forward trials: mouse did not turn back
            nTrials(k) = numel(logs.block(k).trial);
            nCompleted(k) = sum(~omit & blockIdx==k);
            nForward(k) = sum(fwdIdx);
            pCorrect(k) = mean(correct(~omit & blockIdx==k));
            pCorrect_congruent(k) = mean(correct(~omit & congruent & blockIdx==k));
            pCorrect_conflict(k) = mean(correct(~omit & conflict & blockIdx==k));
            pOmit(k) = mean(omit(blockIdx==k));

            %Sensory cues
            pLeftTowers(k) = sum(leftTowers(blockIdx==k))...
                /sum(blockIdx==k);
            pLeftPuffs(k) = sum(leftPuffs(blockIdx==k))...
                /sum(blockIdx==k);
            pLeftCues(k) = sum(leftCues(blockIdx==k))...
                /sum(blockIdx==k);

            %Motor
            pStuck(k) = mean(stuck(~omit & blockIdx==k));
            median_velocity(k) = median(trialData(j).mean_velocity(fwdIdx,2)); %Median velocity across all completed trials (x,y,theta)
            median_pSkid(k) = median(trialData(j).pSkid(fwdIdx)); %Median proportion of maze where mouse skidded along walls
            median_stuckTime(k) = median(trialData(j).stuck_time(fwdIdx),'omitnan');

            %Perceptual bias
            leftSensitivity = sum(leftCues(left & blockIdx==k))/sum(leftCues(blockIdx==k));
            rightSensitivity = sum(rightCues(right & blockIdx==k))/sum(rightCues(blockIdx==k));
            if rule(k)=="forcedChoice"
                leftSensitivity = sum(leftCues(left & blockIdx==k))/sum(leftCues(blockIdx==k));
                rightSensitivity = sum(rightCues(right & blockIdx==k))/sum(rightCues(blockIdx==k));
            end
            bias(k) = rightSensitivity-leftSensitivity;

            %Motor bias
            median_response_delay = median(trialData(j).response_delay(fwdIdx));
            median_delay_bias = median(trialData(j).response_delay(fwdIdx & right))...
                - median(trialData(j).response_delay(fwdIdx & left));

            %Moving average correct rate (100 trial moving window)
            tempCorrect = double(correct(blockIdx==k) & ~exclude(blockIdx==k));
            tempCongruent = congruent(blockIdx==k) & ~exclude(blockIdx==k);
            hits = struct('all',tempCorrect,'congruent',tempCorrect,'conflict',tempCorrect);
            hits.congruent(~tempCongruent) = NaN;
            hits.conflict(tempCongruent) = NaN;
            for fields = ["all","congruent","conflict"]
                movmeanAccuracy(k).(fields) = movmean(hits.(fields),[99 0],'omitnan','Endpoints','discard');
                maxmeanAccuracy(k).(fields) = max(movmeanAccuracy(k).(fields));
                if isempty(maxmeanAccuracy(k).(fields))
                    maxmeanAccuracy(k).(fields) = NaN;
                end
            end

            %Moving average perceptual bias
            hits = struct('left',NaN(1,sum(blockIdx==k)),'right',NaN(1,sum(blockIdx==k)));
            hits.left(leftCues(blockIdx==k)) = left(leftCues & blockIdx==k);
            hits.right(rightCues(blockIdx==k)) = right(rightCues & blockIdx==k);
            leftSensitivity = movmean(hits.left,[99 0],'omitnan','Endpoints','discard');
            rightSensitivity = movmean(hits.right,[99 0],'omitnan','Endpoints','discard');
            movmeanAccuracy(k).bias = rightSensitivity-leftSensitivity;

        end

        %Psychometric curves & histogram of cue counts for whole session
        cueHistogram = struct('puffs',[],'towers',[],'edges',[]);
        nBins = 4; %bins per cueSide
        psychometric.all = getPsychometricCurve(trialData(j), trials(j), ~trials(j).exclude, nBins);
        if any(trials(j).conflict) %Multimodal sessions
            trialSubset = trials(j).congruent & ~trials(j).exclude;
            psychometric.congruent = getPsychometricCurve(trialData(j), trials(j), trialSubset, nBins);
            trialSubset = trials(j).conflict & ~trials(j).exclude;
            psychometric.conflict = getPsychometricCurve(trialData(j), trials(j), trialSubset, nBins);
        end

        %Cue histogram
        nTowers = trialData(j).nTowers;
        nPuffs = trialData(j).nPuffs;
        edges = -max(abs([nTowers(:); nPuffs(:)])) : max(abs([nTowers(:); nPuffs(:)])+1);
        cueHistogram.towers = histcounts(diff(nTowers,[],2), edges);
        cueHistogram.puffs = histcounts(diff(nPuffs,[],2), edges);
        cueHistogram.edges = edges;

        %Histogram of omissions for each cue count
        cueHistogram.omit.towers = histcounts(diff(nTowers(trials(j).omit,:),[],2), edges);
        cueHistogram.omit.puffs = histcounts(diff(nPuffs(trials(j).omit,:),[],2), edges);

        %Store session data
        sessions(j) = struct(...
            'session_date', datetime(sessionDate(j)),...
            'level', mazeLevel,...
            'taskRule', rule,...
            'reward_scale', reward_scale,...
            'maxSkidAngle', maxSkidAngle,...
            'lCue',arrayfun(@(B) lCue(B), 1:numel(logs.block)),...
            'lMem',arrayfun(@(B) lMem(B), 1:numel(logs.block)),...
            'lMaze',arrayfun(@(B) lMaze(B), 1:numel(logs.block)),...
            'nTrials', nTrials,...
            'nCompleted', nCompleted,...
            'nForward', nForward,...
            'pCorrect', pCorrect,...
            'pCorrect_congruent', pCorrect_congruent,...
            'pCorrect_conflict', pCorrect_conflict,...
            'pOmit', pOmit,...
            'pLeftTowers', pLeftTowers,...
            'pLeftPuffs', pLeftPuffs,...
            'pLeftCues', pLeftCues,...
            'pStuck', pStuck,...
            'movmeanAccuracy', movmeanAccuracy,...
            'maxmeanAccuracy', [maxmeanAccuracy.all],...
            'maxmeanAccuracy_congruent', [maxmeanAccuracy.congruent],...
            'maxmeanAccuracy_conflict', [maxmeanAccuracy.conflict],...
            'median_velocity', median_velocity,... %Mean velocity across all completed trials (x,y,theta)
            'median_response_delay', median_response_delay,... %Median delay between turn entry and choice
            'median_delay_bias', median_delay_bias,... %Diff median delay R-L
            'median_pSkid', median_pSkid,... %Mean proportion of maze where mouse skidded along walls
            'median_stuckTime', median_stuckTime,...
            'bias', bias,...
            'psychometric', psychometric,...
            'cueHistogram', cueHistogram,...
            'excludeBlocks', excludeBlocks,...
            'new_remote_path_behavior_file', dataPath);

        clearvars -except i subjects sessions trials trialData key sessionDate
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