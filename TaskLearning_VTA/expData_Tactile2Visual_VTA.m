function [ dirs, expData ] = expData_Tactile2Visual_VTA(dirs)

%PURPOSE: Create data structure for imaging tiff files and behavioral log files
%AUTHOR: MJ Siniscalchi 230918
%
%INPUT ARGUMENTS
%   data_dir:    The base directory to which the raw data are stored.  
%
%OUTPUT VARIABLES
%   dirs:        The subfolder structure within data_dir to work with
%   expData:     Info regarding each experiment

dirs.data = fullfile(dirs.root,'tactile2visual-vta','data'); 
dirs.notebook = fullfile(dirs.root,'tactile2visual-vta','notebook'); 
dirs.results = fullfile(dirs.root,'tactile2visual-vta','results');
dirs.summary = fullfile(dirs.root,'tactile2visual-vta','summary');
dirs.figures = fullfile(dirs.root,'tactile2visual-vta','figures');

%% First VTA Cohort (N=2)

% Initialize structure
expData = struct('sub_dir',[],'subjectID',[],'mainMaze',[],...
    'excludeBlock',[],'npCorrFactor',[]);

% Session metadata
i=1;

%M713 DAT-cre::RiboL1-jGCaMP8s
expData(i).sub_dir = '250702-m713-maze7'; 
expData(i).subjectID = "mjs20_713";
expData(i).mainMaze = 7;
expData(i).npCorrFactor = 0.3;
i = i+1;
expData(i).sub_dir = '250709-m713-maze7'; 
expData(i).subjectID = "mjs20_713";
expData(i).mainMaze = 7;
expData(i).npCorrFactor = 0.3;
i = i+1;
expData(i).sub_dir = '250715-m713-maze7'; 
expData(i).subjectID = "mjs20_713";
expData(i).mainMaze = 7;
expData(i).npCorrFactor = 0.3;
i = i+1;
expData(i).sub_dir = '250801-m713-maze7'; 
expData(i).subjectID = "mjs20_713";
expData(i).mainMaze = 7;
expData(i).npCorrFactor = 0.3;
i = i+1;
expData(i).sub_dir = '250808-m713-maze7'; 
expData(i).subjectID = "mjs20_713";
expData(i).mainMaze = 7;
expData(i).npCorrFactor = 0.3;
i = i+1;
expData(i).sub_dir = '250812-m713-maze7'; 
expData(i).subjectID = "mjs20_713";
expData(i).mainMaze = 7;
expData(i).npCorrFactor = 0.3;
i = i+1;
expData(i).sub_dir = '250814-m713-maze8'; 
expData(i).subjectID = "mjs20_713";
expData(i).mainMaze = 8;
expData(i).npCorrFactor = 0.3;
i = i+1;
expData(i).sub_dir = '250821-m713-maze8'; 
expData(i).subjectID = "mjs20_713";
expData(i).mainMaze = 8;
expData(i).npCorrFactor = 0.3;
i = i+1;
expData(i).sub_dir = '250826-m713-maze8'; 
expData(i).subjectID = "mjs20_713";
expData(i).mainMaze = 8;
expData(i).npCorrFactor = 0.3;
i = i+1;

%M714 DAT-cre::RiboL1-jGCaMP8s
expData(i).sub_dir = '250703-m714-maze7'; 
expData(i).subjectID = "mjs20_714";
expData(i).mainMaze = 7;
expData(i).npCorrFactor = 0.3;
i = i+1;
expData(i).sub_dir = '250710-m714-maze7'; 
expData(i).subjectID = "mjs20_714";
expData(i).mainMaze = 7;
expData(i).npCorrFactor = 0.3;
i = i+1;

%M913 DAT-cre::jGCaMP8s (2 blocks)
expData(i).sub_dir = '250116-m913-maze7'; 
expData(i).subjectID = "mjs20_913";
expData(i).mainMaze = 7;
expData(i).npCorrFactor = 0.3;
i = i+1;
expData(i).sub_dir = '250123-m913-maze7'; 
expData(i).subjectID = "mjs20_913";
expData(i).mainMaze = 7;
expData(i).npCorrFactor = 0.3;
i = i+1;
expData(i).sub_dir = '250206-m913-maze7'; 
expData(i).subjectID = "mjs20_913";
expData(i).mainMaze = 7;
expData(i).npCorrFactor = 0.3;
i = i+1;
expData(i).sub_dir = '250212-m913-maze7'; 
expData(i).subjectID = "mjs20_913";
expData(i).mainMaze = 7;
expData(i).npCorrFactor = 0.3;
i = i+1;
expData(i).sub_dir = '250214-m913-maze8'; 
expData(i).subjectID = "mjs20_913";
expData(i).mainMaze = 8;
expData(i).npCorrFactor = 0.3;
i = i+1;
expData(i).sub_dir = '250221-m913-maze8'; 
expData(i).subjectID = "mjs20_913";
expData(i).mainMaze = 8;
expData(i).npCorrFactor = 0.3;
i = i+1;
expData(i).sub_dir = '250228-m913-maze8'; 
expData(i).subjectID = "mjs20_913";
expData(i).mainMaze = 8;
expData(i).npCorrFactor = 0.3;
i = i+1;
expData(i).sub_dir = '250305-m913-maze8'; 
expData(i).subjectID = "mjs20_913";
expData(i).mainMaze = 8;
expData(i).npCorrFactor = 0.3;
i = i+1;
expData(i).sub_dir = '250307-m913-maze8'; 
expData(i).subjectID = "mjs20_913";
expData(i).mainMaze = 8;
expData(i).npCorrFactor = 0.3;
i = i+1;
expData(i).sub_dir = '250312-m913-maze8'; 
expData(i).subjectID = "mjs20_913";
expData(i).mainMaze = 8;
expData(i).npCorrFactor = 0.3;
i = i+1;

%M37 DAT-cre::RiboL1-jGCaMP8s
expData(i).sub_dir = '260108-m37-maze7'; %Last session on Rule-1 (tactile)
expData(i).subjectID = "mjs20_37";
expData(i).mainMaze = 7;
expData(i).npCorrFactor = 0.3;
i = i+1;
expData(i).sub_dir = '260311-m37-maze8'; %Example %5 zero-cues session for Ilana
expData(i).subjectID = "mjs20_37";
expData(i).mainMaze = 8;
expData(i).npCorrFactor = 0.3;
i = i+1;
expData(i).sub_dir = '260312-m37-maze10'; %Maze 10 is the unimodal variant 
expData(i).subjectID = "mjs20_37";
expData(i).session_number = 1; %Idx from BrainCogs Database/braininit cup
expData(i).mainMaze = 10;
expData(i).npCorrFactor = 0.3;
i = i+1;
expData(i).sub_dir = '260313-m37-maze10';
expData(i).subjectID = "mjs20_37";
expData(i).mainMaze = 10;
expData(i).npCorrFactor = 0.3;
i = i+1;
expData(i).sub_dir = '260316-m37-maze10';
expData(i).subjectID = "mjs20_37";
expData(i).mainMaze = 10;
expData(i).npCorrFactor = 0.3;
i = i+1;
expData(i).sub_dir = '260317-m37-maze10'; 
expData(i).subjectID = "mjs20_37";
expData(i).mainMaze = 10;
expData(i).npCorrFactor = 0.3;
i = i+1;
expData(i).sub_dir = '260320-m37-maze8'; 
expData(i).subjectID = "mjs20_37";
expData(i).mainMaze = 8;
expData(i).npCorrFactor = 0.3;
i = i+1;
expData(i).sub_dir = '260402-m37-maze7'; 
expData(i).subjectID = "mjs20_37";
expData(i).mainMaze = 7;
expData(i).npCorrFactor = 0.3;
i = i+1;

%M39 DAT-cre::RiboL1-jGCaMP8s
expData(i).sub_dir = '260108-m39-maze7'; %Maze 10 is the unimodal variant 
expData(i).subjectID = "mjs20_39";
expData(i).mainMaze = 7;
expData(i).npCorrFactor = 0.3;
i = i+1;
expData(i).sub_dir = '260312-m39-maze10'; %Maze 10 is the unimodal variant 
expData(i).subjectID = "mjs20_39";
expData(i).mainMaze = 10;
expData(i).session_number = 1; %Idx from BrainCogs Database/braininit cup
expData(i).npCorrFactor = 0.3;
i = i+1;
expData(i).sub_dir = '260313-m39-maze10'; %NEED to run FIGURES!
expData(i).subjectID = "mjs20_39";
expData(i).mainMaze = 10;
expData(i).npCorrFactor = 0.3;
i = i+1;
expData(i).sub_dir = '260316-m39-maze10'; 
expData(i).subjectID = "mjs20_39";
expData(i).mainMaze = 10;
expData(i).npCorrFactor = 0.3;
i = i+1;
expData(i).sub_dir = '260317-m39-maze10';
expData(i).subjectID = "mjs20_39";
expData(i).mainMaze = 10;
expData(i).npCorrFactor = 0.3;
i = i+1;

%% ------- Pavlovian Linear Track -----------------------------------------
%m37
expData(i).sub_dir = '260406-m37-plt7'; 
expData(i).subjectID = "mjs20_37";
expData(i).mainMaze = 7;
expData(i).session_number = 1; %Idx from BrainCogs Database/braininit cup
expData(i).npCorrFactor = 0.3;
i = i+1;
% expData(i).sub_dir = '260406-m37-plt7-test'; 
% expData(i).subjectID = "mjs20_37";
% expData(i).mainMaze = 7;
% expData(i).session_number = 1; %Idx from BrainCogs Database/braininit cup
% expData(i).npCorrFactor = 0.3;
% i = i+1;
expData(i).sub_dir = '260409-m37-plt7'; %Penultimate session on initial learning
expData(i).subjectID = "mjs20_37";
expData(i).mainMaze = 7;
expData(i).npCorrFactor = 0.3;
i = i+1;
expData(i).sub_dir = '260410-m37-plt7'; %Last session on initial learning, but TIMING PROBS??
expData(i).subjectID = "mjs20_37";
expData(i).mainMaze = 7;
expData(i).npCorrFactor = 0.3;
i = i+1;
expData(i).sub_dir = '260413-m37-plt7'; %ACTUALLY, main maze 8...leave dir name for now, fix later! 
expData(i).subjectID = "mjs20_37";
expData(i).mainMaze = 8;
expData(i).session_number = 1; %Idx from BrainCogs Database/braininit cup
expData(i).npCorrFactor = 0.3;
i = i+1;
expData(i).sub_dir = '260415-m37-plt8'; 
expData(i).subjectID = "mjs20_37";
expData(i).mainMaze = 8;
expData(i).npCorrFactor = 0.3;
i = i+1;
expData(i).sub_dir = '260420-m37-plt8'; 
expData(i).subjectID = "mjs20_37";
expData(i).mainMaze = 8;
expData(i).npCorrFactor = 0.3;
i = i+1;
expData(i).sub_dir = '260423-m37-plt8'; 
expData(i).subjectID = "mjs20_37";
expData(i).mainMaze = 8;
expData(i).npCorrFactor = 0.3;
i = i+1;
expData(i).sub_dir = '260428-m37-plt9'; 
expData(i).subjectID = "mjs20_37";
expData(i).mainMaze = 9;
expData(i).npCorrFactor = 0.3;
i = i+1;
expData(i).sub_dir = '260505-m37-plt9'; 
expData(i).subjectID = "mjs20_37";
expData(i).mainMaze = 9;
expData(i).npCorrFactor = 0.3;
i = i+1;
expData(i).sub_dir = '260506-m37-plt9'; 
expData(i).subjectID = "mjs20_37";
expData(i).mainMaze = 9;
expData(i).npCorrFactor = 0.3;
i = i+1;
expData(i).sub_dir = '260507-m37-plt7'; 
expData(i).subjectID = "mjs20_37";
expData(i).mainMaze = 7;
expData(i).npCorrFactor = 0.3;
i = i+1;
expData(i).sub_dir = '260511-m37-plt7'; 
expData(i).subjectID = "mjs20_37";
expData(i).mainMaze = 7;
expData(i).npCorrFactor = 0.3;
i = i+1;
expData(i).sub_dir = '260515-m37-plt7'; 
expData(i).subjectID = "mjs20_37";
expData(i).mainMaze = 7;
expData(i).npCorrFactor = 0.3;
i = i+1;
expData(i).sub_dir = '260528-m37-plt10'; 
expData(i).subjectID = "mjs20_37";
expData(i).mainMaze = 10;
expData(i).npCorrFactor = 0.3;
i = i+1;
%m39
expData(i).sub_dir = '260406-m39-plt8'; %Major timing issue--~3.5 delay on dF/F signal wrt. cue/outcome times...
expData(i).subjectID = "mjs20_39";
expData(i).mainMaze = 8;
expData(i).session_number = 1; %Idx from BrainCogs Database/braininit cup
expData(i).npCorrFactor = 0.3;
i = i+1;
%m00
expData(i).sub_dir = '260508-m00-plt7'; 
expData(i).subjectID = "mjs20_00";
expData(i).mainMaze = 7;
expData(i).npCorrFactor = 0.3;
i = i+1;
expData(i).sub_dir = '260519-m00-plt7'; 
expData(i).subjectID = "mjs20_00";
expData(i).mainMaze = 7;
expData(i).npCorrFactor = 0.3;
i = i+1;
%m01 (Cracked lens after 4 sessions)
expData(i).sub_dir = '260515-m01-plt8'; 
expData(i).subjectID = "mjs20_01";
expData(i).mainMaze = 8;
expData(i).npCorrFactor = 0.3;
i = i+1;
%m04
expData(i).sub_dir = '260513-m04-plt7'; %imaging looks pretty bad...
expData(i).subjectID = "mjs20_04";
expData(i).mainMaze = 7;
expData(i).npCorrFactor = 0.3;
i = i+1;
expData(i).sub_dir = '260515-m04-plt7'; %Truncating to 150 stack to look for improvement
expData(i).subjectID = "mjs20_04";
expData(i).mainMaze = 7;
expData(i).npCorrFactor = 0.3;
i = i+1;
%m06
%m07
expData(i).sub_dir = '260522-m07-plt8'; 
expData(i).subjectID = "mjs20_07";
expData(i).mainMaze = 8;
expData(i).npCorrFactor = 0.3;
i = i+1;
%m09
expData(i).sub_dir = '260528-m09-plt7'; 
expData(i).subjectID = "mjs20_9";
expData(i).mainMaze = 7;
expData(i).npCorrFactor = 0.3;
i = i+1;
%m50
expData(i).sub_dir = '261015-m50-plt6'; 
expData(i).subjectID = "mjs20_50";
expData(i).mainMaze = 6;
expData(i).npCorrFactor = 0.3;
i = i+1;
expData(i).sub_dir = '261019-m50-plt7'; 
expData(i).subjectID = "mjs20_50";
expData(i).mainMaze = 7;
expData(i).npCorrFactor = 0.3;
i = i+1;
expData(i).sub_dir = '261020-m50-plt7'; 
expData(i).subjectID = "mjs20_50";
expData(i).mainMaze = 7;
expData(i).npCorrFactor = 0.3;
i = i+1;
expData(i).sub_dir = '261021-m50-plt7'; 
expData(i).subjectID = "mjs20_50";
expData(i).mainMaze = 7;
expData(i).npCorrFactor = 0.3;
i = i+1;
expData(i).sub_dir = '261022-m50-plt7'; 
expData(i).subjectID = "mjs20_50";
expData(i).mainMaze = 7;
expData(i).npCorrFactor = 0.3;
i = i+1;
%m52
expData(i).sub_dir = '261015-m52-plt6'; 
expData(i).subjectID = "mjs20_52";
expData(i).mainMaze = 6;
expData(i).npCorrFactor = 0.3;
i = i+1;
expData(i).sub_dir = '261019-m52-plt7'; 
expData(i).subjectID = "mjs20_52";
expData(i).mainMaze = 7;
expData(i).npCorrFactor = 0.3;
i = i+1;

%m376
expData(i).sub_dir = '261023-m376-plt5'; 
expData(i).subjectID = "mjs20_376";
expData(i).mainMaze = 5;
expData(i).npCorrFactor = 0.3;
i = i+1;
expData(i).sub_dir = '261027-m376-plt6'; 
expData(i).subjectID = "mjs20_376";
expData(i).mainMaze = 6;
expData(i).npCorrFactor = 0.3;
i = i+1;
expData(i).sub_dir = '261028-m376-plt7';
expData(i).subjectID = "mjs20_376";
expData(i).mainMaze = 7;
expData(i).npCorrFactor = 0.3;
i = i+1;
expData(i).sub_dir = '261103-m376-plt7'; 
expData(i).subjectID = "mjs20_376";
expData(i).mainMaze = 7;
expData(i).npCorrFactor = 0.3;
i = i+1;
expData(i).sub_dir = '261106-m376-plt8'; 
expData(i).subjectID = "mjs20_376";
expData(i).mainMaze = 8;
expData(i).npCorrFactor = 0.3;
i = i+1;

%m502
expData(i).sub_dir = '261022-m502-plt5';  
expData(i).subjectID = "mjs20_502";
expData(i).mainMaze = 5;
expData(i).npCorrFactor = 0.3;
i = i+1;
expData(i).sub_dir = '261026-m502-plt6';
expData(i).subjectID = "mjs20_502";
expData(i).mainMaze = 6;
expData(i).npCorrFactor = 0.3;
i = i+1;
expData(i).sub_dir = '261028-m502-plt8'; 
expData(i).subjectID = "mjs20_502";
expData(i).mainMaze = 8;
expData(i).npCorrFactor = 0.3;
i = i+1;


