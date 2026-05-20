function [ nLicksCue, nLicksReward ] = getLicksPerEpoch( eventTimes )

%Count the number of licks between cue and outcome, as well as equal period post-outcome
for i = 1:numel(eventTimes)
    %Count licks between cue and outcome
    nLicksCue(i) = sum((eventTimes(i).licks>eventTimes(i).firstCue) &...
        (eventTimes(i).licks<eventTimes(i).outcome));
    %Count licks over equal interval following reward
    rewardEnd = eventTimes(i).outcome + (eventTimes(i).outcome-eventTimes(i).firstCue);
    nLicksReward(i) = sum(eventTimes(i).licks>eventTimes(i).outcome &...
        eventTimes(i).licks<rewardEnd);
end
