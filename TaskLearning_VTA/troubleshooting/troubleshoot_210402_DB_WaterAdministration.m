
t=fetch(action.WaterAdministration & struct('subject_fullname', 'mjs20_439'),'*');
subject_fullname = {t.subject_fullname}';
administration_date = {t.administration_date}';
earned = [t.earned]';
table(subject_fullname,administration_date,earned)