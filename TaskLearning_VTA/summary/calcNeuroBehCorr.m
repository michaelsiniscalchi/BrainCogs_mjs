%First up, correlate psytrack weights with corresponding kernels (L2 norm)
%Also with peak and AUC of trialAvg signals
%Next, correlate accuracy & session_date with L2 of cue- and reward-related kernels
%Then with the rest of the coefficients
function out = calcNeuroBehCorr(encoding, psytrack, params)

%Correlations Psytrack weights vs. encoding response kernels
cells = encoding.cells;
fields = ["leftTowers","rightTowers","leftPuffs","rightPuffs"];
for i = 1:numel(cells)
    for f = fields
        Corr(i).encodingVar = fields(i);
        Corr(i).psytrackVar = fields(i); %Possibly add bootAvg for further correlations
        Corr(i).paramName = ["L2", "meanCoef"];
        sessionIdx = ismember(psytrack.session_date, cells(i).sessionID
        data1 = [cells(i).kernel.(f).(Corr(i).paramName(1))],...
            [psytrack.(Corr(i).paramName(2)).(f)]...
            };
dat
    end
end
out = [];

