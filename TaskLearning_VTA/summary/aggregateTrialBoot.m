function bootAvg = aggregateTrialBoot( Img, Beh )

bootAvg.cellIDs = string(unique(cat(1,Img(:).cellID)));
for i = 1:numel(Img)
    trigger = string(fieldnames(Img(i).bootAvg));
    for tr = trigger'
        trial_subset = string(fieldnames(Img(i).bootAvg.(tr)));
        trial_subset = trial_subset(~ismember(trial_subset,["t","position"]));
        for ts = trial_subset'
            cells = Img(i).bootAvg.(tr).(ts).cells; %abbreviate
            bootFields = fieldnames(cells);
            bootAvg.(tr).(ts).cells(numel(bootAvg.cellIDs)).sessions(numel(Img)) =...
                cell2struct(cell(size(bootFields)), bootFields); %Initialize
            %Copy data from each cellID into struct           
            for j = 1:numel(Img(i).cellID)
                idx = bootAvg.cellIDs==string(Img(i).cellID(j));
                bootAvg.(tr).(ts).cells(idx).sessions(i) = cells(j); %Assign single-session bootAvg struct to session array
            end
            %If cellID not present in session, init each field with NaN placeholder
            for idx = find(~ismember(bootAvg.cellIDs, Img(i).cellID))'
                bootAvg.(tr).(ts).cells(idx).sessions(i) =... 
                    cell2struct(repmat({nan}, size(bootFields)), bootFields);
            end
        end
    end
end

%End up with a struct like this:
%(trigger).(trial_subset).cells(:).sessions(:).(bootFields)

%Collect behavioral data
bootAvg.sessions = Beh.sessions;