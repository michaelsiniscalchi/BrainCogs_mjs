function [ path, log ] = loadRemoteVRFile( key )

load_mat = false;
if nargout > 1
    load_mat = true;
end

% %Create key for fetch from DJ
% key = struct();
% key.subject_fullname = char(subjectID); %Must be char, even though annotation says 'string'
% key.session_date   = char(sessionDate);
% if nargin > 2
%     key.session_number   = sessionNumber;
% end

%Load remote file(s)
data_dir = fetch(acquisition.SessionStarted & key, 'new_remote_path_behavior_file');
path = string({data_dir.new_remote_path_behavior_file}');
for i = 1:numel(data_dir)
    [~, path(i)] = lab.utils.get_path_from_official_dir(data_dir(i).new_remote_path_behavior_file);
end

%Load behavioral file(s)
if load_mat
    for i = 1:numel(path)
        try
            disp(['Loading ' data_dir(i).new_remote_path_behavior_file '...']);
            data = load(path(i),'log');
            log(i) = data.log;
            log(i) = removeEmpty(log(i), data_dir(i).new_remote_path_behavior_file);
        catch err
            disp(err)
            disp(['Could not open behavioral file: ', path(i)])
        end
    end
end

%Error handling for absent output
if ~exist('log','var')
    log = [];
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