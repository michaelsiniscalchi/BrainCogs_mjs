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
expData(i).sub_dir = '230922-m105-maze7-test'; 
expData(i).subjectID = "mjs20_105";
expData(i).mainMaze = 7;
expData(i).npCorrFactor = 0.3;
i = i+1;

expData(i).sub_dir = '230922-m105-maze7'; 
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

%M177
expData(i).sub_dir = '240118-m177-maze7'; 
expData(i).subjectID = "mjs20_177";
expData(i).mainMaze = 7;
expData(i).npCorrFactor = 0.3;
i = i+1;

expData(i).sub_dir = '240104-m179-maze7'; 
expData(i).subjectID = "mjs20_179";
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
