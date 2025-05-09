function [sessionIDs] = patch_roiData(subjID, dataDir)

%Initialize
sessionIDs = {};

%% Locate ROI data and Time-Projections from all Sessions from Specified Subject

% Search for ROI directories
temp = dir(fullfile(dataDir,['*' subjID '*']));
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

%Rename projections to match current App
fields = {'var_proj','mean_proj','max_proj','filename'};
for i = 1:numel(dirs.roi)
    S = load(fullfile(dirs.roi{i},'roiData.mat'),...
        fields{:}, 'mean','var','max','FileName');
    if any(isfield(S, fields))
        sessionIDs{i,1} = dirs.roi{i}; %#ok<AGROW>
        %Replace fields
        for f = string(fields)
            if ~isfield(S,f)
                continue
            else
                switch f
                    case 'mean_proj'
                        S = replaceField(S, f, 'mean', sessionIDs{i});
                    case 'var_proj'
                        S = replaceField(S, f, 'var', sessionIDs{i});
                    case 'max_proj'
                        S = replaceField(S, f, 'max', sessionIDs{i});
                    case 'filename'
                        S = replaceField(S, f, 'FileName', sessionIDs{i});
                end
            end
        end
        save(fullfile(dirs.roi{i},'roiData.mat'),'-struct',"S");
    end

    %Remove ROI files with no cell mask
    fileList = dir(fullfile(dirs.roi{i},'cell*.mat'));
    for j = 1:numel(fileList)
        filepath = fullfile(dirs.roi{i},fileList(j).name);
        S = load(filepath,'bw');
        if isempty(S.bw)
            delete(filepath);
            disp('No ROI found in:');
            disp(filepath);
            disp('File deleted.');
        end
    end

end

function S = replaceField(S, oldFieldName, newFieldName, sessionID)
S.(newFieldName) = S.(oldFieldName);
S = rmfield(S, oldFieldName);
disp("roiData.mat modified in:")
disp(sessionID);
disp([oldFieldName,' replaced with ', newFieldName]);