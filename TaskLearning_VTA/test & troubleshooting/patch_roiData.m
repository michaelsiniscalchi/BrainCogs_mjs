dataDir = 'X:\michael\network-batch\rois';
searchStr = '-m';

% Search for ROI directories
temp = dir(fullfile(dataDir,['*' searchStr '*']));
for i = 1:numel(temp)
    dirs.sessions{i} = fullfile(dataDir,temp(i).name);
end

for i=1:numel(dirs.sessions)
    temp = dir(fullfile(dirs.sessions{i},'ROI*.tif'));
    temp = temp([temp.isdir]); %Get only the directories
    if ~isempty(temp)
        dirs.roi{i} = fullfile(dirs.sessions{i},temp.name);
    end
end
dirs.roi = dirs.roi(~cellfun(@isempty,dirs.roi));

%%
for i = 1:numel(dirs.roi)
    roiFile = fullfile(dirs.roi{i},'roiData.mat');
    S = load(roiFile);
    %PATCH: fix variable names for old sessions
    if isfield(S,'mean_proj')
        S.mean = S.mean_proj; S=rmfield(S,'mean_proj');
    end
    if isfield(S,'var_proj')
        S.var = S.var_proj; S=rmfield(S,'var_proj');
    end
    if isfield(S,'max_proj')
        S.max = S.max_proj; S=rmfield(S,'max_proj');
    end
    if isfield(S,'filename')
        S.FileName = S.filename; S=rmfield(S,'filename');
    end
   save(roiFile,'-struct',"S");
end