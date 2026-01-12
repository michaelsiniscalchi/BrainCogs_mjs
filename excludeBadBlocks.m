%For manual exclusion of sessions in which data were compromised by rig problems, etc.

function [ logs, excludeBlocks ] = excludeBadBlocks( logs )

% switch experiment
%     case 'mjs_memoryMaze_NAc_DREADD_performance'
% 
%         exclude = {...
%             "mjs20_439",datetime('2021-04-23');...
%             "mjs20_439",datetime('2021-05-04');
%             "mjs20_665",datetime('2021-03-11')};
% 
%     case 'mjs_taskLearning_NAc_DREADD2'
%         %**M11 & M12 were switched on 210702...
%         exclude = {...
%             "mjs20_11",datetime('2021-07-02'),'all';...
%             "mjs20_12",datetime('2021-07-02'),'all';...
%             "mjs20_13",datetime('2021-08-06'),'all';... %Milk spout leaking...
%             "mjs20_15",datetime('2021-08-11'),'all';... %Milk spout leaking
%             "mjs20_11",datetime('2021-08-18'),'all';...
%             "mjs20_12",datetime('2021-08-18'),'all';...
%             "mjs20_13",datetime('2021-08-18'),'all';...
%             "mjs20_14",datetime('2021-08-18'),'all';...
%             "mjs20_15",datetime('2021-08-18'),'all';...
%             "mjs20_16",datetime('2021-08-18'),'all';...
%             "mjs20_17",datetime('2021-08-18'),'all';... %Bug with reward delivery (omitted after error)
%             "mjs20_17",datetime('2021-08-26'),'all'};   %Mounting apparatus failed (head plate rotated)
%     case 'mjs_taskLearningWalls'
%         exclude = {...
%             "mjs20_09",datetime('13-Aug-2021'),[1,2];... %Manual tests
%             "mjs20_09",datetime('17-Sep-2021'),2;... %Accidentally auto-advanced after the first (short) block
%             "mjs20_09",datetime('28-Sep-2021'),'all';... %Reward spout moved out-of-reach
%             "mjs20_10",datetime('01-Oct-2021'),[1,2];... %Projector accidentally blocked
%             "mjs20_10",datetime('28-Oct-2021'),2;... %Actually M09 in second block
%             "mjs20_09",datetime('12-Nov-2021'),'all';... %Mice ran out of food overnight; gave diet gel prior to training; poor task performance.
%             "mjs20_10",datetime('12-Nov-2021'),'all';...
%             "mjs20_18",datetime('12-Nov-2021'),'all';...
%             "mjs20_19",datetime('12-Nov-2021'),'all';...
%             "mjs20_20",datetime('12-Nov-2021'),'all';...
%             "mjs20_09",datetime('20-Dec-2021'), 2;... %Actually M18
%             "mjs20_18",datetime('20-Dec-2021'),'all';... %Actually M20
%             "mjs20_20",datetime('24-Dec-2021'),'all';... %Tried to transition M20 to Bezos2
%             };
%         %Double-check "mjs20_18",datetime('23-Nov-2021'),[1];... %M09 was
%         %accidentally trained under M18...file moved, so probably okay. M18
%         %started around 11:30am
% 
%     case 'mjs_taskLearning_VTA_1'
% 
%         exclude = {...
%             "mjs20_413",datetime('16-Mar-2022'),[1,2];... %Accidental session start with T6
%             "mjs20_413",datetime('17-Mar-2022'),[2,3];... %Accidental T6 (26 trials), then aborted T7
%             "mjs20_411",datetime('23-Mar-2022'),[1:4];... %Multiple restarts '220323 M411 T6 pseudorandom'
%             "mjs20_411",datetime('13-Jun-2022'),[1];...   %Unsure why there are 2 blocks...
%             };
%     case 'mjs_taskLearning_VTA_1'
% 
%         exclude = {...
%             "mjs20_413",datetime('16-Mar-2022'),[1,2];... %Accidental session start with T6
%             "mjs20_413",datetime('17-Mar-2022'),[2,3];... %Accidental T6 (26 trials), then aborted T7
%             "mjs20_411",datetime('23-Mar-2022'),[1:4];... %Multiple restarts '220323 M411 T6 pseudorandom'
%             "mjs20_411",datetime('13-Jun-2022'),[1];...   %Unsure why there are 2 blocks...
%             };
% end


%     'mjs_memoryMaze_NAc_DREADD_performance'

        exclude = {...
            "mjs20_439",datetime('2021-04-23'),'all';...
            "mjs20_439",datetime('2021-05-04'),'all';...
            "mjs20_665",datetime('2021-03-11'),'all';...

%     case 'mjs_taskLearning_NAc_DREADD2'
        %**M11 & M12 were switched on 210702...
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
            "mjs20_17",datetime('2021-08-26'),'all';...   %Mounting apparatus failed (head plate rotated)
%     case 'mjs_taskLearningWalls'

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

        %Double-check "mjs20_18",datetime('23-Nov-2021'),[1];... %M09 was
        %accidentally trained under M18...file moved, so probably okay. M18
        %started around 11:30am

%     case 'mjs_taskLearning_VTA_1'

            "mjs20_413",datetime('16-Mar-2022'),[1,2];... %Accidental session start with T6
            "mjs20_413",datetime('17-Mar-2022'),[2,3];... %Accidental T6 (26 trials), then aborted T7
            "mjs20_411",datetime('23-Mar-2022'),[1:4];... %Multiple restarts '220323 M411 T6 pseudorandom'
            "mjs20_411",datetime('13-Jun-2022'),[1];...   %Unsure why there are 2 blocks...
           
%     case 'mjs_tactile2visual'
            "mjs20_24",datetime('10-Jun-2023'), 'all';...   %Accidentally started on maze level 8
            "mjs20_24",datetime('11-Jun-2023'), 'all';...   %Accidentally started on maze level 8
            "mjs20_24",datetime('12-Jun-2023'), 'all';...   %Accidentally started on maze level 8
            "mjs20_24",datetime('30-Jul-2023'), 'all';...   %Accidentally started on maze level 8
            "mjs20_24",datetime('31-Jul-2023'), [1,2];...   %Accidentally started on maze level 8
            "mjs20_23",datetime('04-Aug-2023'), 'all';...   %Headplate holder arm twisted forward
            "mjs20_23",datetime('09-Aug-2023'), 1;...   %Headplate holder arm twisted forward (again!)  
            "mjs20_26",datetime('09-Aug-2023'), 'all';...   %Had already exceeded accuracy threshold of 80%
            "mjs20_23",datetime('01-Sep-2023'), 'all';... %Extra training and reworked code to include iOutcome in log.block (and removed iBlank) 
            "mjs20_103",datetime('18-Sep-2023'), 'all';...   %Accidentally started on maze level 8


            "mjs20_018",datetime('29-Nov-2024'), 'all';...   %M18 started on linear track
            "mjs20_018",datetime('30-Nov-2024'), 'all';...   %linear track
            "mjs20_018",datetime('28-Feb-2024'),     2;...   %M173 accidentally run as M18
            "mjs20_018",datetime('07-Mar-2024'),     2;...   %M173 accidentally run as M18
            "mjs20_177",datetime('14-Mar-2024'),    'all';...    %missing log field 'pDistractorTrials'
            "mjs20_179",datetime('07-Dec-2024'), 'all';...   %premature tactile rule--should have been lvl 6 L-maze

            "mjs20_569",datetime('06-May-2024'),'all';...   %changed fields in logs.block for second block (could amend code to accommodate)

            "mjs20_40",datetime('10-Apr-2025'),'all';...   %Different task: variable reward
            }; 

% "mjs20_103",datetime('03-Oct-2023'), 1;... %Restarted
% "mjs20_105",datetime('17-Oct-2023'), 1;...   %First img session failed.
% EXCLUDE BLOCKS IN IMG SESSIONS USING expData.session_number

%Remove specified blocks prior to session data extraction
excludeBlocks = [];
for i = 1:size(exclude,1)
    if ismember(logs.animal.name, exclude{i,1}) &&...
            string(datetime(logs.session(1).start,'Format','dd-MMM-yyyy'))==exclude{i,2} &&... %Session idx=1 for multiple sessions with same date
            strcmp(exclude{i,3},'all')
        logs = [];  %Exclude whole session
        return
    elseif ismember(logs.animal.name,exclude{i,1}) &&...
            string(datetime(logs.session(1).start,'Format','dd-MMM-yyyy'))==exclude{i,2}
        excludeBlocks = exclude{i,3};
%         %Truncate logs.block to match
%         exclIdx = false(numel(logs.block),1);
%         exclIdx(excludeBlocks) = true;
%         logs.block = logs.block(~exclIdx);
%         logs.version = logs.version(~exclIdx);
%         logs.session = logs.session(~exclIdx);
        return
    end
end