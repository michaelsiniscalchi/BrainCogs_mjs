function subject = loadExperData( subjectID, dirs )

for i = 1:numel(subjectID)
    fname = fullfile(dirs.results, [subjectID{i}, '.mat']);
    disp(['Loading local: ' fname '...']);
    subject(i) = load(fname, 'ID', 'sessions', 'trialData', 'trials'); %Leave out logs
end