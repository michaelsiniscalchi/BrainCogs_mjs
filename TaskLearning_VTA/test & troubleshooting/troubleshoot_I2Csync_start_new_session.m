%Check if block/trial idxs are consistent with behavioral data
nBlocks = max(behavior.trials.blockIdx);
if numel(unique(stackInfo.I2C.blockIdx))~=nBlocks
    disp('Warning: number of block indices from ViRMEn inconsistent with I2C data.');
    disp('Attempting to reconcile...');
    if strcmp(behavior.logs.animal.restart_session_paradigm, 'START NEW SESSION')
        try
            for i = 1:nBlocks
                stackInfo.I2C.blockIdx(stackInfo.I2C.trialIdx)
            end
        catch err
            disp('Failed.');
            error(err);
        end
    else
        error('Blocks reported in I2C data inconsistent with ViRMEn logs. Could not sync imaging with behavioral data.');
    end
end