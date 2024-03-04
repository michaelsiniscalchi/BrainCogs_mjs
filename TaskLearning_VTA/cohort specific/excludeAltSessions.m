function subjects = excludeAltSessions(subjects)

%Exclude sessions with Alternation trials
for i=1:numel(subjects)
    sessionMask =...
        [subjects(i).sessions.taskRule] ~= "alternation";
    subjects(i).logs = subjects(i).logs(sessionMask);
    subjects(i).trials = subjects(i).trials(sessionMask);
    subjects(i).trialData = subjects(i).trialData(sessionMask);
    subjects(i).sessions = subjects(i).sessions(sessionMask);

end