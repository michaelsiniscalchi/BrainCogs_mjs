%Analysis of accuracy~nCues+nDistractors


%First, load data for subject
% load('X:\michael\mjs_tactile2visual\results\mjs20_913.mat');
sessions = sessions([sessions.taskRule]~="forcedChoice"); %Filter to only visual or tactile sessions

%Get GLM results
glm = [sessions.glm3];

for f = ["nCues", "nDistractors","nCuesXconflict", "nDistractorsXconflict"]

    for i=1:numel(glm)
        coef.(f)(i,:) = [glm(i).(f).beta];
        pVal.(f)(i,:) = [glm(i).(f).p];
    end
meanCoef.(f) = mean(coef.(f));
scores.(f) = exp(coef.(f))./(1+exp(coef.(f))); %odds ratio
pSig.(f) = mean(pVal.(f)<0.01);
meanDeltaP.(f) = mean(abs(scores.(f)-0.5));
end