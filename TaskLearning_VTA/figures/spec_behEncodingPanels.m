function ax = spec_behEncodingPanels( colors )

%Specify struct 'ax' containing variables and plotting params for each figure panel:

i=1;

%Summary Figure for PsyTrack vs. Encoding Model Across Sessions

%------- Cue Events -------------------------------------------------------
%Left Towers vs PsyTrack
ax(i).title         = "Left Towers";
ax(i).behVar        = "psyTrack_leftTowers_meanCoef";
ax(i).behVarSE      = "psyTrack_leftTowers_sd"; %or []
ax(i).encVar        = ["kernel","firstLeftTower","AUC"];
ax(i).color         = {colors.left, colors.left2};
ax(i).lineStyle     = ["-","-"]; 
ax(i).yLabel        = ["PsyTrack weight","Encoding kernel (AUC)"];
i=i+1;
ax(i).title         = "Left Towers";
ax(i).behVar        = "psyTrack_leftTowers_meanCoef";
ax(i).behVarSE      = "psyTrack_leftTowers_sd"; %or []
ax(i).encVar        = ["kernel","leftTowers","AUC"];
ax(i).color         = {colors.left, colors.left2};
ax(i).lineStyle     = ["-","-"]; 
ax(i).yLabel        = ["PsyTrack weight","Encoding kernel (AUC)"];
i=i+1;

%Right Towers vs PsyTrack
ax(i).title         = "Right Towers";
ax(i).behVar        = "psyTrack_rightTowers_meanCoef";
ax(i).behVarSE      = "psyTrack_rightTowers_sd"; %or []
ax(i).encVar        = ["kernel","firstRightTower","AUC"];
ax(i).color         = {colors.right, colors.right2};
ax(i).lineStyle     = ["-","-"]; 
ax(i).yLabel        = ["PsyTrack weight","Encoding kernel (AUC)"];
i=i+1;
ax(i).title         = "Right Towers";
ax(i).behVar        = "psyTrack_rightTowers_meanCoef";
ax(i).behVarSE      = "psyTrack_rightTowers_sd"; %or []
ax(i).encVar        = ["kernel","rightTowers","AUC"];
ax(i).color         = {colors.right, colors.right2};
ax(i).lineStyle     = ["-","-"]; 
ax(i).yLabel        = ["PsyTrack weight","Encoding kernel (AUC)"];

i=i+1;

%Left Puffs vs PsyTrack
ax(i).title         = "Left Puffs";
ax(i).behVar        = "psyTrack_leftPuffs_meanCoef";
ax(i).behVarSE      = "psyTrack_leftPuffs_sd"; %or []
ax(i).encVar        = ["kernel","firstLeftPuff","AUC"];
ax(i).color         = {colors.left, colors.left2};
ax(i).lineStyle     = ["-","-"]; 
ax(i).yLabel        = ["PsyTrack weight","Encoding kernel (AUC)"];
i=i+1;
ax(i).title         = "Left Puffs";
ax(i).behVar        = "psyTrack_leftPuffs_meanCoef";
ax(i).behVarSE      = "psyTrack_leftPuffs_sd"; %or []
ax(i).encVar        = ["kernel","leftPuffs","AUC"];
ax(i).color         = {colors.left, colors.left2};
ax(i).lineStyle     = ["-","-"]; 
ax(i).yLabel        = ["PsyTrack weight","Encoding kernel (AUC)"];
i=i+1;

%Right Puffs vs PsyTrack
ax(i).title         = "Right Puffs";
ax(i).behVar        = "psyTrack_rightPuffs_meanCoef";
ax(i).behVarSE      = "psyTrack_rightPuffs_sd"; %or []
ax(i).encVar        = ["kernel","firstRightPuff","AUC"];
ax(i).color         = {colors.right, colors.right2};
ax(i).lineStyle     = ["-","-"]; 
ax(i).yLabel        = ["PsyTrack weight","Encoding kernel (AUC)"];
i=i+1;
ax(i).title         = "Right Puffs";
ax(i).behVar        = "psyTrack_rightPuffs_meanCoef";
ax(i).behVarSE      = "psyTrack_rightPuffs_sd"; %or []
ax(i).encVar        = ["kernel","rightPuffs","AUC"];
ax(i).color         = {colors.right, colors.right2};
ax(i).lineStyle     = ["-","-"]; 
ax(i).yLabel        = ["PsyTrack weight","Encoding kernel (AUC)"];
i=i+1;

%Left Towers vs pCorrect --------
for cueVar = ["leftTowers","firstLeftTower","leftTowers_position"]
    for behVar = ["pCorrect"] %, "pCorrect_congruent", "pCorrect_conflict"]
        ax(i).title         = "Left Towers";
        ax(i).behVar        = behVar;
        ax(i).behVarSE      = []; %or []
        ax(i).encVar        = ["kernel", cueVar, "AUC"];
        ax(i).color         = {colors.left, colors.left2};
        ax(i).lineStyle     = ["-","-"];
        ax(i).yLabel        = ["Correct rate","Encoding kernel (AUC)"];
        i=i+1;
    end
end

%Right Towers vs pCorrect --------
for cueVar = ["rightTowers","firstRightTower","rightTowers_position"]
    for behVar = ["pCorrect"] %, "pCorrect_congruent", "pCorrect_conflict"]
        ax(i).title         = "Right Towers";
        ax(i).behVar        = behVar;
        ax(i).behVarSE      = []; %or []
        ax(i).encVar        = ["kernel", cueVar, "AUC"];
        ax(i).color         = {colors.right, colors.right2};
        ax(i).lineStyle     = ["-","-"];
        ax(i).yLabel        = ["Correct rate","Encoding kernel (AUC)"];
        i=i+1;
    end
end

%Left Puffs vs pCorrect --------
for cueVar = ["leftPuffs","firstLeftPuff","leftPuffs_position"]
    for behVar = ["pCorrect"] %, "pCorrect_congruent", "pCorrect_conflict"]
        ax(i).title         = "Left Puffs";
        ax(i).behVar        = behVar;
        ax(i).behVarSE      = []; %or []
        ax(i).encVar        = ["kernel", cueVar, "AUC"];
        ax(i).color         = {colors.left, colors.left2};
        ax(i).lineStyle     = ["-","-"];
        ax(i).yLabel        = ["Correct rate","Encoding kernel (AUC)"];
        i=i+1;
    end
end

%Right Towers vs pCorrect --------
for cueVar = ["rightPuffs","firstRightPuff","rightPuffs_position"]
    for behVar = ["pCorrect"] %, "pCorrect_congruent", "pCorrect_conflict"]
        ax(i).title         = "Right Puffs";
        ax(i).behVar        = behVar;
        ax(i).behVarSE      = []; %or []
        ax(i).encVar        = ["kernel", cueVar, "AUC"];
        ax(i).color         = {colors.right, colors.right2};
        ax(i).lineStyle     = ["-","-"];
        ax(i).yLabel        = ["Correct rate","Encoding kernel (AUC)"];
        i=i+1;
    end
end

%--- Cue x Position "Ramps" -----------------------------------------------
%Towers - PsyTrack coef
ax(i).title         = "Right Towers x Position";
ax(i).behVar        = "psyTrack_rightTowers_meanCoef";
ax(i).behVarSE      = "psyTrack_rightTowers_sd"; %or []
ax(i).encVar        = ["kernel","rightTowers_position","AUC"];
ax(i).color         = {colors.visual, colors.visual2};
ax(i).lineStyle     = ["-","-"]; 
ax(i).yLabel        = ["PsyTrack coef: right towers","Encoding kernel (AUC)"];
i=i+1;
ax(i).title         = "Left Towers x Position";
ax(i).behVar        = "psyTrack_leftTowers_meanCoef";
ax(i).behVarSE      = "psyTrack_leftTowers_sd"; %or []
ax(i).encVar        = ["kernel","leftTowers_position","AUC"];
ax(i).color         = {colors.visual, colors.visual2};
ax(i).lineStyle     = ["-","-"]; 
ax(i).yLabel        = ["PsyTrack coef: left towers","Encoding kernel (AUC)"];
i=i+1;

%Puffs - PsyTrack coef
ax(i).title         = "Right Puffs x Position";
ax(i).behVar        = "psyTrack_rightPuffs_meanCoef";
ax(i).behVarSE      = "psyTrack_rightPuffs_sd"; %or []
ax(i).encVar        = ["kernel","rightPuffs_position","AUC"];
ax(i).color         = {colors.tactile, colors.tactile2};
ax(i).lineStyle     = ["-","-"]; 
ax(i).yLabel        = ["PsyTrack coef: right puffs","Encoding kernel (AUC)"];
i=i+1;
ax(i).title         = "Left Puffs x Position";
ax(i).behVar        = "psyTrack_leftPuffs_meanCoef";
ax(i).behVarSE      = "psyTrack_leftPuffs_sd"; %or []
ax(i).encVar        = ["kernel","leftPuffs_position","AUC"];
ax(i).color         = {colors.tactile, colors.tactile2};
ax(i).lineStyle     = ["-","-"]; 
ax(i).yLabel        = ["PsyTrack coef: left puffs","Encoding kernel (AUC)"];
i=i+1;

%Towers - diff PsyTrack
ax(i).title         = "Tower Side x Position";
ax(i).behVar        = "psyTrack_diffTowers_meanCoef";
ax(i).behVarSE      = "psyTrack_diffTowers_sd"; %or []
ax(i).encVar        = ["kernel","towerSide_position","AUC"];
ax(i).color         = {colors.visual, colors.visual2};
ax(i).lineStyle     = ["-","-"]; 
ax(i).yLabel        = ["PsyTrack R-L coef.","Encoding kernel (AUC)"];
i=i+1;

%Puffs - diff PsyTrack
ax(i).title         = "Puff Side x Position";
ax(i).behVar        = "psyTrack_diffPuffs_meanCoef";
ax(i).behVarSE      = "psyTrack_diffPuffs_sd"; %or []
ax(i).encVar        = ["kernel","puffSide_position","AUC"];
ax(i).color         = {colors.tactile, colors.tactile2};
ax(i).lineStyle     = ["-","-"]; 
ax(i).yLabel        = ["PsyTrack R-L coef.","Encoding kernel (AUC)"];
i=i+1;

%Towers - bias
ax(i).title         = "Tower Side x Position";
ax(i).behVar        = "psyTrack_bias_meanCoef";
ax(i).behVarSE      = "psyTrack_bias_sd"; %or []
ax(i).encVar        = ["kernel","towerSide_position","AUC"];
ax(i).color         = {colors.visual, colors.visual2};
ax(i).lineStyle     = ["-","-"]; 
ax(i).yLabel        = ["PsyTrack bias","Encoding kernel (AUC)"];
i=i+1;

%Puffs - bias
ax(i).title         = "Puff Side x Position";
ax(i).behVar        = "psyTrack_bias_meanCoef";
ax(i).behVarSE      = "psyTrack_bias_sd"; %or []
ax(i).encVar        = ["kernel","puffSide_position","AUC"];
ax(i).color         = {colors.tactile, colors.tactile2};
ax(i).lineStyle     = ["-","-"]; 
ax(i).yLabel        = ["PsyTrack bias","Encoding kernel (AUC)"];
i=i+1;

%Towers - GLM ---------
%Towers x Position coef
ax(i).title         = "Tower Side x Position";
ax(i).behVar        = "glm1_towers_beta"; 
ax(i).behVarSE      = "glm1_towers_se"; %or []
ax(i).encVar        = ["kernel","towerSide_position","AUC"];
ax(i).color         = {colors.visual, colors.visual2};
ax(i).lineStyle     = ["-","-"]; 
ax(i).yLabel        = ["GLM R-L coef.","Encoding kernel (AUC)"];
i=i+1;
%Bias
ax(i).title         = "Tower Side x Position";
ax(i).behVar        = "glm1_bias_beta"; %Towers
ax(i).behVarSE      = "glm1_bias_se"; %or []
ax(i).encVar        = ["kernel","towerSide_position","AUC"];
ax(i).color         = {colors.visual, colors.visual2};
ax(i).lineStyle     = ["-","-"]; 
ax(i).yLabel        = ["GLM bias coef.","Encoding kernel (AUC)"];
i=i+1;

%Puffs - GLM -------
%Puffs x Position coef
ax(i).title         = "Puff Side x Position";
ax(i).behVar        = "glm1_puffs_beta";
ax(i).behVarSE      = "glm1_puffs_se"; %or []
ax(i).encVar        = ["kernel","puffSide_position","AUC"];
ax(i).color         = {colors.tactile, colors.tactile2};
ax(i).lineStyle     = ["-","-"]; 
ax(i).yLabel        = ["GLM R-L coef.","Encoding kernel (AUC)"];
i=i+1;
%Bias
ax(i).title         = "Puff Side x Position";
ax(i).behVar        = "glm1_bias_beta"; %Towers
ax(i).behVarSE      = "glm1_bias_se"; %or []
ax(i).encVar        = ["kernel","puffSide_position","AUC"];
ax(i).color         = {colors.tactile, colors.tactile2};
ax(i).lineStyle     = ["-","-"]; 
ax(i).yLabel        = ["GLM bias coef.","Encoding kernel (AUC)"];
i=i+1;

% Cues vs behavioral bias
%Towers x Position coef vs. pLeftTowers
ax(i).title         = "Tower Side x Position";
ax(i).behVar        = "pLeftTowers"; 
ax(i).behVarSE      = []; %or []
ax(i).encVar        = ["kernel","towerSide_position","AUC"];
ax(i).color         = {colors.visual, colors.visual2};
ax(i).lineStyle     = ["-","-"]; 
ax(i).yLabel        = ["Proportion left tower trials","Encoding kernel (AUC)"];
i=i+1;
%Puffs x Position coef vs. pLeftTowers
ax(i).title         = "Tower Side x Position";
ax(i).behVar        = "pLeftPuffs"; 
ax(i).behVarSE      = []; %or []
ax(i).encVar        = ["kernel","towerSide_position","AUC"];
ax(i).color         = {colors.visual, colors.visual2};
ax(i).lineStyle     = ["-","-"]; 
ax(i).yLabel        = ["Proportion left tower trials","Encoding kernel (AUC)"];
i=i+1;

%------- Reward -----------------------------------------------------------
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