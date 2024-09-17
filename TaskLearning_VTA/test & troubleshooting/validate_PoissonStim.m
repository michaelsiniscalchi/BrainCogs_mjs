

% Simulate standard ATT and Poisson cue distributions
clearvars;

nTrials = 8000;
meanNumCues = 4.8; %mean cue count per 200 cm (one side only for simulation)
lenCueRegion = 200;
minSpacing = 12; % "refractory interval" from ATT 
maxCues = floor(lenCueRegion/minSpacing);

[Pos.Poisson, Pos.Uniform, Int.Poisson, Int.Uniform] = deal(cell(nTrials,1));

for i = 1:nTrials
    nCues(i) = inf; %Initialize
    while nCues(i) > maxCues || nCues(i)==0
        nCues(i) = poissrnd(meanNumCues);
    end

    %The random portion of the intertower interval (after subtracting the fixed min interval)
    effectiveLen = lenCueRegion/nCues(i) - minSpacing; %Intervals determine positions, so initialize one cue at 0 then circular shift

    %Spatial Poisson: exponentially dist. inter-tower intervals
    intervals = inf; %Initialize
    while sum(intervals) > lenCueRegion %Distribution right-truncated to fit maze length 
        %Exp(lambda) with lambda = mean distance between towers 
        intervals = exprnd(effectiveLen, [nCues(i),1]) + minSpacing; %Recenter exponential to implement refractory interval
        positions = cumsum(intervals); %Place one cue at 0 (later, circular shift)
    end
    if isempty(positions)
        dbstop
    end
    [Pos.Poisson{i}, Int.Poisson{i}] = shiftPositions(positions, lenCueRegion);
    
    %Poisson counts with Uniform dist. inter-tower intervals
    intervals = effectiveLen*rand([nCues(i),1]) + minSpacing; %Including interval before first cue
    positions = cumsum(intervals); 
    [Pos.Uniform{i}, Int.Uniform{i}] = shiftPositions(positions, lenCueRegion);

end

%Aggregate into matrices
Pos.Poisson = cell2mat(Pos.Poisson);
Pos.Uniform = cell2mat(Pos.Uniform);
Int.Poisson = cell2mat(Int.Poisson);
Int.Uniform = cell2mat(Int.Uniform);

%Figures
f = fieldnames(Int);
bins = 0:10:200;
for i = 1:2
figure;

subplot(1,2,1)
histogram(Int.(f{i}), bins)
xlabel("Distance between towers (cm)");
ylabel("Number of instances");
title(['Inter-Tower Intervals: ',f{i}]);
axis square;

subplot(1,2,2)
histogram(Pos.(f{i}), bins)
xlabel("Tower position (cm)");
ylabel("Number of instances");
title(['Position:',f{i}]);
axis square;
end

function [pos, int] = shiftPositions(positions, lenCueRegion)
%Circularly shift positions and update intervals (to match ATT)
% lastTowerPosition = max(positions);
positions = positions + rand*(lenCueRegion); %Shift by random length
positions(positions>lenCueRegion) = positions(positions>lenCueRegion)-lenCueRegion; %To preserve interval distribution, remove distance between last tower and end of cue region
pos = sort(positions);
int = diff(pos);
end