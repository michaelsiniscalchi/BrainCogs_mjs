function cells = summarize_sessions2cells(sessions)

%For each cell, create vector length nSessions of kernels, coefs, etc.; 
% nan if absent
% clearvars cellIDs cells S

coefNames = string(fieldnames(sessions(1).predictorIdx));
coefParams = string(fieldnames(sessions(1).coef));
kernelNames = string(fieldnames(sessions(1).kernel));
kernelParams = string(fieldnames(sessions(1).kernel(1).start));

session_date = [sessions(:).session_date];

predictorIdx = sessions(1).predictorIdx;

%Aggregate all data into cell arrays
for i = 1:numel(sessions)
    S.cellIDs{i,:} = sessions(i).cellID;
    for j = 1:numel(sessions(i).kernel) %For each cell
        %Response kernels for event-variables
        S.session_date{i,:}{j,:} = session_date(i); %SessionID for each entry
        for kName = kernelNames'
            for kParam = kernelParams'
                S.kernel.(kName).(kParam){i,:}{j,:} =...
                    (sessions(i).kernel(j).(kName).(kParam)); %one cell per entry
            end
        end
        %Coefficients for kinematic vars, etc.
        for cName = coefNames'
            for cParam = coefParams'
                S.coef.(cName).(cParam){i,:}{j,:} =...
                    sessions(i).coef.(cParam)(j, predictorIdx.(cName));
            end
        end
    end
end

%Create struct array with one element per cellID
% eg, {S.kernel.start.L2}, cell, length N non-unique neurons across all sessions
cellList = unique(cat(1, S.cellIDs{:}));
cells = struct('cellID',cellList);

S.cellIDs = cat(1, S.cellIDs{:});
S.session_date = cat(1, S.session_date{:});
for f = string(fieldnames(S))'
    if isstruct(S.(f))
        for ff = string(fieldnames(S.(f)))'
            for fff = string(fieldnames(S.(f).(ff)))'
                %Concatenate data for indexing by cellID
                allValues = cat(1, S.(f).(ff).(fff){:}); %cell array of values for all cells, all sessions
                for i = 1:numel(cellList)
                    dataIdx = strcmp(S.cellIDs, cellList{i}); %Index data by unique cell ID
                    %Assign session IDs
                    if ~isfield(cells,'session_date') || isempty(cells(i).session_date)
                        cells(i).session_date = cat(1, S.session_date{dataIdx});
                    end
                    %Assign values, eg cells(1).coef.velocity.estimate(nSessions,:)
                    C = allValues(dataIdx); %Get all values from this cellID
                    if fff=="x"
                        cells(i).(f).(ff).(fff) = C{1}; %Time bins should be nearly identical (rounding error)
                    elseif size(C{1}, 1)==1 %Scalar or row vector data
                        cells(i).(f).(ff).(fff) = cell2mat(C);
                    else %Multi-row data like SE
                        cells(i).(f).(ff).(fff) = C;
                    end
                end
            end
        end
    end
end

disp('done.');

