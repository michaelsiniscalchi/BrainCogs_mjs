function ax = spec_behEncodingPanels( colors )

%Specify struct 'ax' containing variables and plotting params for each figure panel:

i=1;

%Summary Figure for PsyTrack vs. Encoding Model Across Sessions

%Left Towers
ax(i).title         = "Left Towers";
ax(i).behVar        = "psyTrack_leftTowers_meanCoef";
ax(i).behVarSE      = "psyTrack_leftTowers_se"; %or []
ax(i).encVar        = ["kernel","firstLeftTower","AUC"];
ax(i).color         = {colors.left, colors.left2};
ax(i).lineStyle     = ["-","-"]; 
ax(i).yLabel        = ["PsyTrack weight","Encoding kernel (L2 norm)"];
i=i+1;

%Right Towers
ax(i).title         = "Right Towers";
ax(i).behVar        = "psyTrack_rightTowers_meanCoef";
ax(i).behVarSE      = "psyTrack_rightTowers_se"; %or []
ax(i).encVar        = ["kernel","firstRightTower","AUC"];
ax(i).color         = {colors.right, colors.right2};
ax(i).lineStyle     = ["-","-"]; 
ax(i).yLabel        = ["PsyTrack weight","Encoding kernel (L2 norm)"];
i=i+1;

%Left Puffs
ax(i).title         = "Left Puffs";
ax(i).behVar        = "psyTrack_leftPuffs_meanCoef";
ax(i).behVarSE      = "psyTrack_leftPuffs_se"; %or []
ax(i).encVar        = ["kernel","firstLeftPuff","AUC"];
ax(i).color         = {colors.left, colors.left2};
ax(i).lineStyle     = ["-","-"]; 
ax(i).yLabel        = ["PsyTrack weight","Encoding kernel (L2 norm)"];
i=i+1;

%Right Puffs
ax(i).title         = "Right Puffs";
ax(i).behVar        = "psyTrack_rightPuffs_meanCoef";
ax(i).behVarSE      = "psyTrack_rightPuffs_se"; %or []
ax(i).encVar        = ["kernel","firstRightPuff","AUC"];
ax(i).color         = {colors.right, colors.right2};
ax(i).lineStyle     = ["-","-"]; 
ax(i).yLabel        = ["PsyTrack weight","Encoding kernel (L2 norm)"];
i=i+1;

[ax(:).xLabel]          = deal('Imaging Sessions');