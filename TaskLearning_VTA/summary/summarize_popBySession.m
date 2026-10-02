function population = summarize_popBySession( sessions )      

%Matrix of p-values (nCells x nSessions) 
allSessionDates = [sessions.session_date];
allCellIDs = string(unique(cat(1,sessions.cellID))); %cell IDs from all sessions
exclAggregates = ~isnan(str2double(allCellIDs)); %Index excluding ROI/FOV aggregates, eg 'cellfov' or 'allCells'
alpha = unique([sessions.alpha]);
for f = string(fieldnames([sessions.pValues]))'
     pValues.(f) = NaN(numel(allCellIDs), numel(allSessionDates)); %initialize
     for dateIdx = 1:numel(allSessionDates)
         cellIdx = ismember(allCellIDs, sessions(dateIdx).cellID); %cell IDs present in session(i)
         pValues.(f)(cellIdx, dateIdx) =  sessions(dateIdx).pValues.(f);
         %Calculate proportion of cells with significant coefficients
         cellIdx = cellIdx & exclAggregates; %cell IDs present in session(i)
         pSignificant.(f)(dateIdx) = mean(pValues.(f)(cellIdx, dateIdx)<alpha);
     end
end
N = sum(~isnan(pValues.(f)(exclAggregates,:)),1); %Number of cells (excluding aggregate ROIs)

%Population summary structure
population = struct(...
    'sessionDates', allSessionDates,...
    'cellIDs', allCellIDs,...
    'pValues', pValues,...
    'pSignificant', pSignificant,...
    'N', N,...
    'alpha', alpha...
    );