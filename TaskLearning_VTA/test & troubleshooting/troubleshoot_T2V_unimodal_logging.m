vr.protocol.trialChoice(1:20)
nTrials = numel([vr.logger.block.trial.choice]);
[cellfun(@(C) numel(C{1}), {vr.logger.block.trial(1:nTrials).cueOnset});
cellfun(@(C) numel(C{2}), {vr.logger.block.trial(1:nTrials).cueOnset})]

[cellfun(@(C) numel(C{1}), {vr.logger.block.trial(1:nTrials).puffOnset});
cellfun(@(C) numel(C{2}), {vr.logger.block.trial(1:nTrials).puffOnset})]


[cellfun(@(C) numel(C{:}), {vr.logger.block.trial(1:nTrials).cuePos});
cellfun(@(C) numel(C{:}), {vr.logger.block.trial(1:nTrials).puffPos})]

%From virmen log
nTrials = numel([log.block.trial.choice]);
[log.block.trial(1:nTrials).choice]

[cellfun(@(C) numel(C{1}), {log.block.trial(1:nTrials).cuePos});
cellfun(@(C) numel(C{2}), {log.block.trial(1:nTrials).cuePos})]

[cellfun(@(C) numel(C{1}), {log.block.trial(1:nTrials).puffPos});
cellfun(@(C) numel(C{2}), {log.block.trial(1:nTrials).puffPos})]


%Correct syntax:
[cellfun(@(C) sum([numel(C{1}), numel(C{2})]), {log.block.trial(1:nTrials).cuePos});
cellfun(@(C) sum([numel(C{1}), numel(C{2})]), {log.block.trial(1:nTrials).puffPos})]
