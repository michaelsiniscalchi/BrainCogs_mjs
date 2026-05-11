function bootParams = specBootAvgParams_plt( generalParams )

i = 1;
% ----- Fluorescence Temporally Aligned to Maze Segments ------------------

%Start of trial
bootParams(i).trigger = "start";
bootParams(i).subtractBaseline = true;
bootParams(i).getScalarEstimates = true; %Indicator for time-averaging and peak estimation
bootParams(i).trialSpec = {... %***FUTURE: include priorReward and priorNoReward
    "forward",... 
    };
i = i+1;

%cueEntry
bootParams(i).trigger = "cueEntry";
bootParams(i).subtractBaseline = true;
bootParams(i).trialSpec = {...
    "forward",...
    };
i = i+1;

% --- Fluorescence Spatially Aligned to Cue Region ------------------------
%Aligned to y-position, no baseline subtraction
bootParams(i).trigger = "cueRegion";
bootParams(i).subtractBaseline = false; %***FUTURE: include priorReward and priorNoReward
bootParams(i).trialSpec = {...
    "forward",...
    };
i = i+1;

% --- Temporally Aligned to Trial Events ----------------------------------
%outcome
bootParams(i).trigger = "outcome";
bootParams(i).subtractBaseline = true;
bootParams(i).getScalarEstimates = true; %Indicator for time-averaging and peak estimation
bootParams(i).trialSpec = {...
    "rewarded",... %***Need trialMask for puff vs. towers trial 
    "unrewarded",... %'hiPuffs' trials are uppermost quartile of nPuffs
    };
i = i+1;

%First cue onset
bootParams(i).trigger = "firstPuff";
bootParams(i).subtractBaseline = true;
bootParams(i).getScalarEstimates = true; %Indicator for time-averaging and peak estimation
bootParams(i).trialSpec = {...
    "forward",... %Double-check that only puff trials are included here!
    "leftPuffs",...
    "rightPuffs",...
    };
i = i+1;

bootParams(i).trigger = "firstTower";
bootParams(i).subtractBaseline = true;
bootParams(i).getScalarEstimates = true; %Indicator for time-averaging and peak estimation
bootParams(i).trialSpec = {...
    "forward"...
    "leftTowers",...
    "rightTowers",...
    };
i = i+1;

bootParams(i).trigger = "firstCue";
bootParams(i).subtractBaseline = true;
bootParams(i).getScalarEstimates = true; %Indicator for time-averaging and peak estimation
bootParams(i).trialSpec = {...
    "forward",... %Double-check that only puff trials are included here!
    "leftTowers",...
    "rightTowers",...
    "leftPuffs",...
    "rightPuffs",...
    "puffs",...
    "towers",...
    };
i = i+1;

%Append general params
fields = string(fieldnames(generalParams)); %Some params specified in params_...m may overwrite bootParams(i)
for j = 1:numel(fields)
    if fields(j)=='subtractBaseline' && ~generalParams.subtractBaseline
        continue
    end
    [bootParams(1:numel(bootParams)).(fields{j})] = deal(generalParams.(fields{j}));
end

