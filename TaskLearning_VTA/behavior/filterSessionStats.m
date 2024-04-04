function subjects_out = filterSessionStats( subjects )
%%

fields.params = ["taskRule","level","reward_scale","maxSkidAngle","lCue","lMem","lMaze"];
fields.counts = ["nTrials","nCompleted","nForward"];
fields.mean = ["pCorrect","pCorrect_congruent","pCorrect_conflict",...
    "pLeftTowers","pLeftPuffs","pLeftCues","pOmit","pStuck"];
fields.max = ["maxCorrectMoving","maxCorrectMoving_congruent","maxCorrectMoving_conflict"];
fields.other = ["median_velocity","median_pSkid","median_stuckTime","bias"];

for i = 1:numel(subjects)
    exclSessionIdx = false(size(subjects(i).sessions));
    for j = 1:numel(subjects(i).sessions)
        
        %Get main task rule (excl. isolated forced-choice blocks, etc.)
        S = subjects(i).sessions(j);

        ruleNames = ["visual","tactile","sensory","alternation"];
        inclBlockIdx = ismember(S.taskRule, ruleNames);
        if ~isempty(S.taskRule) && all(S.taskRule=="forcedChoice")
            inclBlockIdx = S.taskRule=="forcedChoice" & S.nCompleted==max(S.nCompleted); %Just use majority block for shaping
        elseif any(S.taskRule=="visual") && any(S.taskRule=="tactile") %check for any mixed sessions and flag for block exclusion
            warning(strjoin(["Session from " subjects(i).ID ", " string(S.session_date) "was mixed between rules. Check!"]));
        elseif all(~inclBlockIdx)
            disp('Warning: "taskRule" must be one of the following: "forcedChoice","visual","tactile","sensory","alternation"...');
            disp('Excluding all blocks in');
            disp(S.new_remote_path_behavior_file);
            exclSessionIdx(j) = true;
            continue
        end

        %Filter out excluded blocks
        if ~isempty(S.excludeBlocks)
            inclBlockIdx(S.excludeBlocks) = false;
        end

        %No further processing for sessions with only one main block
        if isequal(inclBlockIdx,true)
            continue
        end

        %Filter session stats to exclude warmup blocks
        for F = [fields.params, fields.counts, fields.mean, fields.max, fields.other]
            S.(F) = S.(F)(inclBlockIdx);
        end

        %Session parameters
        for F = fields.params, S.(F) = S.(F)(end); end %Report params for final level in session

        %Mean/proportional quantities
        weights = S.nCompleted ./ sum(S.nCompleted); %Weight sensory or alternation stats by the respective number of trials
        for F = ["pCorrect","pCorrect_congruent","pCorrect_conflict"] %Calculated across completed trials
            S.(F) = sum(S.(F) .* weights);
        end

        weights = S.nTrials ./ sum(S.nTrials); %Weight sensory or alternation stats by the respective number of trials
        for F = ["pOmit","pStuck","pLeftTowers","pLeftPuffs","pLeftCues"] %Calculated across all trials
            S.(F) = sum(S.(F) .* weights);
        end

        %Counts
        for F = fields.counts, S.(F) = sum(S.(F)); end

        %Max quantities
        for F = fields.max, S.(F) = max(S.(F)); end

        %% Recalculate from TrialData or "Trials" vectors
        trials = subjects(i).trials(j); %unpack
        trialData = subjects(i).trialData(j); %unpack
        blockIdx = ismember(trials.blockIdx,find(inclBlockIdx)); %Index for trials within included block(s)

        %Truncate field 'trials': trial masks
        fieldStr = string(fieldnames(trials));
        for f = fieldStr'
            trials.(f) = trials.(f)(blockIdx);
        end

        %Truncate field 'trialData'
        fieldStr = string(fieldnames(trialData));
        fieldStr = fieldStr(~ismember(fieldStr,... Exclude fields where D1 is not trial number
            {'session_date','x_trajectory','theta_trajectory','time_trajectory','positionRange'}));
        for f = fieldStr'
            trialData.(f) = trialData.(f)(blockIdx,:);
        end

        %Truncate position-based trajectories
        fieldStr = ["x_trajectory","theta_trajectory","time_trajectory"];
        for f = fieldStr
            if iscell(trialData.(f))
                trialData.(f) = trialData.(f)(inclBlockIdx); %Sessions with multiple maze lengths stored in cell arrays
            else
                trialData.(f) = trialData.(f)(:,blockIdx); %Dimensions flipped to pos x trial
            end
        end

        %Recalculate kinematic quantities (recalculate median values)
        trialMask = trials.forward & ~trials.omit;
        S.median_velocity = median(trialData.mean_velocity(trialMask,2)); %Median Y-velocity across all completed trials
        S.median_pSkid = median(trialData.pSkid(trialMask)); %Median proportion of maze where mouse skidded along walls
        S.median_stuckTime = median(trialData.stuck_time,'omitnan'); %Median proportion of time spent stuck as result of friction

        %Choice bias
        leftError = sum(trialMask & trials.error & trials.left)...
            / sum(trials.left(trialMask));
        rightError = sum(trialMask & trials.error & trials.right)...
            / sum(trials.right(trialMask));
        S.bias = rightError-leftError;

        %Replace edited fields
        subjects(i).sessions(j) = S;
        subjects(i).trialData(j) = trialData;
        subjects(i).trials(j) = trials;
    end
    %Exclude any sessions with no data (or different task, etc)
    for f = ["logs","sessions","trialData","trials"]
        subjects(i).(f) = subjects(i).(f)(~exclSessionIdx);
    end


end

%Output modified structure
subjects_out = subjects;