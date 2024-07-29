subjects = struct(...
    'ID',    {'mjs20_439','mjs20_665','mjs20_441','mjs20_443','mjs20_447','mjs20_449','mjs20_658'},...
    'rigNum',{"rig1",     "rig2",     "rig3",     "rig4",     "rig5",     "rig6",     "rig7"},...
    'startDate', datetime('2021-02-08'), 'experimenter', 'mjs20', 'waterType', 'Milk');

data = getDBData(subjects);

%Example files for mjs20_439
subjIdx = 1;
bucket = fullfile('Y:','RigData','training',subjects(subjIdx).rigNum,...
    'msiniscalchi','data',subjects(subjIdx).ID);

fnames = {...
    'mjs_memoryMaze_cohort1_TrainVR1_mjs20_439_T_20210218.mat';...
    'mjs_memoryMaze_cohort1_TrainVR1_mjs20_439_T_20210219.mat';...
    };

for i=1:numel(fnames)
    %Get data from MAT file
    S = load(fullfile(bucket, fnames{i}));
    disp({'From file:';...
        fnames{i};...
        S.log.animal.name;...
        datetime(S.log.session.end);...
        'rewardMil by block:'
        [S.log.block(:).rewardMiL];...
        });
    
    %Data from DB
    blockDate = datetime({data.performance.(subjID).session_date})';
    sessionDate = datetime(S.log.session.end(1:3)); %Example session
    idx = blockDate==sessionDate;
    rewEarned = [data.performance.(subjID)(idx).reward_mil];
    
    disp({'From DB:';...
        data.performance.(subjID)(idx).subject_fullname;...
        data.performance.(subjID)(idx).session_date;...
        'rewardMil by block:'
        [data.performance.(subjID)(idx).reward_mil];...
        });
    
end

%From Alvaro:

% key = struct();
% key.subject_fullname = 'mjs20_439';
% key.session_date   = '2021-02-18';
% fields = {'remote_path_behavior_file'};
% data_dir = fetch(acquisition.SessionStarted & key, fields{:});
% [~, acqsession_file] = lab.utils.get_path_from_official_dir(data_dir.remote_path_behavior_file);
% %Load behavioral file
% try
%   data = load(acqsession_file,'log');
%   log = data.log;
% catch err
%   disp(err)
%   disp(['Could not open behavioral file: ', acqsession_file])
% end
% 
% disp([data.log.block.rewardMiL]);

function data = getDBData( subjects, varargin)

% table data requested will be specified in 'varargin'

%Water administration and weighing data
for i = 1:numel(subjects)
    query = ...
        proj(action.Weighing, 'date(weighing_time)->administration_date', 'weight', 'weigh_person')...
        * action.WaterAdministration & struct('subject_fullname', subjects(i).ID);
    data.intake.(subjects(i).ID) = fetch(query,'*');
end

%Behavior session data
for i = 1:numel(subjects)
    query = proj(behavior.TowersBlock,...
        'level','n_trials','block_duration','reward_mil','reward_scale','block_performance')...
        & struct('subject_fullname', subjects(i).ID);
    data.performance.(subjects(i).ID) = fetch(query,'*');
end

end
