function trajectories = getTrajectoryDist(subjects)

S = subjects;
trajectories = struct();

for i = 1:numel(subjects)


    %Session indices
    sensoryIdx = cellfun(@(Level) all(ismember(Level,4)),{S(i).sessions.level});
    memIdx = cellfun(@(Level) all(ismember(Level,5)),{S(i).sessions.level}); 
    %Trial indices
    trialType = ["forward","exclude","left","right","correct","error"];
    for j = 1:numel(trialType)
    idx.(trialType(j)) = {S(i).trials.(trialType(j))};
    end
    
    %X-Position
%     x_trajectory.trials. = arrayfun(@(sesIdx) ...
%         S(i).trialData(sesIdx).x_trajectory(fwd{sesIdx} & ~exclude{sesIdx}),...
%         1:numel(S(i).trials),'UniformOutput',false);
    
    %Theta
    
    theta_traj = [];
    
    trials.all = arrayfun(@(sesIdx) (fwd{sesIdx} & ~exclude{sesIdx}),...
        1:numel(S(i).trials),'UniformOutput',false);
    
    pExcluded = arrayfun(@(sesIdx) numel(trials{sesIdx})/numel(fwd{sesIdx}),...
        1:numel(S(i).trials)); 

    
    trajectories.(S(i).ID) = struct('trials',trials,'pExcluded',pExcluded,'');
end
% viewAngle.all = ;

% idx=1;
% for i=1:numel(subjects(idx).trials)
%     C = {subjects(idx).trials.forward};
% end
% 
% 
% M = cellfun(@mean,C);