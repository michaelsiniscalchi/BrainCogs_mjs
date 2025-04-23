clearvars;
dataDir =  'X:\michael\network-batch\rois';
subjID = 'M42';

% Search for ROI directories
temp = dir(fullfile(dataDir,['*' subjID '*']));
for i = 1:numel(temp)
    dirs.sessions{i,1} = fullfile(dataDir,temp(i).name);
end

for i=1:numel(dirs.sessions)
    temp = dir(fullfile(dirs.sessions{i},'ROI*.tif'));
    temp = temp([temp.isdir]); %Get only the directories
    if ~isempty(temp)
        dirs.roi{i,1} = fullfile(dirs.sessions{i},temp.name);
    end
end
dirs.roi = dirs.roi(~cellfun(@isempty,dirs.roi));

for i = 1:numel(dirs.roi)
    file_list = dir(fullfile(dirs.roi{i},'*cell*.mat'));

    for j = 1:numel(file_list)
        filepath = fullfile(dirs.roi{i}, file_list(j).name);
        S = load(filepath,'sessionID','bw','cellf');
        if isempty(S.bw)
            warning(['Deleting file: ', filepath]);
            delete(filepath);
        end
    end
end

