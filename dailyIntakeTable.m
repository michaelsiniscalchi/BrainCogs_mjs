% Generate Tables to Record Daily Intake and Weight

function intake = dailyIntakeTable(subjects, dirs, dataSource)

%Default data source
if nargin<3
    if isfield(subjects,'logs') 
        dataSource = 'matfiles';
    else
        dataSource = 'DJ';
    end
end

%Calculate daily reward volume
for i = 1:numel(subjects)

    %Unpack
    subjID = subjects(i).ID;
    startDate = subjects(i).startDate;
    
    %Initialize session variables
    if strcmp(dataSource,'matfiles')  %If data extracted from files rather than from database
        logData = subjects(i).logs;
        rewEarned = NaN(numel(logData),1);
        
        %Get total reward volume for each day by summing blocks
        for j = 1:numel(logData)
            Date(j,1:3) = logData(j).session.start(1:3); %Remove time
            rewEarned(j,:) = sum([logData(j).block(:).rewardMiL]);
        end
        sessionDate = datetime(Date,'format','yyyy-MM-dd');
    elseif strcmp(dataSource,'DJ')
        sessionIdx = ~isnan([subjects(i).intake.earned]);
        rewEarned = [subjects(i).intake(sessionIdx).earned];
        sessionDate = [subjects(i).intake(sessionIdx).session_date];
%         subjects(i).weighData(sessionIdx)
    end

    %Initialize table variables
    administration_date = (startDate : sessionDate(end))'; %All set to 00:00:00 for indexing by date
    [earned, supplement, received, weight] = deal(NaN(numel(administration_date),1));
    weighing_time = administration_date; %Not currently used... use after linking with DB
    %weighing_time = NaT(numel(administration_date),1);
    
    fillStr = @(str) string(repmat(str,numel(administration_date),1));
    subject_fullname    = fillStr(subjects(i).ID);
    weigh_person        = fillStr(subjects(i).experimenter);
    location            = fillStr(getRigID(subjects(i).rigNum));
    watertype_name      = fillStr(subjects(i).waterType);
       
    %Load existing workbook and append new data
    excelPath = fullfile(dirs.intake,'Daily_Intake.xls');
    if exist(excelPath,'file') && ismember(subjID,sheetnames(excelPath))
        %Update table
        T = readtable(excelPath,'Sheet',subjID,'TextType','string');
        newRows = abs(size(T,1)-size(administration_date,1));
        if size(administration_date,1)>size(T,1)
            %Add rows to existing sheet
            T2 = table(subject_fullname, administration_date, weighing_time, weigh_person,...
                earned, supplement, weight, received, location, watertype_name);
            idx = [false(size(administration_date,1)-newRows,1); true(newRows,1)];
            T = [T; T2(idx,:)];
        end
    else %Generate new table
        T = table(subject_fullname, administration_date, weighing_time, weigh_person,...
            earned, supplement, weight, received, location, watertype_name); %supplement & weight adjacent for easy copy-paste from weigh sheet
    end
    
    %Fill in subject IDs, dates and earned reward amounts
    T.subject_fullname(1:end) = subjects(i).ID;
    T.administration_date(1:end) = (startDate : startDate+size(T,1)-1)';
    T.earned(ismember(T.administration_date,sessionDate)) = rewEarned;
    % received = earned + supplement
    %   For missing supplement, received = NaN; 
    %   For non-session dates set = supplement.
    T.received = max(sum([T.earned,T.supplement],2), T.supplement); 
    
    %Write table for current subject as XLS sheet
    intake.(subjID) = T;
    writetable(T,excelPath,'Sheet',subjID);
end

%Concatenate tables for use in DB
T = table;
subjID = fieldnames(intake);
for i = 1:numel(subjID)
    T = [T; intake.(subjID{i})];
end
writetable(T,fullfile(dirs.intake,'Daily_Intake_All_Subjects.xls'));

%Save as MAT
save(fullfile(dirs.intake,['Daily_Intake_' dataSource]),'-struct','intake');