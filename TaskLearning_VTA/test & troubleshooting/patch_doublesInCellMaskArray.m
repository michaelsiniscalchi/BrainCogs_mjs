function patch_doublesInCellMaskArray(subjID, dataDir)

%% Locate ROI data from all Sessions from Specified Subject and Check Cell Masks

% Search for ROI directories
temp = dir(fullfile(dataDir,['*' subjID '*']));
for i = 1:numel(temp)
    dirs.sessions{i} = fullfile(dataDir,temp(i).name);
end

for i=1:numel(dirs.sessions)
    temp = dir(fullfile(dirs.sessions{i},'ROI*.tif'));
    temp = temp([temp.isdir]); %Get only the directories
    if ~isempty(temp)
        dirs.roi{i} = fullfile(dirs.sessions{i}, temp.name);
    end
end
dirs.roi = dirs.roi(~cellfun(@isempty,dirs.roi));

%Load cellmasks from ROI files and replace doubles with logical
for i = 1:numel(dirs.roi)
    disp(['Checking ', fileparts(dirs.roi{i}), '...']);
    fileList = dir(fullfile(dirs.roi{i},'cell*.mat'));
    for j = 1:numel(fileList)
        filepath = fullfile(dirs.roi{i}, fileList(j).name);
        S = load(filepath,'bw');
        if ~islogical(S.bw)
            bw = logical(S.bw);
            disp(['Cell mask in ', fileList(j).name, ' converted to logical.']);
            save(filepath, 'bw', '-append');
        end
    end

end