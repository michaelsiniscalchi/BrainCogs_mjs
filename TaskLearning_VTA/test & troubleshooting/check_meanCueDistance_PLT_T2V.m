%PLT
trials = log.block.trial;
for i = 1:numel(trials)
    P(i) = [trials(i).CS.position(1)];
end
firstCuePos = mean(P);

%Frame rate
for i = 1:numel(trials)
    dt(i) = median(diff(trials(i).time));
end
frameRate = 1/mean(dt);

%T2V
trials = log.block(end).trial;
%Frame rate
for i = 1:numel(trials)
    dt(i) = median(diff(trials(i).time));
end
frameRate = 1/mean(dt);
