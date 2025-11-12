session = subjects.sessions;
trialData = subjects.trialData;
trials = subjects.trials;

disp('------------------');
disp('------------------');

%Response Time
for f = ["leftTowers","rightTowers","leftPuffs","rightPuffs"]
    idx = trials.(f);
    responseTime.(f) = mean(trialData.response_time(idx),1,"omitnan");
    disp(strjoin(['Response time,', f, 'trials:', num2str(responseTime.(f))],' '));
end
disp('------------------');
%Time to Complete Cue Region
for f = ["leftTowers","rightTowers","leftPuffs","rightPuffs"]
    idx = trials.(f);
    cueRegionTime.(f) = mean(trialData.duration_cueRegion(idx),1,"omitnan");
    disp(strjoin(['Time to complete cue region,', f, 'trials:', num2str(cueRegionTime.(f))],' '));
end
disp('------------------');
%Response Delay
for f = ["leftTowers","rightTowers","leftPuffs","rightPuffs"]
    idx = trials.(f);
    responseDelay.(f) = mean(trialData.response_delay(idx),1,"omitnan");
    disp(strjoin(['Response delay,', f, 'trials:', num2str(responseDelay.(f))],' '));
end
disp('------------------');
disp(['Median delay bias: ', num2str(session.median_delay_bias)]);