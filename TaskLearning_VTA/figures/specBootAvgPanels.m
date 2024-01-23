function ax = specBootAvgPanels( params )

% switch figID
%     case 'bootAvg_choice'
%     case 'bootAvg_cue'
%     case 'bootAvg_outcome'
% end

colors = params.all.colors;

%Specify struct 'ax' containing variables and plotting params for each figure panel:

i=1;

%Summary Figure for Cue Region of Maze
ax(i).title         = "Choice";
ax(i).comparison    = "cue-region";
ax(i).trigger       = "cueRegion";
ax(i).trialType     = ["left", "right"];
ax(i).window        = [-50, 300];
ax(i).color         = {colors.left,colors.right}; %Choice: left/hit/sound vs right/hit/sound
ax(i).lineStyle     = {'-','-'};
ax(i).xLabel        = 'Distance (cm)';  % XLabel
i=i+1;
ax(i).title         = "Prior Choice";
ax(i).comparison    = "cue-region";
ax(i).trigger       = "cueRegion";
ax(i).trialType     = ["priorLeft", "priorRight"];
ax(i).window        = [-50, 300];
ax(i).color         = {colors.left,colors.right}; %Choice: left/hit/sound vs right/hit/sound
ax(i).lineStyle     = {'-','-'};
ax(i).xLabel        = 'Distance (cm)';  % XLabel
i=i+1;
ax(i).title         = "Cue Side";
ax(i).comparison    = "cue-region";
ax(i).trigger       = "cueRegion";
ax(i).trialType     = ["leftTowers", "rightTowers"];
ax(i).window        = [-50, 300];
ax(i).color         = {colors.left,colors.right}; %Choice: left/hit/sound vs right/hit/sound
ax(i).lineStyle     = {'-','-'};
ax(i).xLabel        = 'Distance (cm)';  % XLabel
i=i+1;
ax(i).title         = "Cue Side";
ax(i).comparison    = "cue-region";
ax(i).trigger       = "cueRegion";
ax(i).trialType     = ["leftPuffs", "rightPuffs"];
ax(i).window        = [-50, 300];
ax(i).color         = {colors.left,colors.right}; %Choice: left/hit/sound vs right/hit/sound
ax(i).lineStyle     = {'-','-'};
ax(i).xLabel        = 'Distance (cm)';  % XLabel
i=i+1;
ax(i).title         = 'Accuracy';
ax(i).comparison    = "cue-region";
ax(i).trigger       = "cueRegion";
ax(i).trialType     = ["correct", "error"];
ax(i).window        = [-50, 300];
ax(i).color         = {colors.correct, colors.err}; %Outcome: hit/priorHit vs err/priorHit
ax(i).lineStyle     = {'-','-'};
ax(i).xLabel        = 'Distance (cm)';  % XLabel
i=i+1;
ax(i).title         = 'Prior Outcome';
ax(i).comparison    = "cue-region";
ax(i).trigger       = "cueRegion";
ax(i).trialType     = ["priorCorrect", "priorError"];
ax(i).window        = [-50, 300];
ax(i).color         = {colors.correct, colors.err}; %Outcome: hit/priorHit vs err/priorHit
ax(i).lineStyle     = {'-','-'};
ax(i).xLabel        = 'Distance (cm)';  % XLabel
i=i+1;

ax(i).title         = "Rule Conflict";
ax(i).comparison    = "conflict-cue-region";
ax(i).trigger       = "cueRegion";
ax(i).trialType     = ["congruent", "conflict"];
ax(i).window        = [-50, 300];
ax(i).color         = {colors.congruent, colors.conflict}; %Choice: left/hit/sound vs right/hit/sound
ax(i).lineStyle     = {'-','-'};
ax(i).xLabel        = 'Distance (cm)';  % XLabel
i=i+1;

ax(i).title         = "Position";
ax(i).comparison    = "Position";
ax(i).trigger       = "cueRegion";
ax(i).trialType     = ["forward"];
ax(i).window        = [-50, 300];
ax(i).color         = {colors.data}; %Choice: left/hit/sound vs right/hit/sound
ax(i).lineStyle     = {'-'};
ax(i).xLabel        = 'Distance (cm)';  % XLabel
i=i+1;

ax(i).title         = "Time";
ax(i).comparison    = "time";
ax(i).trigger       = "cueEntry";
ax(i).trialType     = ["forward"];
ax(i).window        = [-1, 5];
ax(i).color         = {colors.data}; %Choice: left/hit/sound vs right/hit/sound
ax(i).lineStyle     = {'-'};
ax(i).xLabel        = 'Time from cue entry (s)';  % XLabel
i=i+1;

ax(i).title         = 'Rewarded';
ax(i).comparison    = "prior-outcome";
ax(i).trigger       = "outcome";
ax(i).trialType     = ["correct_priorCorrect", "correct_priorError"];
ax(i).window        = [-1, 5];
ax(i).color         = {colors.correct,colors.correct2}; %Outcome: hit/priorHit vs err/priorHit
ax(i).lineStyle     = {'-',':'};
ax(i).xLabel        = 'Time from outcome (s)';  % XLabel
i=i+1;
ax(i).title         = 'Unrewarded';
ax(i).comparison    = "prior-outcome";
ax(i).trigger       = "outcome";
ax(i).trialType     = ["error_priorCorrect", "error_priorError"];
ax(i).window        = [-1, 3];
ax(i).color         = {colors.err,colors.err2}; %Outcome: hit/priorHit vs err/priorHit
ax(i).lineStyle     = {'-',':'};
ax(i).xLabel        = 'Time from outcome (s)';  % XLabel
i=i+1;

ax(i).title         = 'Rewarded';
ax(i).comparison    = "choice-outcome";
ax(i).trigger       = "outcome";
ax(i).trialType     = ["left_correct", "right_correct"];
ax(i).window        = [-1, 3];
ax(i).color         = {colors.left,colors.right}; %Outcome: hit/priorHit vs err/priorHit
ax(i).lineStyle     = {'-','-'};
ax(i).xLabel        = 'Time from outcome (s)';  % XLabel
i=i+1;
ax(i).title         = 'Unrewarded';
ax(i).comparison    = "choice-outcome";
ax(i).trigger       = "outcome";
ax(i).trialType     = ["left_error", "right_error"];
ax(i).window        = [-1, 3];
ax(i).color         = {colors.left,colors.right}; %Outcome: hit/priorHit vs err/priorHit
ax(i).lineStyle     = {':',':'};
ax(i).xLabel        = 'Time from outcome (s)';  % XLabel
i=i+1;

ax(i).title         = 'Congruent';
ax(i).comparison    = "conflict-outcome";
ax(i).trigger       = "outcome";
ax(i).trialType     = ["correct_congruent", "correct_conflict"];
ax(i).window        = [-1, 5];
ax(i).color         = {colors.correct,colors.correct2}; %Outcome: hit/priorHit vs err/priorHit
ax(i).lineStyle     = {'-',':'};
ax(i).xLabel        = 'Time from outcome (s)';  % XLabel
i=i+1;
ax(i).title         = 'Conflict';
ax(i).comparison    = "conflict-outcome";
ax(i).trigger       = "outcome";
ax(i).trialType     = ["error_congruent", "error_conflict"];
ax(i).window        = [-1, 5];
ax(i).color         = {colors.err, colors.err2}; %Outcome: hit/priorHit vs err/priorHit
ax(i).lineStyle     = {'-',':'};
ax(i).xLabel        = 'Time from outcome (s)';  % XLabel
i=i+1;

ax(i).title      = 'First Puff';
ax(i).comparison   = 'first-puff';
ax(i).trigger   = "firstPuff";
ax(i).trialType = ["leftPuffs", "rightPuffs"];
ax(i).window    = [-1, 1];
ax(i).color      = {colors.left,colors.right}; 
ax(i).lineStyle  = {'-','-'};
ax(i).xLabel = 'Time from first cue (s)';  % XLabel
i=i+1;

ax(i).title      = 'First Tower';
ax(i).comparison   = 'first-tower';
ax(i).trigger   = "firstTower";
ax(i).trialType = ["leftTowers", "rightTowers"];
ax(i).window    = [-1, 1];
ax(i).color      = {colors.left,colors.right}; 
ax(i).lineStyle  = {'-','-'};
ax(i).xLabel = 'Time from first cue (s)';  % XLabel
i=i+1;

ax(i).title      = 'Last Puff';
ax(i).comparison   = 'last-puff';
ax(i).trigger   = "lastPuff";
ax(i).trialType = ["leftPuffs", "rightPuffs"];
ax(i).window    = [-1, 1];
ax(i).color      = {colors.left,colors.right}; 
ax(i).lineStyle  = {'-','-'};
ax(i).xLabel = 'Time from first cue (s)';  % XLabel
i=i+1;

ax(i).title      = 'Last Tower';
ax(i).comparison   = 'last-tower';
ax(i).trigger   = "lastTower";
ax(i).trialType = ["leftTowers", "rightTowers"];
ax(i).window    = [-1, 1];
ax(i).color      = {colors.left,colors.right}; 
ax(i).lineStyle  = {'-','-'};
ax(i).xLabel = 'Time from first cue (s)';  % XLabel
i=i+1;

ax(i).title         = "Tower Responses";
ax(i).comparison    = "tower-onset";
ax(i).trigger       = "towers";
ax(i).trialType     = ["leftTowers", "rightTowers"];
ax(i).window        = [-1, 1];
ax(i).color         = {colors.left, colors.right}; %Choice: left/hit/sound vs right/hit/sound
ax(i).lineStyle     = {'-','-'};
ax(i).xLabel        = 'Time from cue onset (s)';  % XLabel
i=i+1;

ax(i).title         = "Puff Responses";
ax(i).comparison    = "puff-onset";
ax(i).trigger       = "puffs";
ax(i).trialType     = ["leftPuffs", "rightPuffs"];
ax(i).window        = [-1, 1];
ax(i).color         = {colors.left, colors.right}; %Choice: left/hit/sound vs right/hit/sound
ax(i).lineStyle     = {'-','-'};
ax(i).xLabel        = 'Time from cue onset (s)';  % XLabel
i=i+1;


[ax(:).yLabel]          = deal('Cellular Fluorescence (dF/F)');
[ax(:).verboseLegend]   = deal(false);