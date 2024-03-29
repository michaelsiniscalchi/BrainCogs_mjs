function decode = calc_selectivity( trial_dFF, trials, params )

% NOTE: Temporal correlation in dF/F means traces must be shuffled whole rather than as individual 
%           time points, in order to determine H0: number of cells significant by chance, etc. 

%% ESTIMATE ROC-RELATED PARAMETERS FROM CELLULAR FLUORESCENCE AND BEHAVIORAL DATA 

% Initialize parallel pool
disp(gcp); %Query/initialize

% Loop Through Each Decode Type
for i = 1:numel(params.decodeType) %Decode type, eg 'choice' or 'outcome'
    
    % Unpack some variables for readability
    trial_dff  = trial_dFF.cueTimes; %***FUTURE, could include arg 'trigger'
    trialSpec  = params.trialSpec(i,:);
    
    % Initialize output variables
    fields = {'selectivity','AUC','TPR','FPR','AUC_boot',...
        'AUC_shuffle','TPR_shuffle','FPR_shuffle'};
    for j = 1:numel(fields)
        decode.(params.decodeType{i}).(fields{j}) = cell([numel(trial_dff), 1]);
    end
    decode.(params.decodeType{i}).trialSpec = trialSpec;
    decode.t = trial_dFF.t;
    
    % Generate grouping vector
    for j = 1:numel(trialSpec)
        trialMasks(:,j) = getMask(trials,trialSpec{j}); %#ok<AGROW> %Logical mask for specified combination of trials   
    end
    subset = any(trialMasks,2); %Include only trials for comparison
    types = trialMasks(subset,:); %Logical of dim nTrials x nTrialSpecs
    types = uint8(sum((1:size(types,2)).*types,2)); %Convert to uint8 grouping var: trial type coded as column index
       
    % Downsample aligned dF/F if specified
    if ~isempty(params.dsFactor)
        [trial_dff, decode.t] = downsampleTS(trial_dff,decode.t,params.dsFactor);
    end
    
    % Estimate receiver operating characteristic for aligned dF/F at each timepoint
    for j = 1:numel(trial_dff)
        disp(['Calculating ROC for ' params.decodeType{i} ' from cell ' num2str(j) '/' num2str(numel(trial_dff)) '...']);
        
        %Get only trials specified in trialMasks
        dff = trial_dff{j}(subset,:);
        
        % Initialize variables for parallelization
        nTrials = size(dff,1); %Set of criteria for ROC is dF/F(t) from each trial in subset (max number of criteria) 
        nTimepoints = size(dff,2);
        AUC = NaN(1,nTimepoints);           %Area under the ROC curve
        TPR = NaN(nTrials,nTimepoints); %True positive rate (nTP/nP) at each criterion; size = [nCriteria, nTimepoints]
        FPR = NaN(nTrials,nTimepoints); %False positive rate (nFP/nN)
        AUC_BOOT = NaN(3,nTimepoints);      %Mean area under the ROC curve, with bootstrapped CI
        
        % AUROC with bootstrapped confidence intervals
        parfor t = 1:size(dff,2)
            [TPR(:,t),FPR(:,t),AUC(t),AUC_BOOT(:,t)] = calc_ROC(dff(:,t),types,params); %[...] = calc_ROC(signal,class,positive_class,params)
        end
        
        % AUROC for Shuffled Traces *PARALLEL*
        [TPR_SHUFFLE,FPR_SHUFFLE,AUC_SHUFFLE] = shuffle_ROC(dff,types,params.nShuffle); %TPR and FPR are mean over all shuffles.
        
        % Store results in structure
        decode.(params.decodeType{i}).selectivity{j} = 2*([AUC; AUC_BOOT(2:3,:)]-0.5); %Selectivity = 2*(AUC-0.5)
        decode.(params.decodeType{i}).AUC{j} = AUC;
        decode.(params.decodeType{i}).TPR{j} = TPR;
        decode.(params.decodeType{i}).FPR{j} = FPR;
        decode.(params.decodeType{i}).AUC_shuffle{j} = AUC_SHUFFLE; %AUC for each shuffled class label replicate
        decode.(params.decodeType{i}).TPR_shuffle{j} = TPR_SHUFFLE; %Mean TPR(nCriteria,nTime) for shuffled class labels
        decode.(params.decodeType{i}).FPR_shuffle{j} = FPR_SHUFFLE; %Mean FPR for shuffled class labels
        decode.(params.decodeType{i}).nTrials = sum(trialMasks);
    end
    
end