function bootStruct = calcTimeAvgFluo(bootStruct, params)

%Find peak for each trial subset
t = bootStruct.t; %Unpack

fields = string(fieldnames(bootStruct));
fields = fields(fields~="t");
for f = fields(1) %fields'
    cells = bootStruct.(f).cells;
    for i = 1:numel(cells)
                
        %Mean within window following trigger
        signal = movmean(cells(i).signal, params.smoothWin); %Smooth with simple moving mean
        idx = t>0 & t<params.avgWin; %sample idx for averaging around max
        cells(i).meanResp = mean(signal(:, idx));

        %Max value or peak 
        cells(i).peak = max(signal);
        cells(i).peak_t = t(signal==max(signal));
        %Avg surrounding max
        idx = t>cells(i).max_t-params.avgWin/2 &...
            t<cells(i).max_t+params.avgWin/2; %sample idx for averaging around max
        cells(i).peak_avg = mean(signal(:, idx));
        
        %Min value or trough
        cells(i).min = min(signal);
        cells(i).min_t = t(signal==min(signal));
        %Avg surrounding min
        idx = t>cells(i).min_t - params.avgWin/2 &...
            t<cells(i).min_t + params.avgWin/2; %sample idx for averaging around max
        cells(i).min_avg = mean(signal(:, idx));

    end
end