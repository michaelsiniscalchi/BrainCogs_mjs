%INCOMPLETE: exclude sessions with no psytrack data
psyDates = [sessions(~cellfun(@isempty,{sessions.psyTrack_bias_meanCoef})).session_date]; %Dates w/ psyTrack weights
% C(i).session_date = C(i).session_date(ismember(C(i).session_date, psyDates)); %Exclude any sessions without psytrack weights
for i = 1:numel(cells)
    idx = ismember(cells(i).session_date, psyDates);
    cells(i).session_date = cells(i).session_date(idx);
    for f = ["kernel","coef"]
        for ff = string(fieldnames(cells(i).(f)))'
              cells(i).(f).(ff) = cells(i).(f).(ff)(idx);
        end
    end
end