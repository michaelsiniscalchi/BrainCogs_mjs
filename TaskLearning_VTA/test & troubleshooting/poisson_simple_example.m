clearvars;

%Draw cue counts for large number of trials and generate positions from
%random intervals in each trial.
for i = 1:10000
    nCues(i) = poissrnd(4);
    intervals.exp{i,:} = exprnd(1/nCues(i),[nCues(i),1]); %Draw intervals from an exponential with mean=1/nCues (lambda)
    positions.exp{i,:} = cumsum(intervals.exp{i}); %Positions derived from intervals

    intervals.uni{i,:} = rand([nCues(i),1])*(1/nCues(i)); %Draw intervals from a Uniform with max=1/nCues
    positions.uni{i,:} = cumsum(intervals.uni{i});
end
%Aggregate across "trials"
intervals.exp = cell2mat(intervals.exp);
positions.exp = cell2mat(positions.exp);
intervals.uni = cell2mat(intervals.uni);
positions.uni = cell2mat(positions.uni);

f = fieldnames(intervals);
bins = 0:0.05:1;
for i = 1:2
figure;

subplot(1,2,1)
histogram(intervals.(f{i}), bins)
xlabel("Distance between towers (cm)");
ylabel("Number of instances");
title(['Inter-Tower Intervals: ',f{i}]);
axis square;

subplot(1,2,2)
histogram(positions.(f{i}), bins)
xlabel("Tower position (cm)");
ylabel("Number of instances");
title(['Position:',f{i}]);
axis square;
end

