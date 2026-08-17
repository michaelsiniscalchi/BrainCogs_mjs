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
ax(i).trialType     = ["towers_noPuffs", "puffs_noTowers"];
ax(i).window        = [-inf, inf];
ax(i).color         = {colors.visual, colors.tactile}; %Choice: left/hit/sound vs right/hit/sound
ax(i).lineStyle     = {'-','-'};
ax(i).xLabel        = 'Distance (cm)';  % XLabel
i=i+1;
ax(i).title         = "Tower Side"; %Or just do relevant cueSide
ax(i).comparison    = "cue-region";
ax(i).trigger       = "cueRegion";
ax(i).trialType     = ["leftTowers", "rightTowers"];
ax(i).window        = [-inf, inf];
ax(i).color         = {colors.left,colors.right}; %Choice: left/hit/sound vs right/hit/sound
ax(i).lineStyle     = {'-','-'};
ax(i).xLabel        = 'Distance (cm)';  % XLabel
i=i+1;
ax(i).title         = "Puff Side";
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

ax(i).title         = "Cue Conflict";
ax(i).comparison    = "cueRegion-conflict";
ax(i).trigger       = "cueRegion";
ax(i).trialType     = ["congruent", "conflict"];
ax(i).window        = [-inf, inf];
ax(i).color         = {colors.congruent, colors.conflict}; 
ax(i).lineStyle     = {'-','-'};
ax(i).xLabel        = 'Distance (cm)';  % XLabel
i=i+1;

ax(i).title         = 'Puff Side';
ax(i).comparison    = "cueRegion-puffSide";
ax(i).trigger       = "cueRegion";
ax(i).trialType     = ["leftPuffs_hiPuffs", "rightPuffs_hiPuffs", "noPuffs"];
ax(i).window        = [-inf, inf];
ax(i).color         = {colors.left, colors.right, colors.data2}; %Outcome: hit/priorHit vs err/priorHit
ax(i).lineStyle     = {'-','-','-'};
ax(i).xLabel        = 'Distance (cm)';  % XLabel
i=i+1;
ax(i).title         = 'Tower Side';
ax(i).comparison    = "cueRegion-towerSide";
ax(i).trigger       = "cueRegion";
ax(i).trialType     = ["leftTowers_hiTowers", "rightTowers_hiTowers", "noTowers"];
ax(i).window        = [-inf, inf];
ax(i).color         = {colors.left, colors.right, colors.data2}; %Outcome: hit/priorHit vs err/priorHit
ax(i).lineStyle     = {'-','-','-'};
ax(i).xLabel        = 'Distance (cm)';  % XLabel
i=i+1;

ax(i).title         = 'Single-Modality Trials';
ax(i).comparison    = "cueRegion-zeroCues-cueType";
ax(i).trigger       = "cueRegion";
ax(i).trialType     = ["towers_noPuffs", "puffs_noTowers"];
ax(i).window        = [-inf, inf];
ax(i).color         = {colors.visual, colors.tactile}; %Outcome: hit/priorHit vs err/priorHit
ax(i).lineStyle     = {'-','-'};
ax(i).xLabel        = 'Distance (cm)';  % XLabel
i=i+1;

%Prior and current trial outcome as f(position) 
ax(i).title         = 'Prior Outcome';
ax(i).comparison    = "cueRegion-priorOutcome";
ax(i).trigger       = "cueRegion";
ax(i).trialType     = ["priorCorrect", "priorError"];
ax(i).window        = [-inf, inf];
ax(i).color         = {colors.correct, colors.err}; 
ax(i).lineStyle     = {'-','-'};
ax(i).xLabel        = 'Distance (cm)';  % XLabel
i=i+1;
ax(i).title         = 'Accuracy';
ax(i).comparison    = "cueRegion-outcome";
ax(i).trigger       = "cueRegion";
ax(i).trialType     = ["correct", "error"];
ax(i).window        = [-inf, inf];
ax(i).color         = {colors.correct, colors.err};
ax(i).lineStyle     = {'-','-'};
ax(i).xLabel        = 'Distance (cm)';  % XLabel
i=i+1;

%Cue Value
ax(i).title         = 'Puff Side (Prior Correct)';
ax(i).comparison    = "cueRegion-cueSideValue";
ax(i).trigger       = "cueRegion";
ax(i).trialType     = ["repeatPuffSide_priorRewarded", "switchPuffSide_priorRewarded"];
ax(i).window        = [-inf, inf];
ax(i).color         = {colors.tactile, colors.tactile2};
ax(i).lineStyle     = {'-','-'};
ax(i).xLabel        = 'Distance (cm)';  % XLabel
i=i+1;
ax(i).title         = 'Tower Side (Prior Correct)';
ax(i).comparison    = "cueRegion-cueSideValue";
ax(i).trigger       = "cueRegion";
ax(i).trialType     = ["repeatTowerSide_priorRewarded", "switchTowerSide_priorRewarded"];
ax(i).window        = [-inf, inf];
ax(i).color         = {colors.visual, colors.visual2};
ax(i).lineStyle     = {'-','-'};
ax(i).xLabel        = 'Distance (cm)';  % XLabel
i=i+1;

% ax(i).title         = 'Puff Side Value';
% ax(i).comparison    = "cueRegion-puffSideValue";
% ax(i).trigger       = "cueRegion";
% ax(i).trialType     = ["puffSideValued", "puffSideDevalued"];
% ax(i).window        = [-inf, inf];
% ax(i).color         = {colors.tactile, colors.tactile2}; 
% ax(i).lineStyle     = {'-','-'};
% ax(i).xLabel        = 'Distance (cm)';  % XLabel
% i=i+1;
% ax(i).title         = 'Left Puffs Value'; %Split by side
% ax(i).comparison    = "cueRegion-puffSideValue";
% ax(i).trigger       = "cueRegion";
% ax(i).trialType     = ["leftPuffsValued_leftPuffs", "leftPuffsDevalued_leftPuffs"];
% ax(i).window        = [-inf, inf];
% ax(i).color         = {colors.left, colors.left2}; 
% ax(i).lineStyle     = {'-','-'};
% ax(i).xLabel        = 'Distance (cm)';  % XLabel
% i=i+1;
% ax(i).title         = 'Right Puffs Value'; %Split by side
% ax(i).comparison    = "cueRegion-puffSideValue";
% ax(i).trigger       = "cueRegion";
% ax(i).trialType     = ["rightPuffsValued_rightPuffs", "rightPuffsDevalued_rightPuffs"];
% ax(i).window        = [-inf, inf];
% ax(i).color         = {colors.right, colors.right2}; 
% ax(i).lineStyle     = {'-','-'};
% ax(i).xLabel        = 'Distance (cm)';  % XLabel
% i=i+1;
% 
% ax(i).title         = 'Tower Side Value';
% ax(i).comparison    = "cueRegion-towerSideValue";
% ax(i).trigger       = "cueRegion";
% ax(i).trialType     = ["towerSideValued", "towerSideDevalued"];
% ax(i).window        = [-inf, inf];
% ax(i).color         = {colors.visual, colors.visual2}; 
% ax(i).lineStyle     = {'-','-'};
% ax(i).xLabel        = 'Distance (cm)';  % XLabel
% i=i+1;
% ax(i).title         = 'Left Towers Value'; %Split by side
% ax(i).comparison    = "cueRegion-towerSideValue";
% ax(i).trigger       = "cueRegion";
% ax(i).trialType     = ["leftTowersValued_leftTowers", "leftTowersDevalued_leftTowers"];
% ax(i).window        = [-inf, inf];
% ax(i).color         = {colors.left, colors.left2}; 
% ax(i).lineStyle     = {'-','-'};
% ax(i).xLabel        = 'Distance (cm)';  % XLabel
% i=i+1;
% ax(i).title         = 'Right Towers Value'; %Split by side
% ax(i).comparison    = "cueRegion-towerSideValue";
% ax(i).trigger       = "cueRegion";
% ax(i).trialType     = ["rightTowersValued_rightTowers", "rightTowersDevalued_rightTowers"];
% ax(i).window        = [-inf, inf];
% ax(i).color         = {colors.right, colors.right2}; 
% ax(i).lineStyle     = {'-','-'};
% ax(i).xLabel        = 'Distance (cm)';  % XLabel
% i=i+1;

%%---OUTCOME RESPONSES-----------------------------------------------------

ax(i).title         = 'Outcome';
ax(i).comparison    = "reward-noReward";
ax(i).trigger       = "outcome";
ax(i).trialType     = ["correct", "error"];
ax(i).window        = [-1, 5];
ax(i).color         = {colors.correct,colors.err}; %Outcome: hit/priorHit vs err/priorHit
ax(i).lineStyle     = {'-','-'};
ax(i).xLabel        = 'Time from outcome (s)';  % XLabel
i=i+1;

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

%Cue Value
ax(i).title         = 'Puffs (Correct/Prior Correct)';
ax(i).comparison    = "outcome-cueSideValue";
ax(i).trigger       = "outcome";
ax(i).trialType     = ["repeatPuffSide_priorRewarded_rewarded", "switchPuffSide_priorRewarded_rewarded"];
ax(i).window        = [-inf, inf];
ax(i).color         = {colors.tactile, colors.tactile2}; 
ax(i).lineStyle     = {'-','-'};
ax(i).xLabel        = 'Time from outcome (s)';  % XLabel
i=i+1;
ax(i).title         = 'Towers (Correct/Prior Correct)';
ax(i).comparison    = "outcome-cueSideValue";
ax(i).trigger       = "outcome";
ax(i).trialType     = ["repeatTowerSide_priorRewarded_rewarded", "switchTowerSide_priorRewarded_rewarded"];
ax(i).window        = [-inf, inf];
ax(i).color         = {colors.visual, colors.visual2}; 
ax(i).lineStyle     = {'-','-'};
ax(i).xLabel        = 'Time from outcome (s)';  % XLabel
i=i+1;
ax(i).title         = 'Puffs (Error/Prior Correct)';
ax(i).comparison    = "outcome-cueSideValue";
ax(i).trigger       = "outcome";
ax(i).trialType     = ["repeatPuffSide_priorRewarded_unrewarded", "switchPuffSide_priorRewarded_unrewarded"];
ax(i).window        = [-inf, inf];
ax(i).color         = {colors.tactile, colors.tactile2}; 
ax(i).lineStyle     = {'-','-'};
ax(i).xLabel        = 'Time from outcome (s)';  % XLabel
i=i+1;
ax(i).title         = 'Towers (Error/Prior Correct)';
ax(i).comparison    = "outcome-cueSideValue";
ax(i).trigger       = "outcome";
ax(i).trialType     = ["repeatTowerSide_priorRewarded_unrewarded", "switchTowerSide_priorRewarded_unrewarded"];
ax(i).window        = [-inf, inf];
ax(i).color         = {colors.visual, colors.visual2}; 
ax(i).lineStyle     = {'-','-'};
ax(i).xLabel        = 'Time from outcome (s)';  % XLabel
i=i+1;

%---START-OF-TRIAL RESPONSES---------------------------------------------------
ax(i).title         = 'Time';
ax(i).comparison    = "time";
ax(i).trigger       = "start";
ax(i).trialType     = "forward";
ax(i).window        = [-1, 5];
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

%--- CUE ENTRY RESPONSES---------------------------------------------------
% ax(i).title         = 'Cue Entry';
% ax(i).comparison    = "cue-entry";
% ax(i).trigger       = "cueEntry";
% ax(i).trialType     = "forward";
% ax(i).window        = [-1, 5];
% ax(i).color         = {colors.data}; %Outcome: hit/priorHit vs err/priorHit
% ax(i).lineStyle     = {'-','-'};
% ax(i).xLabel        = 'Time from entry (s)';  % XLabel
% i=i+1;
% 
% ax(i).title         = 'Cue Entry';
% ax(i).comparison    = "cue-entry";
% ax(i).trigger       = "cueEntry";
% ax(i).trialType     = ["left", "right"];
% ax(i).window        = [-1, 5];
% ax(i).color         = {colors.left, colors.right};
% ax(i).lineStyle     = {'-','-'};
% ax(i).xLabel        = 'Time from start (s)';  % XLabel
% i=i+1;

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

ax(i).title      = 'Tower Response';
ax(i).comparison   = 'first-tower';
ax(i).trigger    = "firstTower";
ax(i).trialType  = ["leftTowers", "rightTowers"];
ax(i).window     = [-1, 2];
ax(i).color      = {colors.left, colors.right}; 
ax(i).lineStyle  = {'-','-'};
ax(i).xLabel = 'Time from first cue (s)';  % XLabel
i=i+1;

ax(i).title      = 'Cue Response (Single Modality Trials)';
ax(i).comparison   = 'first-cue';
ax(i).trigger   = "firstCue";
ax(i).trialType = ["puffs_noTowers", "towers_noPuffs"];
ax(i).window    = [-1, 2];
ax(i).color      = {colors.tactile, colors.visual}; 
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

ax(i).title         = "Puff Side";
ax(i).comparison    = "puff-onset";
ax(i).trigger       = "puffs";
ax(i).trialType     = ["leftPuffs", "rightPuffs"];
ax(i).window        = [-1, 2];
ax(i).color         = {colors.left, colors.right}; %Choice: left/hit/sound vs right/hit/sound
ax(i).lineStyle     = {'-','-'};
ax(i).xLabel        = 'Time from cue onset (s)';  % XLabel
i=i+1;

%Cue Value
ax(i).title         = 'Puff Side (Prior Correct)';
ax(i).comparison    = "puffSideValue";
ax(i).trigger       = "firstPuff";
ax(i).trialType     = ["repeatPuffSide_priorRewarded", "switchPuffSide_priorRewarded"];
ax(i).window        = [-1, 2];
ax(i).color         = {colors.tactile, colors.tactile2};
ax(i).lineStyle     = {'-','-'};
ax(i).xLabel        = 'Time from first cue (s)';  % XLabel
i=i+1;
ax(i).title         = 'Tower Side (Prior Correct)';
ax(i).comparison    = "towerSideValue";
ax(i).trigger       = "firstTower";
ax(i).trialType     = ["repeatTowerSide_priorRewarded", "switchTowerSide_priorRewarded"];
ax(i).window        = [-1, 2];
ax(i).color         = {colors.visual, colors.visual2};
ax(i).lineStyle     = {'-','-'};
ax(i).xLabel        = 'Time from first cue (s)';  % XLabel
i=i+1;

% ax(i).title         = 'Puff Side Value';
% ax(i).comparison    = "puffSideValue";
% ax(i).trigger       = "firstPuff";
% ax(i).trialType     = ["puffSideValued", "puffSideDevalued"];
% ax(i).window        = [-1, 2];
% ax(i).color         = {colors.tactile, colors.tactile2}; 
% ax(i).lineStyle     = {'-','-'};
% ax(i).xLabel        = 'Time from first cue (s)';  % XLabel
% i=i+1;
% ax(i).title         = 'Left Puffs Value'; %Split by side
% ax(i).comparison    = "puffSideValue";
% ax(i).trigger       = "firstPuff";
% ax(i).trialType     = ["leftPuffsValued_leftPuffs", "leftPuffsDevalued_leftPuffs"];
% ax(i).window        = [-1, 2];
% ax(i).color         = {colors.left, colors.left2}; 
% ax(i).lineStyle     = {'-','-'};
% ax(i).xLabel        = 'Time from first cue (s)';  % XLabel
% i=i+1;
% ax(i).title         = 'Right Puffs Value'; %Split by side
% ax(i).comparison    = "puffSideValue";
% ax(i).trigger       = "firstPuff";
% ax(i).trialType     = ["rightPuffsValued_rightPuffs", "rightPuffsDevalued_rightPuffs"];
% ax(i).window        = [-1, 2];
% ax(i).color         = {colors.right, colors.right2}; 
% ax(i).lineStyle     = {'-','-'};
% ax(i).xLabel        = 'Time from first cue (s)';  % XLabel
% i=i+1;
% 
% ax(i).title         = 'Tower Side Value';
% ax(i).comparison    = "towerSideValue";
% ax(i).trigger       = "firstTower";
% ax(i).trialType     = ["towerSideValued", "towerSideDevalued"];
% ax(i).window        = [-1, 2];
% ax(i).color         = {colors.visual, colors.visual2}; 
% ax(i).lineStyle     = {'-','-'};
% ax(i).xLabel        = 'Time from first cue (s)';  % XLabel
% i=i+1;
% ax(i).title         = 'Left Towers Value'; %Split by side
% ax(i).comparison    = "towerSideValue";
% ax(i).trigger       = "firstTower";
% ax(i).trialType     = ["leftTowersValued_leftTowers", "leftTowersDevalued_leftTowers"];
% ax(i).window        = [-1, 2];
% ax(i).color         = {colors.left, colors.left2}; 
% ax(i).lineStyle     = {'-','-'};
% ax(i).xLabel        = 'Time from first cue (s)';  % XLabel
% i=i+1;
% ax(i).title         = 'Right Towers Value'; %Split by side
% ax(i).comparison    = "towerSideValue";
% ax(i).trigger       = "firstTower";
% ax(i).trialType     = ["rightTowersValued_rightTowers", "rightTowersDevalued_rightTowers"];
% ax(i).window        = [-1, 2];
% ax(i).color         = {colors.right, colors.right2}; 
% ax(i).lineStyle     = {'-','-'};
% ax(i).xLabel        = 'Time from first cue (s)';  % XLabel
% i=i+1;

%%---POSITION (omit for now)-----------------------------------------------

ax(i).title         = "Position";
ax(i).comparison    = "position";
ax(i).trigger       = "cueRegion";
ax(i).trialType     = "forward";
ax(i).window        = [-inf, inf];
ax(i).color         = {colors.data}; %Choice: left/hit/sound vs right/hit/sound
ax(i).lineStyle     = {'-'};
ax(i).xLabel        = 'Distance (cm)';  % XLabel

[ax(:).tickLabelFormat] = deal('%.2f');
[ax(:).yLabel]          = deal('Cellular Fluorescence (dF/F)');
[ax(:).verboseLegend]   = deal(false);