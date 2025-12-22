function ax = spec_behEncodingPanels( colors )

%Specify struct 'ax' containing variables and plotting params for each figure panel:

i=1;

%Summary Figure for PsyTrack vs. Encoding Model Across Sessions

%------- Cue Events -------
%Left Towers
ax(i).title         = "Left Towers";
ax(i).behVar        = "psyTrack_leftTowers_meanCoef";
ax(i).behVarSE      = "psyTrack_leftTowers_sd"; %or []
ax(i).encVar        = ["kernel","firstLeftTower","AUC"];
ax(i).color         = {colors.left, colors.left2};
ax(i).lineStyle     = ["-","-"]; 
ax(i).yLabel        = ["PsyTrack weight","Encoding kernel (AUC)"];
i=i+1;

%Right Towers
ax(i).title         = "Right Towers";
ax(i).behVar        = "psyTrack_rightTowers_meanCoef";
ax(i).behVarSE      = "psyTrack_rightTowers_sd"; %or []
ax(i).encVar        = ["kernel","firstRightTower","AUC"];
ax(i).color         = {colors.right, colors.right2};
ax(i).lineStyle     = ["-","-"]; 
ax(i).yLabel        = ["PsyTrack weight","Encoding kernel (AUC)"];
i=i+1;

%Left Puffs
ax(i).title         = "Left Puffs";
ax(i).behVar        = "psyTrack_leftPuffs_meanCoef";
ax(i).behVarSE      = "psyTrack_leftPuffs_sd"; %or []
ax(i).encVar        = ["kernel","firstLeftPuff","AUC"];
ax(i).color         = {colors.left, colors.left2};
ax(i).lineStyle     = ["-","-"]; 
ax(i).yLabel        = ["PsyTrack weight","Encoding kernel (AUC)"];
i=i+1;

%Right Puffs
ax(i).title         = "Right Puffs";
ax(i).behVar        = "psyTrack_rightPuffs_meanCoef";
ax(i).behVarSE      = "psyTrack_rightPuffs_sd"; %or []
ax(i).encVar        = ["kernel","firstRightPuff","AUC"];
ax(i).color         = {colors.right, colors.right2};
ax(i).lineStyle     = ["-","-"]; 
ax(i).yLabel        = ["PsyTrack weight","Encoding kernel (AUC)"];
i=i+1;

%--- Cue x Position "Ramps" ---
%Towers
ax(i).title         = "Tower Side x Position";
ax(i).behVar        = "psyTrack_diffTowers_meanCoef";
ax(i).behVarSE      = "psyTrack_diffTowers_sd"; %or []
ax(i).encVar        = ["kernel","towerSide_position","AUC"];
ax(i).color         = {colors.visual, colors.visual2};
ax(i).lineStyle     = ["-","-"]; 
ax(i).yLabel        = ["PsyTrack weight","Encoding kernel (AUC)"];
i=i+1;

%Puffs
ax(i).title         = "Puff Side x Position";
ax(i).behVar        = "psyTrack_diffPuffs_meanCoef";
ax(i).behVarSE      = "psyTrack_diffPuffs_sd"; %or []
ax(i).encVar        = ["kernel","puffSide_position","AUC"];
ax(i).color         = {colors.tactile, colors.tactile2};
ax(i).lineStyle     = ["-","-"]; 
ax(i).yLabel        = ["PsyTrack weight","Encoding kernel (AUC)"];
i=i+1;

%Towers - bias
ax(i).title         = "Tower Side x Position";
ax(i).behVar        = "psyTrack_bias_meanCoef";
ax(i).behVarSE      = "psyTrack_bias_sd"; %or []
ax(i).encVar        = ["kernel","towerSide_position","AUC"];
ax(i).color         = {colors.visual, colors.visual2};
ax(i).lineStyle     = ["-","-"]; 
ax(i).yLabel        = ["PsyTrack weight","Encoding kernel (AUC)"];
i=i+1;

%Puffs - bias
ax(i).title         = "Puff Side x Position";
ax(i).behVar        = "psyTrack_bias_meanCoef";
ax(i).behVarSE      = "psyTrack_bias_sd"; %or []
ax(i).encVar        = ["kernel","puffSide_position","AUC"];
ax(i).color         = {colors.tactile, colors.tactile2};
ax(i).lineStyle     = ["-","-"]; 
ax(i).yLabel        = ["PsyTrack weight","Encoding kernel (AUC)"];
i=i+1;

%------- Reward -------
%Reward - pCorrect
ax(i).title         = "Reward";
ax(i).behVar        = "pCorrect";
ax(i).behVarSE      = []; %or []
ax(i).encVar        = ["kernel","reward","AUC"];
ax(i).color         = {colors.correct, colors.correct2};
ax(i).lineStyle     = ["-","-"]; 
ax(i).yLabel        = ["P(correct)", "Encoding kernel (AUC)"];
i=i+1;

%Reward - pCorrect (congruent)
ax(i).title         = "Reward";
ax(i).behVar        = "pCorrect_congruent";
ax(i).behVarSE      = []; %or []
ax(i).encVar        = ["kernel","reward","AUC"];
ax(i).color         = {colors.correct, colors.correct2};
ax(i).lineStyle     = ["-","-"]; 
ax(i).yLabel        = ["P(correct): congruent", "Encoding kernel (AUC)"];
i=i+1;

%Reward - pCorrect (conflict)
ax(i).title         = "Reward";
ax(i).behVar        = "pCorrect_conflict";
ax(i).behVarSE      = []; %or []
ax(i).encVar        = ["kernel","reward","AUC"];
ax(i).color         = {colors.correct, colors.correct2};
ax(i).lineStyle     = ["-","-"]; 
ax(i).yLabel        = ["P(correct): conflict", "Encoding kernel (AUC)"];
i=i+1;


[ax(:).xLabel]          = deal('Imaging Sessions');