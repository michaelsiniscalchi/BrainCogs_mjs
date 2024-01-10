clearvars;
subjects = [...
    "17","018","023",...
    "173","175",...
    "177","178","179",...
    "192","194"]';
prefix = "mjs20";
subject_fullname = join([repmat(prefix,numel(subjects),1),subjects],'_');

for i=1:numel(subject_fullname)
key.subject_fullname = char(subject_fullname(i));
data = fetchIntakeData(key);
datetime({data.administration_date});
dates = datetime({data.administration_date});

idx = dates>='11-Dec-2023'; %Day-1 of Citric acid
s(i).ID = subject_fullname(i);
s(i).date = dates(idx)'; 
weight = [data.weight];
s(i).weight = weight(idx)';
end

%Not all data in DB...so, plot in Google Sheets...