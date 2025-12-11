function [ Beh, Beh_vect ] = filterImgSessions(sessions)

%Aggregate scalar session data in struct array
for i = 1:numel(sessions)
    %General Session Data
    for f = ["session_date", "taskRule", "pCorrect", "pCorrect_congruent",...
            "pCorrect_conflict", "pLeftTowers", "pLeftPuffs"]
        Beh(i).(f) = sessions(i).(f);
    end
    
    %GLM
    for f = sessions(i).glm1.predictors
        for ff = ["beta","se","p"]
            Beh(i).(strjoin(['glm1',f,ff],'_')) = sessions(i).glm1.(f).(ff); %eg, glm1.puffs.beta
        end
    end
    %Fit
    for f = ["R2_adj","conditionNum"]
            Beh(i).(strjoin(['glm1',f],'_')) = sessions(i).glm1.(f);
    end
    %Side-specific cue sensitivity
    %sensitivity_LR = abs([mean(rightChoice(~rightCues)), mean(rightChoice(rightCues))]-bias);
    for f = ["puffs","towers"]
         Beh(i).(strjoin(['sensitivity',f,'left'],'_')) = sessions(i).glm1.sensitivity.(f)(1);
         Beh(i).(strjoin(['sensitivity',f,'right'],'_')) = sessions(i).glm1.sensitivity.(f)(2);         
    end

end

%Aggregate in single struct with vector-valued terminal fields
for f = string(fieldnames(Beh))'
    Beh_vect.(f) = [Beh.(f)];
end
    
% y = sessions(10).psychometric.towers.pRight_binned;
% x = sessions(10).psychometric.towers.bins;
%     figure; plot(x,y)