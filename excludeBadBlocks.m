%For manual exclusion of sessions in which data were compromised by rig problems, etc.

function [ logs, excludeBlocks ] = excludeBadBlocks( logs, experiment )

switch experiment
    case 'mjs_memoryMaze_NAc_DREADD_performance'

        exclude = {...
            "mjs20_439",datetime('2021-04-23');...
            "mjs20_439",datetime('2021-05-04');
            "mjs20_665",datetime('2021-03-11')};

    case 'mjs_taskLearning_NAc_DREADD2'
        %**M11 & M12 were switched on 210702...
        exclude = {...
            "mjs20_11",datetime('2021-07-02'),'all';...
            "mjs20_12",datetime('2021-07-02'),'all';...
            "mjs20_13",datetime('2021-08-06'),'all';... %Milk spout leaking...
            "mjs20_15",datetime('2021-08-11'),'all';... %Milk spout leaking
            "mjs20_11",datetime('2021-08-18'),'all';...
            "mjs20_12",datetime('2021-08-18'),'all';...
            "mjs20_13",datetime('2021-08-18'),'all';...
            "mjs20_14",datetime('2021-08-18'),'all';...
            "mjs20_15",datetime('2021-08-18'),'all';...
            "mjs20_16",datetime('2021-08-18'),'all';...
            "mjs20_17",datetime('2021-08-18'),'all';... %Bug with reward delivery (omitted after error)
            "mjs20_17",datetime('2021-08-26'),'all'};   %Mounting apparatus failed (head plate rotated)
    case 'mjs_taskLearningWalls'
        exclude = {...
            "mjs20_09",datetime('13-Aug-2021'),[1,2];... %Manual tests
            "mjs20_09",datetime('17-Sep-2021'),2;... %Accidentally auto-advanced after the first (short) block
            "mjs20_09",datetime('28-Sep-2021'),'all';... %Reward spout moved out-of-reach
            "mjs20_10",datetime('01-Oct-2021'),[1,2];... %Projector accidentally blocked
            "mjs20_10",datetime('28-Oct-2021'),2;... %Actually M09 in second block
            "mjs20_09",datetime('12-Nov-2021'),'all';... %Mice ran out of food overnight; gave diet gel prior to training; poor task performance.
            "mjs20_10",datetime('12-Nov-2021'),'all';...
            "mjs20_18",datetime('12-Nov-2021'),'all';...
            "mjs20_19",datetime('12-Nov-2021'),'all';...
            "mjs20_20",datetime('12-Nov-2021'),'all';...
            "mjs20_09",datetime('20-Dec-2021'), 2;... %Actually M18
            "mjs20_18",datetime('20-Dec-2021'),'all';... %Actually M20
            "mjs20_20",datetime('24-Dec-2021'),'all';... %Tried to transition M20 to Bezos2
            };
        %Double-check "mjs20_18",datetime('23-Nov-2021'),[1];... %M09 was
        %accidentally trained under M18...file moved, so probably okay. M18
        %started around 11:30am

    case 'mjs_taskLearning_VTA_1'

        exclude = {...
            "mjs20_413",datetime('16-Mar-2022'),[1,2];... %Accidental session start with T6
            "mjs20_413",datetime('17-Mar-2022'),[2,3];... %Accidental T6 (26 trials), then aborted T7
            "mjs20_411",datetime('23-Mar-2022'),[1:4];... %Multiple restarts '220323 M411 T6 pseudorandom'
            "mjs20_411",datetime('13-Jun-2022'),[1];...   %Unsure why there are 2 blocks...
            };
end

%Remove specified blocks prior to session data extraction
excludeBlocks = [];
for i = 1:size(exclude,1)
    if ismember(logs.animal.name,exclude{i,1}) &&...
            string(datetime(logs.session.start,'Format','dd-MMM-yyyy'))==exclude{i,2} &&...
            strcmp(exclude{i,3},'all')
        logs = [];  %Exclude whole session
        return
    elseif ismember(logs.animal.name,exclude{i,1}) &&...
            string(datetime(logs.session.start,'Format','dd-MMM-yyyy'))==exclude{i,2}
        excludeBlocks = exclude{i,3};
%         Method 2 (obsolete)
%                 ***This method may be incompatible with I2C data contained in
%                 imaging frames... instead, use output variable 'exclude' to
%                 exclude all trials in block***
%         logs.block = logs.block(~ismember(1:numel(logs.block), exclude{i,3}));

        return
    end
end