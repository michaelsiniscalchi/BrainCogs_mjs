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
% expData(i).sub_dir = '230922-m105-maze7-test'; 
% expData(i).subjectID = "mjs20_105";
% expData(i).mainMaze = 7;
% expData(i).npCorrFactor = 0.3;
% i = i+1;

expData(i).sub_dir = '230922-m105-maze7'; 
expData(i).subjectID = "mjs20_105";
expData(i).mainMaze = 7;
expData(i).npCorrFactor = 0.3;
i = i+1;

expData(i).sub_dir = '230922-m105-simulation'; 
expData(i).subjectID = "mjs20_105";
expData(i).mainMaze = 7;
expData(i).npCorrFactor = 0.3;
i = i+1;

expData(i).sub_dir = '231004-m105-maze7'; 
expData(i).subjectID = "mjs20_105";
expData(i).mainMaze = 7;
expData(i).npCorrFactor = 0.3;
i = i+1;

expData(i).sub_dir = '230929-m103-maze7'; % 93% Accuracy; '231003-m103-maze7', 85%; '231005-m103-maze7', 67%
expData(i).subjectID = "mjs20_103";
expData(i).mainMaze = 7;
expData(i).npCorrFactor = 0.3;
i = i+1;

expData(i).sub_dir = '231003-m103-maze7'; % 93% Accuracy; '231003-m103-maze7', 85%; '231005-m103-maze7', 67%
expData(i).subjectID = "mjs20_103";
expData(i).session_number = 1; 
expData(i).mainMaze = 7;
expData(i).npCorrFactor = 0.3;
i = i+1;

expData(i).sub_dir = '231006-m105-maze7'; 
expData(i).subjectID = "mjs20_105";
expData(i).mainMaze = 7;
expData(i).npCorrFactor = 0.3;
i = i+1;
expData(i).sub_dir = '231009-m105-maze8'; 
expData(i).subjectID = "mjs20_105";
expData(i).mainMaze = 8;
expData(i).npCorrFactor = 0.3;
i = i+1;
expData(i).sub_dir = '231017-m105-maze8'; 
expData(i).subjectID = "mjs20_105";
expData(i).session_number = 1;
expData(i).mainMaze = 8;
expData(i).npCorrFactor = 0.3;
i = i+1;
expData(i).sub_dir = '231101-m105-maze8'; 
expData(i).subjectID = "mjs20_105";
expData(i).mainMaze = 8;
expData(i).npCorrFactor = 0.3;
i = i+1;

%% VTA Cohort #2 (N=4)
%M18
expData(i).sub_dir = '240126-m18-maze7'; 
expData(i).subjectID = "mjs20_018";
expData(i).mainMaze = 7;
expData(i).npCorrFactor = 0.3;
i = i+1;
expData(i).sub_dir = '240130-m18-maze7'; 
expData(i).subjectID = "mjs20_018";
expData(i).mainMaze = 7;
expData(i).npCorrFactor = 0.3;
i = i+1;
expData(i).sub_dir = '240201-m18-maze7-session2'; 
expData(i).subjectID = "mjs20_018";
expData(i).session_number = 2;
expData(i).mainMaze = 7;
expData(i).npCorrFactor = 0.3;
i = i+1;
expData(i).sub_dir = '240207-m18-maze7'; 
expData(i).subjectID = "mjs20_018";
expData(i).mainMaze = 7;
expData(i).npCorrFactor = 0.3;
i = i+1;
expData(i).sub_dir = '240220-m18-maze7'; 
expData(i).subjectID = "mjs20_018";
expData(i).mainMaze = 7;
expData(i).npCorrFactor = 0.3;
i = i+1;
expData(i).sub_dir = '240222-m18-maze7'; 
expData(i).subjectID = "mjs20_018";
expData(i).mainMaze = 7;
expData(i).npCorrFactor = 0.3;
i = i+1;
expData(i).sub_dir = '240229-m18-maze7'; 
expData(i).subjectID = "mjs20_018";
expData(i).mainMaze = 7;
expData(i).npCorrFactor = 0.3;
i = i+1;
expData(i).sub_dir = '240306-m18-maze7'; 
expData(i).subjectID = "mjs20_018";
expData(i).mainMaze = 7;
expData(i).npCorrFactor = 0.3;
i = i+1;
expData(i).sub_dir = '240312-m18-maze7'; 
expData(i).subjectID = "mjs20_018";
expData(i).mainMaze = 7;
expData(i).npCorrFactor = 0.3;
i = i+1;

%M173
expData(i).sub_dir = '240119-m173-maze7'; 
expData(i).subjectID = "mjs20_173";
expData(i).mainMaze = 7;
expData(i).npCorrFactor = 0.3;
i = i+1;
expData(i).sub_dir = '240125-m173-maze7'; 
expData(i).subjectID = "mjs20_173";
expData(i).mainMaze = 7;
expData(i).npCorrFactor = 0.3;
i = i+1;
expData(i).sub_dir = '240131-m173-maze7'; 
expData(i).subjectID = "mjs20_173";
expData(i).mainMaze = 7;
expData(i).npCorrFactor = 0.3;
i = i+1;
expData(i).sub_dir = '240202-m173-maze7'; 
expData(i).subjectID = "mjs20_173";
expData(i).mainMaze = 7;
expData(i).npCorrFactor = 0.3;
i = i+1;
expData(i).sub_dir = '240206-m173-maze7'; 
expData(i).subjectID = "mjs20_173";
expData(i).mainMaze = 7;
expData(i).npCorrFactor = 0.3;
i = i+1;
expData(i).sub_dir = '240213-m173-maze7'; 
expData(i).subjectID = "mjs20_173";
expData(i).mainMaze = 7;
expData(i).npCorrFactor = 0.3;
i = i+1;
expData(i).sub_dir = '240220-m173-maze7'; 
expData(i).subjectID = "mjs20_173";
expData(i).mainMaze = 7;
expData(i).npCorrFactor = 0.3;
i = i+1;
expData(i).sub_dir = '240222-m173-maze7'; 
expData(i).subjectID = "mjs20_173";
expData(i).mainMaze = 7;
expData(i).npCorrFactor = 0.3;
i = i+1;
expData(i).sub_dir = '240229-m173-maze7'; 
expData(i).subjectID = "mjs20_173";
expData(i).mainMaze = 7;
expData(i).npCorrFactor = 0.3;
i = i+1;
expData(i).sub_dir = '240306-m173-maze7'; 
expData(i).subjectID = "mjs20_173";
expData(i).mainMaze = 7;
expData(i).npCorrFactor = 0.3;
i = i+1;
expData(i).sub_dir = '240312-m173-maze7'; 
expData(i).subjectID = "mjs20_173";
expData(i).mainMaze = 7;
expData(i).npCorrFactor = 0.3;
i = i+1;
expData(i).sub_dir = '240412-m173-maze7'; 
expData(i).subjectID = "mjs20_173";
expData(i).mainMaze = 7;
expData(i).npCorrFactor = 0.3;
i = i+1;

%M175
expData(i).sub_dir = '240216-m175-maze7'; 
expData(i).subjectID = "mjs20_175";
expData(i).mainMaze = 7;
expData(i).session_number = 1; 
expData(i).npCorrFactor = 0.3;
i = i+1;
expData(i).sub_dir = '240223-m175-maze7'; 
expData(i).subjectID = "mjs20_175";
expData(i).mainMaze = 7;
expData(i).npCorrFactor = 0.3;
i = i+1;
expData(i).sub_dir = '240305-m175-maze7'; 
expData(i).subjectID = "mjs20_175";
expData(i).mainMaze = 7;
expData(i).npCorrFactor = 0.3;
i = i+1;
expData(i).sub_dir = '240307-m175-maze7'; 
expData(i).subjectID = "mjs20_175";
expData(i).mainMaze = 7;
expData(i).npCorrFactor = 0.3;
i = i+1;
expData(i).sub_dir = '240412-m175-maze7'; 
expData(i).subjectID = "mjs20_175";
expData(i).mainMaze = 7;
expData(i).npCorrFactor = 0.3;
i = i+1;

%M177
expData(i).sub_dir = '240118-m177-maze7'; 
expData(i).subjectID = "mjs20_177";
expData(i).mainMaze = 7;
expData(i).npCorrFactor = 0.3;
i = i+1;
expData(i).sub_dir = '240124-m177-maze7'; 
expData(i).subjectID = "mjs20_177";
expData(i).mainMaze = 7;
expData(i).session_number = 1; %Idx starts with 0
expData(i).npCorrFactor = 0.3;
i = i+1;

%M179
expData(i).sub_dir = '240104-m179-maze7'; 
expData(i).subjectID = "mjs20_179";
expData(i).mainMaze = 7;
expData(i).npCorrFactor = 0.3;
i = i+1;

% %M570


%M571
expData(i).sub_dir = '240528-m571-maze7'; 
expData(i).subjectID = "mjs20_571";
expData(i).mainMaze = 7;
expData(i).npCorrFactor = 0.3;
i = i+1;
expData(i).sub_dir = '240701-m571-maze7'; 
expData(i).subjectID = "mjs20_571";
expData(i).mainMaze = 7;
expData(i).npCorrFactor = 0.3;
i = i+1;
expData(i).sub_dir = '240807-m571-maze8'; 
expData(i).subjectID = "mjs20_571";
expData(i).mainMaze = 8;
expData(i).npCorrFactor = 0.3;
i = i+1;
expData(i).sub_dir = '240814-m571-maze8'; 
expData(i).subjectID = "mjs20_571";
expData(i).mainMaze = 8;
expData(i).npCorrFactor = 0.3;
i = i+1;
expData(i).sub_dir = '240816-m571-maze9'; 
expData(i).subjectID = "mjs20_571";
expData(i).mainMaze = 9;
expData(i).npCorrFactor = 0.3;
i = i+1;

%M32
expData(i).sub_dir = '240821-m32-maze7'; 
expData(i).subjectID = "mjs20_32";
expData(i).mainMaze = 7;
expData(i).npCorrFactor = 0.3;
i = i+1;
expData(i).sub_dir = '240827-m32-maze7'; 
expData(i).subjectID = "mjs20_32";
expData(i).mainMaze = 7;
expData(i).npCorrFactor = 0.3;
i = i+1;
expData(i).sub_dir = '240904-m32-maze7'; 
expData(i).subjectID = "mjs20_32";
expData(i).mainMaze = 7;
expData(i).npCorrFactor = 0.3;
i = i+1;
expData(i).sub_dir = '240906-m32-maze7'; 
expData(i).subjectID = "mjs20_32";
expData(i).mainMaze = 7;
expData(i).npCorrFactor = 0.3;
i = i+1;
expData(i).sub_dir = '240913-m32-maze7'; 
expData(i).subjectID = "mjs20_32";
expData(i).mainMaze = 7;
expData(i).npCorrFactor = 0.3;
i = i+1;
expData(i).sub_dir = '240917-m32-maze7'; 
expData(i).subjectID = "mjs20_32";
expData(i).mainMaze = 7;
expData(i).npCorrFactor = 0.3;
i = i+1;



% 230929-m103-maze7

% 230922-m105-maze7
% 231004-m105-maze7
% 231006-m105-maze7
% 231009-m105-maze8
% 231017-m105-maze8
% 231101-m105-maze8
