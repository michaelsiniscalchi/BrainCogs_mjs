function subjects = loadExperData( subjectID, dirs )

for i = 1:numel(subjectID)
    fname = fullfile(dirs.results, subjectID{i});
    disp(['Loading local: ' fname '...']);
    subjects(i) = load(fname, 'ID', 'sessions', 'trialData', 'trials'); %Leave out logs
end