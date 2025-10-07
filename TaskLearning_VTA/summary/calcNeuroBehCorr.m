%First up, correlate psytrack weights with corresponding kernels (L2 norm)
%Also with peak and AUC of trialAvg signals
%Next, correlate accuracy & session_date with L2 of cue- and reward-related kernels
%Then with the rest of the coefficients
function [nbCorr, cells] = calcNeuroBehCorr(encoding, psytrack, params)

%Correlate psytrack weights vs. encoding response kernels
C = encoding.cells;
initNum = NaN(numel(C),1); %Initialize numeric fields
initCell = {cell(numel(C),1)}; %Init cell fields (to store vector data)
corrName = strjoin(params.paramNames,'_'); %Name of saved MATLAB variable: 'param1_param2'

%Get session dates
for i = 1:numel(C)
    sessionDates{i} = intersect(psytrack.session_date, C(i).session_date); %TEMP: should be ismember(psy,cells)...but some psytrack is missing
    psyIdx{i} = ismember(psytrack.session_date, sessionDates{i});
    imgIdx{i} = ismember(C(i).session_date, sessionDates{i});
end

%First struct (nbCorr) by variables, cell data in terminal fields
for f = params.psyField
    for ff = params.imgField
        S = struct(...
            'cellID', repmat("",numel(C),1),...
            'data', initCell,'ranks', initCell,...
            'R', initNum, 'p_R', initNum, 'rho', initNum, 'p_rho', initNum,...
            'N', initNum, 'session_dates', initCell);

        for i = 1:numel(C)

            %Extract scalar estimates for psytrack and encoding model
            data = [...
                psytrack.(params.paramNames(1)).(f)(psyIdx{i}),...
                C(i).kernel.(ff).(params.paramNames(2))(imgIdx{i})...
                ];

            %Calculate Pearson and Spearman correlation
            [~,ranks] = sort(data,1);
            [R, p_R] = corrcoef(data); %Pearson
            [rho, p_rho] = corrcoef(ranks); %Spearman

            %Assign results to structs
            S.cellID(i) = string(C(i).cellID);
            S.session_dates{i} = sessionDates{i};
            S.N(i) = numel(sessionDates{i});
            S.data{i} = data;
            if S.N(i)>2
                S.ranks{i} = ranks;
                S.R(i,:) = R(2,1);
                S.p_R(i,:) = p_R(2,1);
                S.rho(i,:) = rho(2,1);
                S.p_rho(i,:) = p_rho(2,1);
            end
        end
        nbCorr.(corrName).(f).(ff) = S;
    end
end

%Format as struct array by cell
cells = struct('cellID',{C.cellID},'session_dates', NaT, 'N', NaN);
dataFields = ["data","ranks","R","p_R","rho","p_rho"];
for i = 1:numel(cells)
    cells(i).session_dates = sessionDates{i};
    cells(i).N = numel(sessionDates{i});
    for f = params.psyField
        for ff = params.imgField
            S = nbCorr.(corrName).(f).(ff);
            for fff = dataFields
                cells(i).(f).(ff).(fff) = S.(fff)(i);
            end
        end
    end
end
