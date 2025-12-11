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

% expData(i).sub_dir = '230922-m105-simulation'; 
% expData(i).subjectID = "mjs20_105";
% expData(i).mainMaze = 7;
% expData(i).npCorrFactor = 0.3;
% i = i+1;

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

%% VTA Cohort #2 (N=4; DAT-cre;AAV-GCaMP or DAT-cre;Ai148;AAV-mCherry)
%M18 (AAV9-syn-flex-GCaMP8f)
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
expData(i).session_number = 0; %named ..._0, _1, _2, etc.
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

%M173 (DAT-cre;Ai148;AAVdj-mCherry)
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

%M175 (DAT-cre;Ai148;AAVdj-mCherry)
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

%M177 (DAT-cre;Ai148 ask Addie re: AAV?)
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

%% VTA Cohort #3 (N=5 DAT-cre::Ai148)

%M570 (3 blocks)


%M571 (3 blocks)
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

%M32 (1 block completed) 
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

%M33 (2 blocks)
expData(i).sub_dir = '241031-m33-maze7'; 
expData(i).subjectID = "mjs20_33";
expData(i).mainMaze = 7;
expData(i).npCorrFactor = 0.3;
i = i+1;
expData(i).sub_dir = '241105-m33-maze7'; 
expData(i).subjectID = "mjs20_33";
expData(i).mainMaze = 7;
expData(i).npCorrFactor = 0.3;
i = i+1;
expData(i).sub_dir = '241206-m33-maze7'; 
expData(i).subjectID = "mjs20_33";
expData(i).mainMaze = 7;
expData(i).npCorrFactor = 0.3;
i = i+1;


%m199 (1 block completed)
expData(i).sub_dir = '241206-m199-maze7'; 
expData(i).subjectID = "mjs20_199";
expData(i).mainMaze = 7;
expData(i).npCorrFactor = 0.3;
i = i+1;

%M834 (1 block completed)
expData(i).sub_dir = '240920-m834-maze7'; 
expData(i).subjectID = "mjs20_834";
expData(i).mainMaze = 7;
expData(i).npCorrFactor = 0.3;
i = i+1;
expData(i).sub_dir = '241001-m834-maze7'; 
expData(i).subjectID = "mjs20_834";
expData(i).mainMaze = 7;
expData(i).npCorrFactor = 0.3;
i = i+1;
expData(i).sub_dir = '241011-m834-maze7'; 
expData(i).subjectID = "mjs20_834";
expData(i).mainMaze = 7;
expData(i).npCorrFactor = 0.3;
i = i+1;
expData(i).sub_dir = '241016-m834-maze7'; 
expData(i).subjectID = "mjs20_834";
expData(i).mainMaze = 7;
expData(i).npCorrFactor = 0.3;
i = i+1;
expData(i).sub_dir = '241028-m834-maze8'; 
expData(i).subjectID = "mjs20_834";
expData(i).mainMaze = 8;
expData(i).npCorrFactor = 0.3;
i = i+1;
expData(i).sub_dir = '241104-m834-maze8'; 
expData(i).subjectID = "mjs20_834";
expData(i).mainMaze = 8;
expData(i).npCorrFactor = 0.3;
i = i+1;

%% VTA Cohort #4 (N=3)

%M40 DAT-cre::jGCaMP8s (4 blocks)
expData(i).sub_dir = '250203-m40-maze7'; 
expData(i).subjectID = "mjs20_40";
expData(i).mainMaze = 7;
expData(i).npCorrFactor = 0.3;
i = i+1;

%M42 DAT-cre::jGCaMP8s + Fellin Lens (4 blocks)
expData(i).sub_dir = '250117-m42-maze7'; 
expData(i).subjectID = "mjs20_42";
expData(i).mainMaze = 7;
expData(i).npCorrFactor = 0.3;
i = i+1;
expData(i).sub_dir = '250127-m42-maze7'; 
expData(i).subjectID = "mjs20_42";
expData(i).mainMaze = 7;
expData(i).npCorrFactor = 0.3;
i = i+1;
expData(i).sub_dir = '250130-m42-maze8'; 
expData(i).subjectID = "mjs20_42";
expData(i).mainMaze = 8;
expData(i).npCorrFactor = 0.3;
i = i+1;
expData(i).sub_dir = '250207-m42-maze8'; 
expData(i).subjectID = "mjs20_42";
expData(i).mainMaze = 8;
expData(i).npCorrFactor = 0.3;
i = i+1;
expData(i).sub_dir = '250211-m42-maze8'; 
expData(i).subjectID = "mjs20_42";
expData(i).mainMaze = 8;
expData(i).npCorrFactor = 0.3;
i = i+1;
expData(i).sub_dir = '250213-m42-maze8'; 
expData(i).subjectID = "mjs20_42";
expData(i).mainMaze = 8;
expData(i).npCorrFactor = 0.3;
i = i+1;
expData(i).sub_dir = '250218-m42-maze9'; %Session mislabeled as maze8
expData(i).subjectID = "mjs20_42";
expData(i).mainMaze = 9;
expData(i).npCorrFactor = 0.3;
i = i+1;
expData(i).sub_dir = '250220-m42-maze9'; 
expData(i).subjectID = "mjs20_42";
expData(i).mainMaze = 9;
expData(i).npCorrFactor = 0.3;
i = i+1;
expData(i).sub_dir = '250228-m42-maze9'; 
expData(i).subjectID = "mjs20_42";
expData(i).mainMaze = 9;
expData(i).npCorrFactor = 0.3;
i = i+1;
expData(i).sub_dir = '250305-m42-maze9'; 
expData(i).subjectID = "mjs20_42";
expData(i).mainMaze = 9;
expData(i).npCorrFactor = 0.3;
i = i+1;
expData(i).sub_dir = '250307-m42-maze10'; 
expData(i).subjectID = "mjs20_42";
expData(i).mainMaze = 10;
expData(i).npCorrFactor = 0.3;
i = i+1;
expData(i).sub_dir = '250311-m42-maze10'; 
expData(i).subjectID = "mjs20_42";
expData(i).mainMaze = 10;
expData(i).npCorrFactor = 0.3;
i = i+1;
expData(i).sub_dir = '250313-m42-maze10'; 
expData(i).subjectID = "mjs20_42";
expData(i).mainMaze = 10;
expData(i).npCorrFactor = 0.3;
i = i+1;
expData(i).sub_dir = '250318-m42-maze10'; 
expData(i).subjectID = "mjs20_42";
expData(i).mainMaze = 10;
expData(i).npCorrFactor = 0.3;
i = i+1;
expData(i).sub_dir = '250320-m42-maze10'; 
expData(i).subjectID = "mjs20_42";
expData(i).mainMaze = 10;
expData(i).npCorrFactor = 0.3;
i = i+1;
expData(i).sub_dir = '250404-m42-maze10'; 
expData(i).subjectID = "mjs20_42";
expData(i).mainMaze = 10;
expData(i).npCorrFactor = 0.3;
i = i+1;

%M477 DAT-cre::jGCaMP8s (2 blocks but probably few neurons)
expData(i).sub_dir = '250603-m477-maze7'; 
expData(i).subjectID = "mjs20_477";
expData(i).session_number = 1; 
expData(i).mainMaze = 7;
expData(i).npCorrFactor = 0.3;
i = i+1;
expData(i).sub_dir = '250619-m477-maze7'; 
expData(i).subjectID = "mjs20_477";
expData(i).mainMaze = 7;
expData(i).npCorrFactor = 0.3;
i = i+1;
expData(i).sub_dir = '250624-m477-maze7'; 
expData(i).subjectID = "mjs20_477";
expData(i).mainMaze = 7;
expData(i).npCorrFactor = 0.3;
i = i+1;
expData(i).sub_dir = '250630-m477-maze8'; 
expData(i).subjectID = "mjs20_477";
expData(i).mainMaze = 8;
expData(i).npCorrFactor = 0.3;
i = i+1;

%Sync test
expData(i).sub_dir = '250905-m477-maze8'; 
expData(i).subjectID = "mjs20_477";
expData(i).mainMaze = 8;
expData(i).npCorrFactor = NaN;
i = i+1;

%M478 DAT-cre::jGCaMP8s (2 blocks but probably only one neuron)
expData(i).sub_dir = '250603-m478-maze7'; 
expData(i).subjectID = "mjs20_478";
expData(i).mainMaze = 7;
expData(i).npCorrFactor = 0.3;
i = i+1;
expData(i).sub_dir = '250605-m478-maze8'; 
expData(i).subjectID = "mjs20_478";
expData(i).mainMaze = 8;
expData(i).npCorrFactor = 0.3;
i = i+1;
expData(i).sub_dir = '250619-m478-maze8'; 
expData(i).subjectID = "mjs20_478";
expData(i).mainMaze = 8;
expData(i).npCorrFactor = 0.3;
i = i+1;
expData(i).sub_dir = '250707-m478-maze8'; 
expData(i).subjectID = "mjs20_478";
expData(i).mainMaze = 8;
expData(i).npCorrFactor = 0.3;
i = i+1;
expData(i).sub_dir = '250710-m478-maze8'; 
expData(i).subjectID = "mjs20_478";
expData(i).mainMaze = 8;
expData(i).npCorrFactor = 0.3;
i = i+1;

%M480 DAT-cre::jGCaMP8s (1 rule block-->68%)
expData(i).sub_dir = '250623-m480-maze7'; 
expData(i).subjectID = "mjs20_480";
expData(i).mainMaze = 7;
expData(i).npCorrFactor = 0.3;
i = i+1;
expData(i).sub_dir = '250630-m480-maze7'; 
expData(i).subjectID = "mjs20_480";
expData(i).mainMaze = 7;
expData(i).npCorrFactor = 0.3;
i = i+1;

%M650 DAT-cre::RiboL1-jGCaMP8s (1 rule block-->~60%)
expData(i).sub_dir = '250618-m650-maze7'; 
expData(i).subjectID = "mjs20_m650";
expData(i).mainMaze = 7;
expData(i).npCorrFactor = 0.3;
i = i+1;
expData(i).sub_dir = '250624-m650-maze7'; 
expData(i).subjectID = "mjs20_m650";
expData(i).mainMaze = 7;
expData(i).npCorrFactor = 0.3;
i = i+1;
expData(i).sub_dir = '250701-m650-maze7'; 
expData(i).subjectID = "mjs20_m650";
expData(i).mainMaze = 7;
expData(i).npCorrFactor = 0.3;
i = i+1;
expData(i).sub_dir = '250708-m650-maze7'; 
expData(i).subjectID = "mjs20_m650";
expData(i).mainMaze = 7;
expData(i).npCorrFactor = 0.3;
i = i+1;


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


