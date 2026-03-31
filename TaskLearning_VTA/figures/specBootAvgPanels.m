function ax = specBootAvgPanels( params )

% switch figID
%     case 'bootAvg_choice'
%     case 'bootAvg_cue'
%     case 'bootAvg_outcome'
% end

colors = params.all.colors;

%Specify struct 'ax' containing variables and plotting params for each figure panel:

i=1;

%---Summary Figure for Cue Region of Maze----------------------------------
ax(i).title         = "Choice";
ax(i).comparison    = "cue-region";
ax(i).trigger       = "cueRegion";
ax(i).trialType     = ["left", "right"];
ax(i).window        = [-inf, inf];
ax(i).color         = {colors.left,colors.right}; %Choice: left/hit/sound vs right/hit/sound
ax(i).lineStyle     = {'-','-'};
ax(i).xLabel        = 'Distance (cm)';  % XLabel
i=i+1;
ax(i).title         = "Prior Choice";
ax(i).comparison    = "cue-region";
ax(i).trigger       = "cueRegion";
ax(i).trialType     = ["priorLeft", "priorRight"];
ax(i).window        = [-inf, inf];
ax(i).color         = {colors.left,colors.right}; %Choice: left/hit/sound vs right/hit/sound
ax(i).lineStyle     = {'-','-'};
ax(i).xLabel        = 'Distance (cm)';  % XLabel
i=i+1;
ax(i).title         = "Cue Type";
ax(i).comparison    = "cue-region";
ax(i).trigger       = "cueRegion";
ax(i).trialType     = ["hiTowers", "hiPuffs"];
ax(i).window        = [-inf, inf];
ax(i).color         = {colors.visual, colors.tactile}; %Choice: left/hit/sound vs right/hit/sound
ax(i).lineStyle     = {'-','-'};
ax(i).xLabel        = 'Distance (cm)';  % XLabel
i=i+1;
ax(i).title         = "Cue Side"; %Or just do relevant cueSide
ax(i).comparison    = "cue-region";
ax(i).trigger       = "cueRegion";
ax(i).trialType     = ["leftTowers", "rightTowers"];
ax(i).window        = [-inf, inf];
ax(i).color         = {colors.left,colors.right}; %Choice: left/hit/sound vs right/hit/sound
ax(i).lineStyle     = {'-','-'};
ax(i).xLabel        = 'Distance (cm)';  % XLabel
i=i+1;
ax(i).title         = "Cue Side";
ax(i).comparison    = "cue-region";
ax(i).trigger       = "cueRegion";
ax(i).trialType     = ["leftPuffs", "rightPuffs"];
ax(i).window        = [-inf, inf];
ax(i).color         = {colors.left,colors.right}; %Choice: left/hit/sound vs right/hit/sound
ax(i).lineStyle     = {'-','-'};
ax(i).xLabel        = 'Distance (cm)';  % XLabel
i=i+1;
ax(i).title         = 'Accuracy';
ax(i).comparison    = "cue-region";
ax(i).trigger       = "cueRegion";
ax(i).trialType     = ["correct", "error"];
ax(i).window        = [-inf, inf];
ax(i).color         = {colors.correct, colors.err}; %Outcome: hit/priorHit vs err/priorHit
ax(i).lineStyle     = {'-','-'};
ax(i).xLabel        = 'Distance (cm)';  % XLabel
i=i+1;
ax(i).title         = 'Prior Outcome';
ax(i).comparison    = "cue-region";
ax(i).trigger       = "cueRegion";
ax(i).trialType     = ["priorCorrect", "priorError"];
ax(i).window        = [-inf, inf];
ax(i).color         = {colors.correct, colors.err}; %Outcome: hit/priorHit vs err/priorHit
ax(i).lineStyle     = {'-','-'};
ax(i).xLabel        = 'Distance (cm)';  % XLabel
i=i+1;

%---OTHER CUE REGION COMPARISONS-------------------------------------------

ax(i).title         = "All Trials";
ax(i).comparison    = "cueRegion-conflict";
ax(i).trigger       = "cueRegion";
ax(i).trialType     = ["congruent", "conflict"];
ax(i).window        = [-inf, inf];
ax(i).color         = {colors.congruent, colors.conflict}; 
ax(i).lineStyle     = {'-','-'};
ax(i).xLabel        = 'Distance (cm)';  % XLabel
i=i+1;

ax(i).title         = "Correct Trials";
ax(i).comparison    = "cueRegion-conflict";
ax(i).trigger       = "cueRegion";
ax(i).trialType     = ["congruent_correct", "conflict_correct"];
ax(i).window        = [-inf, inf];
ax(i).color         = {colors.congruent, colors.conflict}; %Choice: left/hit/sound vs right/hit/sound
ax(i).lineStyle     = {'-','-'};
ax(i).xLabel        = 'Distance (cm)';  % XLabel
i=i+1;

ax(i).title         = "Air Puffs";
ax(i).comparison    = "cueRegion-cueCount";
ax(i).trigger       = "cueRegion";
ax(i).trialType     = ["loPuffs","hiPuffs"];
ax(i).window        = [-inf, inf];
ax(i).color         = {colors.orange2, colors.orange}; %Choice: left/hit/sound vs right/hit/sound
ax(i).lineStyle     = {'-','-'};
ax(i).xLabel        = 'Distance (cm)';  % XLabel
i=i+1;
ax(i).title         = "Towers";
ax(i).comparison    = "cueRegion-cueCount";
ax(i).trigger       = "cueRegion";
ax(i).trialType     = ["loTowers","hiTowers"];
ax(i).window        = [-inf, inf];
ax(i).color         = {colors.orange2, colors.orange}; %Choice: left/hit/sound vs right/hit/sound
ax(i).lineStyle     = {'-','-'};
ax(i).xLabel        = 'Distance (cm)';  % XLabel
i=i+1;

ax(i).title         = 'High Cue Count';
ax(i).comparison    = "cueRegion-cueCount-cueType";
ax(i).trigger       = "cueRegion";
ax(i).trialType     = ["hiTowers", "hiPuffs"];
ax(i).window        = [-inf, inf];
ax(i).color         = {colors.visual, colors.tactile}; %Outcome: hit/priorHit vs err/priorHit
ax(i).lineStyle     = {'-','-'};
ax(i).xLabel        = 'Distance (cm)';  % XLabel
i=i+1;
ax(i).title         = 'Low Cue Count';
ax(i).comparison    = "cueRegion-cueCount-cueType";
ax(i).trigger       = "cueRegion";
ax(i).trialType     = ["loTowers", "loPuffs"];
ax(i).window        = [-inf, inf];
ax(i).color         = {colors.visual, colors.tactile}; %Outcome: hit/priorHit vs err/priorHit
ax(i).lineStyle     = {'-','-'};
ax(i).xLabel        = 'Distance (cm)';  % XLabel
i=i+1;
% ax(i).title         = 'Distractors'; %FUTURE: try hiTowers & noPuffs, etc.
% ax(i).comparison    = "cueRegion-cueCount-cueType";
% ax(i).trigger       = "cueRegion";
% ax(i).trialType     = ["noTowers", "noPuffs"];
% ax(i).window        = [-inf, inf];
% ax(i).color         = {colors.visual, colors.tactile}; %Outcome: hit/priorHit vs err/priorHit
% ax(i).lineStyle     = {'-','-'};
% ax(i).xLabel        = 'Distance (cm)';  % XLabel
% i=i+1;

% ax(i).title         = "High Cue Count";
% ax(i).comparison    = "cueRegion-cueCount-conflict";
% ax(i).trigger       = "cueRegion";
% ax(i).trialType     = ["congruent_hiCues", "conflict_hiCues"];
% ax(i).window        = [-inf, inf];
% ax(i).color         = {colors.congruent, colors.conflict};
% ax(i).lineStyle     = {'-','-'};
% ax(i).xLabel        = 'Distance (cm)';  % XLabel
% i=i+1;
% ax(i).title         = "Low Cue Count";
% ax(i).comparison    = "cueRegion-cueCount-conflict";
% ax(i).trigger       = "cueRegion";
% ax(i).trialType     = ["congruent_loCues", "conflict_loCues"];
% ax(i).window        = [-inf, inf];
% ax(i).color         = {colors.congruent, colors.conflict};
% ax(i).lineStyle     = {'-','-'};
% ax(i).xLabel        = 'Distance (cm)';  % XLabel
% i=i+1;

%%---OUTCOME RESPONSES-----------------------------------------------------

ax(i).title         = 'Rewarded';
ax(i).comparison    = "prior-outcome";
ax(i).trigger       = "outcome";
ax(i).trialType     = ["priorCorrect_correct", "priorError_correct"];
ax(i).window        = [-1, 5];
ax(i).color         = {colors.correct, colors.correct2}; %Outcome: hit/priorHit vs err/priorHit
ax(i).lineStyle     = {'-',':'};
ax(i).xLabel        = 'Time from outcome (s)';  % XLabel
i=i+1;
ax(i).title         = 'Unrewarded';
ax(i).comparison    = "prior-outcome";
ax(i).trigger       = "outcome";
ax(i).trialType     = ["priorCorrect_error", "priorError_error"];
ax(i).window        = [-1, 5];
ax(i).color         = {colors.err, colors.err2}; %Outcome: hit/priorHit vs err/priorHit
ax(i).lineStyle     = {'-',':'};
ax(i).xLabel        = 'Time from outcome (s)';  % XLabel
i=i+1;

ax(i).title         = 'Rewarded';
ax(i).comparison    = "choice-outcome";
ax(i).trigger       = "outcome";
ax(i).trialType     = ["left_correct", "right_correct"];
ax(i).window        = [-1, 5];
ax(i).color         = {colors.left, colors.right}; 
ax(i).lineStyle     = {'-','-'};
ax(i).xLabel        = 'Time from outcome (s)';  % XLabel
i=i+1;
ax(i).title         = 'Unrewarded';
ax(i).comparison    = "choice-outcome";
ax(i).trigger       = "outcome";
ax(i).trialType     = ["left_error", "right_error"];
ax(i).window        = [-1, 5];
ax(i).color         = {colors.left, colors.right}; 
ax(i).lineStyle     = {':',':'};
ax(i).xLabel        = 'Time from outcome (s)';  % XLabel
i=i+1;

ax(i).title         = 'Rewarded';
ax(i).comparison    = "conflict-outcome";
ax(i).trigger       = "outcome";
ax(i).trialType     = ["congruent_correct", "conflict_correct"];
ax(i).window        = [-1, 5];
ax(i).color         = {colors.correct, colors.correct2}; %Outcome: hit/priorHit vs err/priorHit
ax(i).lineStyle     = {'-',':'};
ax(i).xLabel        = 'Time from outcome (s)';  % XLabel
i=i+1;
ax(i).title         = 'Unrewarded';
ax(i).comparison    = "conflict-outcome";
ax(i).trigger       = "outcome";
ax(i).trialType     = ["congruent_error", "conflict_error"];
ax(i).window        = [-1, 5];
ax(i).color         = {colors.err, colors.err2}; %Outcome: hit/priorHit vs err/priorHit
ax(i).lineStyle     = {'-',':'};
ax(i).xLabel        = 'Time from outcome (s)';  % XLabel
i=i+1;

ax(i).title         = 'Outcome';
ax(i).comparison    = "reward-noReward";
ax(i).trigger       = "outcome";
ax(i).trialType     = ["correct", "error"];
ax(i).window        = [-1, 5];
ax(i).color         = {colors.correct,colors.err}; %Outcome: hit/priorHit vs err/priorHit
ax(i).lineStyle     = {'-','-'};
ax(i).xLabel        = 'Time from outcome (s)';  % XLabel
i=i+1;

ax(i).title      = 'Rewarded';
ax(i).comparison   = "towerCount-outcome";
ax(i).trigger   = "outcome";
ax(i).trialType = ["hiTowers_correct", "loTowers_correct"];
ax(i).window    = [-1, 5];
ax(i).color      = {colors.correct, colors.correct2}; 
ax(i).lineStyle  = {'-',':'};
ax(i).xLabel = 'Time from outcome (s)';  % XLabel
i=i+1;
ax(i).title      = 'Unrewarded';
ax(i).comparison   = "towerCount-outcome";
ax(i).trigger   = "outcome";
ax(i).trialType = ["hiTowers_error", "loTowers_error"];
ax(i).window    = [-1, 5];
ax(i).color      = {colors.err, colors.err2};
ax(i).lineStyle  = {'-',':'};
ax(i).xLabel = 'Time from outcome (s)';  % XLabel
i=i+1;

ax(i).title      = 'Rewarded';
ax(i).comparison   = "puffCount-outcome";
ax(i).trigger   = "outcome";
ax(i).trialType = ["hiPuffs_correct", "loPuffs_correct"];
ax(i).window    = [-1, 5];
ax(i).color      = {colors.correct, colors.correct2}; 
ax(i).lineStyle  = {'-',':'};
ax(i).xLabel = 'Time from outcome (s)';  % XLabel
i=i+1;
ax(i).title      = 'Unrewarded';
ax(i).comparison   = "puffCount-outcome";
ax(i).trigger   = "outcome";
ax(i).trialType = ["hiPuffs_error", "loPuffs_error"];
ax(i).window    = [-1, 5];
ax(i).color      = {colors.err, colors.err2}; 
ax(i).lineStyle  = {'-',':'};
ax(i).xLabel = 'Time from outcome (s)';  % XLabel
i=i+1;

%---START-OF-TRIAL RESPONSES---------------------------------------------------
ax(i).title         = 'Time';
ax(i).comparison    = "time";
ax(i).trigger       = "start";
ax(i).trialType     = "forward";
ax(i).window        = [-3, 7];
ax(i).color         = {colors.data}; %Outcome: hit/priorHit vs err/priorHit
ax(i).lineStyle     = {'-','-'};
ax(i).xLabel        = 'Time from start (s)';  % XLabel
i=i+1;

ax(i).title         = 'Choice';
ax(i).comparison    = "choice-start";
ax(i).trigger       = "start";
ax(i).trialType     = ["left", "right"];
ax(i).window        = [-1, 5];
ax(i).color         = {colors.left, colors.right};
ax(i).lineStyle     = {'-','-'};
ax(i).xLabel        = 'Time from start (s)';  % XLabel
i=i+1;

%---TURN ENTRY RESPONSES---------------------------------------------------
% ax(i).title         = 'Choice';
% ax(i).comparison    = "choice-turn";
% ax(i).trigger       = "turnEntry";
% ax(i).trialType     = ["left", "right"];
% ax(i).window        = [-1, 5];
% ax(i).color         = {colors.left, colors.right};
% ax(i).lineStyle     = {'-','-'};
% ax(i).xLabel        = 'Time from turn (s)';  % XLabel
% i=i+1;
% 
% ax(i).title         = 'Accuracy';
% ax(i).comparison    = "accuracy-turn";
% ax(i).trigger       = "turnEntry";
% ax(i).trialType     = ["correct", "error"];
% ax(i).window        = [-1, 5];
% ax(i).color         = {colors.correct, colors.err};
% ax(i).lineStyle     = {'-','-'};
% ax(i).xLabel        = 'Time from turn (s)';  % XLabel
% i=i+1;
% 
% ax(i).title         = "Congruent Trials";
% ax(i).comparison    = "choice-turn-conflict";
% ax(i).trigger       = "turnEntry";
% ax(i).trialType     = ["left_congruent", "right_congruent"];
% ax(i).window        = [-1, 5];
% ax(i).color         = {colors.left, colors.right};
% ax(i).lineStyle     = {'-','-'};
% ax(i).xLabel        = 'Time from turn (s)';  % XLabel
% i=i+1;
% ax(i).title         = "Conflict Trials";
% ax(i).comparison    = "choice-turn-conflict";
% ax(i).trigger       = "turnEntry";
% ax(i).trialType     = ["left_conflict", "right_conflict"];
% ax(i).window        = [-1, 5];
% ax(i).color         = {colors.left, colors.right};
% ax(i).lineStyle     = {'-','-'};
% ax(i).xLabel        = 'Time from turn (s)';  % XLabel
% i=i+1;
% 
% ax(i).title         = "All Trials";
% ax(i).comparison    = "conflict-turnEntry";
% ax(i).trigger       = "turnEntry";
% ax(i).trialType     = ["congruent", "conflict"];
% ax(i).window        = [-1, 5];
% ax(i).color         = {colors.congruent, colors.conflict}; 
% ax(i).lineStyle     = {'-','-'};
% ax(i).xLabel        = 'Time from turn (s)';  % XLabel
% i=i+1;
% 
% ax(i).title         = "Correct Trials";
% ax(i).comparison    = "conflict-turnEntry";
% ax(i).trigger       = "turnEntry";
% ax(i).trialType     = ["congruent_correct", "conflict_correct"];
% ax(i).window        = [-1, 5];
% ax(i).color         = {colors.congruent, colors.conflict}; 
% ax(i).lineStyle     = {'-','-'};
% ax(i).xLabel        = 'Time from turn (s)';  % XLabel
% i=i+1;

%---CUE RESPONSES----------------------------------------------------------

ax(i).title      = 'Air Puff Response';
ax(i).comparison   = 'first-puff';
ax(i).trigger    = "firstPuff";
ax(i).trialType  = ["leftPuffs", "rightPuffs"];
ax(i).window     = [-1, 2];
ax(i).color      = {colors.left, colors.right}; 
ax(i).lineStyle  = {'-','-'};
ax(i).xLabel = 'Time from first cue (s)';  % XLabel
i=i+1;
ax(i).title      = 'Choice Contrast';
ax(i).comparison   = 'first-puff-choice';
ax(i).trigger    = "firstPuff";
ax(i).trialType  = ["left", "right"];
ax(i).window     = [-1, 2];
ax(i).color      = {colors.left, colors.right}; 
ax(i).lineStyle  = {'-','-'};
ax(i).xLabel = 'Time from first cue (s)';  % XLabel
i=i+1;

ax(i).title      = 'Low Count Trials';
ax(i).comparison   = 'first-puff-count';
ax(i).trigger   = "firstPuff";
ax(i).trialType = ["leftPuffs_loPuffs", "rightPuffs_loPuffs"];
ax(i).window    = [-1, 2];
ax(i).color      = {colors.left, colors.right}; 
ax(i).lineStyle  = {'-','-'};
ax(i).xLabel = 'Time from first cue (s)';  % XLabel
i=i+1;
ax(i).title      = 'High Count Trials';
ax(i).comparison   = 'first-puff-count';
ax(i).trigger   = "firstPuff";
ax(i).trialType = ["leftPuffs_hiPuffs", "rightPuffs_hiPuffs"];
ax(i).window    = [-1, 2];
ax(i).color      = {colors.left, colors.right}; 
ax(i).lineStyle  = {'-','-'};
ax(i).xLabel = 'Time from first cue (s)';  % XLabel
i=i+1;

ax(i).title      = 'Tower Response';
ax(i).comparison   = 'first-tower';
ax(i).trigger   = "firstTower";
ax(i).trialType = ["leftTowers", "rightTowers"];
ax(i).window    = [-1, 2];
ax(i).color      = {colors.left, colors.right}; 
ax(i).lineStyle  = {'-','-'};
ax(i).xLabel = 'Time from first cue (s)';  % XLabel
i=i+1;
ax(i).title      = 'Choice Contrast';
ax(i).comparison   = 'first-tower-choice';
ax(i).trigger    = "firstTower";
ax(i).trialType  = ["left", "right"];
ax(i).window     = [-1, 2];
ax(i).color      = {colors.left, colors.right}; 
ax(i).lineStyle  = {'-','-'};
ax(i).xLabel = 'Time from first cue (s)';  % XLabel
i=i+1;

ax(i).title      = 'Low Count Trials';
ax(i).comparison   = 'first-tower-count';
ax(i).trigger   = "firstTower";
ax(i).trialType = ["leftTowers_loTowers", "rightTowers_loTowers"];
ax(i).window    = [-1, 2];
ax(i).color      = {colors.left, colors.right}; 
ax(i).lineStyle  = {'-','-'};
ax(i).xLabel = 'Time from first cue (s)';  % XLabel
i=i+1;
ax(i).title      = 'High Count Trials';
ax(i).comparison   = 'first-tower-count';
ax(i).trigger   = "firstTower";
ax(i).trialType = ["leftTowers_hiTowers", "rightTowers_hiTowers"];
ax(i).window    = [-1, 2];
ax(i).color      = {colors.left, colors.right}; 
ax(i).lineStyle  = {'-','-'};
ax(i).xLabel = 'Time from first cue (s)';  % XLabel
i=i+1;

ax(i).title         = "Tower Side";
ax(i).comparison    = "tower-onset";
ax(i).trigger       = "towers";
ax(i).trialType     = ["leftTowers", "rightTowers"];
ax(i).window        = [-1, 2];
ax(i).color         = {colors.left, colors.right}; %Choice: left/hit/sound vs right/hit/sound
ax(i).lineStyle     = {'-','-'};
ax(i).xLabel        = 'Time from cue onset (s)';  % XLabel
i=i+1;
ax(i).title         = "Tower Count";
ax(i).comparison    = "tower-onset";
ax(i).trigger       = "towers";
ax(i).trialType     = ["hiTowers", "loTowers"];
ax(i).window        = [-1, 2];
ax(i).color         = {colors.orange, colors.orange2}; %Choice: left/hit/sound vs right/hit/sound
ax(i).lineStyle     = {'-','-'};
ax(i).xLabel        = 'Time from cue onset (s)';  % XLabel
i=i+1;

ax(i).title         = "Puff Side";
ax(i).comparison    = "puff-onset";
ax(i).trigger       = "puffs";
ax(i).trialType     = ["leftPuffs", "rightPuffs"];
ax(i).window        = [-1, 2];
ax(i).color         = {colors.left, colors.right}; %Choice: left/hit/sound vs right/hit/sound
ax(i).lineStyle     = {'-','-'};
ax(i).xLabel        = 'Time from cue onset (s)';  % XLabel
i=i+1;
ax(i).title         = "Puff Count";
ax(i).comparison    = "puff-onset";
ax(i).trigger       = "puffs";
ax(i).trialType     = ["hiPuffs", "loPuffs"];
ax(i).window        = [-1, 2];
ax(i).color         = {colors.orange, colors.orange2}; %Choice: left/hit/sound vs right/hit/sound
ax(i).lineStyle     = {'-','-'};
ax(i).xLabel        = 'Time from cue onset (s)';  % XLabel
i=i+1;

%%---POSITION (omit for now)-----------------------------------------------

% ax(i).title         = "Position";
% ax(i).comparison    = "position";
% ax(i).trigger       = "cueRegion";
% ax(i).trialType     = "forward";
% ax(i).window        = [-50, 300];
% ax(i).color         = {colors.data}; %Choice: left/hit/sound vs right/hit/sound
% ax(i).lineStyle     = {'-'};
% ax(i).xLabel        = 'Distance (cm)';  % XLabel


[ax(:).yLabel]          = deal('Cellular Fluorescence (dF/F)');
[ax(:).verboseLegend]   = deal(false);