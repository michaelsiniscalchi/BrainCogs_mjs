function sessionStructArray = appendPsyTrackWeights( sessionStructArray, psyStruct )

%Append PsyTrack coefficients and se to sessions array
for i = 1:numel(sessionStructArray)
    idx = psyStruct.session_date==sessionStructArray(i).session_date;
    if any(idx)
        for f = ["meanCoef","sd"]
            for ff = string(fieldnames(psyStruct.(f)))'
                sessionStructArray(i).(strjoin(['psyTrack',ff,f],'_'))(:,1) = psyStruct.(f).(ff)(idx,:);
            end
        end
    end
end