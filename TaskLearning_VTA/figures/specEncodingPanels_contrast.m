function ax = specEncodingPanels_contrast( params )

colors = params.all.colors;

%Specify struct 'ax' containing variables and plotting params for each figure panel:

i=1;

%Summary Figure for Encoding Model (glm coefficents)

%Start of trial
ax(i).title         = "Start Trial";
ax(i).varName       = "start";
ax(i).window        = [-1, 2];
ax(i).color         = {colors.data, colors.data2}; % {pred1,pred2,obs1,obs2}
ax(i).lineStyle     = ["-","-"]; % {pred1,pred2,obs1,obs2}
ax(i).xLabel        = 'Time from start (s)';
i=i+1;

%First Tower
ax(i).title         = "First Tower";
ax(i).varName       = ["firstLeftTower", "firstRightTower"];
ax(i).window        = [-1, 2];
ax(i).color         = {colors.left, colors.right}; 
ax(i).lineStyle     = ["-","-"]; 
ax(i).xLabel        = 'Time from cue (s)';
i=i+1;

%First Puff
ax(i).title         = "First Puff";
ax(i).varName       = ["firstLeftPuff", "firstRightPuff"];
ax(i).window        = [-1, 2];
ax(i).color         = {colors.left, colors.right}; 
ax(i).lineStyle     = ["-","-"]; 
ax(i).xLabel        = 'Time from cue (s)';
i=i+1;

%All Towers
ax(i).title         = "Towers";
ax(i).varName       = ["leftTowers", "rightTowers"];
ax(i).window        = [-1, 2];
ax(i).color         = {colors.left, colors.right}; 
ax(i).lineStyle     = ["-","-"]; 
ax(i).xLabel        = 'Time from cue (s)';
i=i+1;

% %All Puffs
ax(i).title         = "Puffs";
ax(i).varName       = ["leftPuffs", "rightPuffs"];
ax(i).window        = [-1, 2];
ax(i).color         = {colors.left, colors.right}; 
ax(i).lineStyle     = ["-","-"]; 
ax(i).xLabel        = 'Time from cue (s)';
i=i+1;
 
%Outcome
ax(i).title         = "Outcome";
ax(i).varName       = ["reward", "noReward"];
ax(i).window        = [-1, 5];
ax(i).color         = {colors.correct, colors.err}; 
ax(i).lineStyle     = ["-","-"]; 
ax(i).xLabel        = 'Time from outcome (s)';
i=i+1;

%Position x trialType Interactions
ax(i).title         = "Position x Puff Side";
ax(i).varName       = ["leftPuffs_position", "rightPuffs_position"];
ax(i).window        = [-30, 250];
ax(i).color         = {colors.left, colors.right}; 
ax(i).lineStyle     = ["-","-"]; 
ax(i).xLabel        = 'Position (cm)';
i=i+1;
ax(i).title         = "Position x Tower Side";
ax(i).varName       = ["leftTowers_position", "rightTowers_position"];
ax(i).window        = [-30, 250];
ax(i).color         = {colors.left, colors.right}; 
ax(i).lineStyle     = ["-","-"]; 
ax(i).xLabel        = 'Position (cm)';
i=i+1;
ax(i).title         = "Position x Left CueType";
ax(i).varName       = ["leftPuffs_position", "leftTowers_position"];
ax(i).window        = [-30, 250];
ax(i).color         = {colors.left, colors.left2}; 
ax(i).lineStyle     = ["-","-"]; 
ax(i).xLabel        = 'Position (cm)';
i=i+1;
ax(i).title         = "Position x Right CueType";
ax(i).varName       = ["rightPuffs_position", "rightTowers_position"];
ax(i).window        = [-30, 250];
ax(i).color         = {colors.right, colors.right2}; 
ax(i).lineStyle     = ["-","-"]; 
ax(i).xLabel        = 'Position (cm)';
i=i+1;

% ax(i).title         = "Position";
% ax(i).comparison    = "position";
% ax(i).trigger       = "cueRegion";
% ax(i).trialType     = "forward";
% ax(i).varName       = ["position"];
% ax(i).window        = [-30, 250];
% ax(i).color         = {colors.data}; 
% ax(i).lineStyle     = ["-"]; 
% ax(i).xLabel        = 'Position (cm)';
% i=i+1;

% %Left vs. Right Choice
% %Explore whether this should be a whole-trial variable, or a regression
% %spline from start or turn
% ax(i).title         = "Left Choice";
% ax(i).comparison    = "choice";
% ax(i).trigger       = "turnEntry";
% ax(i).trialType     = "left";
% ax(i).varName       = "leftChoice";
% ax(i).window        = [-1, 3];
% ax(i).color         = {colors.data2,colors.left}; 
% ax(i).lineStyle     = ["-","-"]; % {pred1,pred2,obs1,obs2}
% ax(i).xLabel        = 'Time from turn (s)';
% i=i+1;
% 
% ax(i).title         = "Right Choice";
% ax(i).comparison    = "choice";
% ax(i).trigger       = "turnEntry";
% ax(i).trialType     = "right";
% ax(i).varName       = "rightChoice";
% ax(i).window        = [-1, 3];
% ax(i).color         = {colors.data2,colors.right}; 
% ax(i).lineStyle     = ["-","-"]; % {pred1,pred2,obs1,obs2}
% ax(i).xLabel        = 'Time from turn (s)';
% i=i+1;
% 
% %Outcome
% ax(i).title         = "Reward";
% ax(i).comparison    = "outcome";
% ax(i).trigger       = "outcome";
% ax(i).trialType      = "correct";
% ax(i).varName       = "reward";
% ax(i).window        = [-1, 3];
% ax(i).color         = {colors.data2,colors.correct}; 
% ax(i).lineStyle     = ["-","-"]; 
% ax(i).xLabel        = 'Time from outcome (s)';
% i=i+1;
% ax(i).title         = "No Reward";
% ax(i).comparison    = "outcome";
% ax(i).trigger       = "outcome";
% ax(i).trialType       = "error";
% ax(i).varName       = "noReward";
% ax(i).window        = [-1, 3];
% ax(i).color         = {colors.data2,colors.err}; 
% ax(i).lineStyle     = ["-","-"]; 
% ax(i).xLabel        = 'Time from outcome (s)';
% i=i+1;
% 
% %Cue Region, split by cue-type
% ax(i).title         = "Left Puffs";
% ax(i).comparison    = "cueRegion-cueType";
% ax(i).trigger       = "cueRegion";
% ax(i).trialType     = "leftPuffs";
% ax(i).varName       = []; %Empty if non-event
% ax(i).window        = [-50, 300];
% ax(i).color         = {colors.data2,colors.left}; 
% ax(i).lineStyle     = ["-","-"]; 
% ax(i).xLabel        = 'Position (cm)';
% i=i+1;
% ax(i).title         = "Right Puffs";
% ax(i).comparison    = "cueRegion-cueType";
% ax(i).trigger       = "cueRegion";
% ax(i).trialType     = "rightPuffs";
% ax(i).varName       = []; %Empty if non-event
% ax(i).window        = [-50, 300];
% ax(i).color         = {colors.data2,colors.right}; 
% ax(i).lineStyle     = ["-","-"]; 
% ax(i).xLabel        = 'Position (cm)';
% i=i+1;
% ax(i).title         = "Left Towers";
% ax(i).comparison    = "cueRegion-cueType";
% ax(i).trigger       = "cueRegion";
% ax(i).trialType     = "leftTowers";
% ax(i).varName       = []; %Empty if non-event
% ax(i).window        = [-50, 300];
% ax(i).color         = {colors.data2,colors.left}; 
% ax(i).lineStyle     = ["-","-"]; 
% ax(i).xLabel        = 'Position (cm)';
% i=i+1;
% ax(i).title         = "Right Towers";
% ax(i).comparison    = "cueRegion-cueType";
% ax(i).trigger       = "cueRegion";
% ax(i).trialType     = "rightTowers";
% ax(i).varName       = []; %Empty if non-event
% ax(i).window        = [-50, 300];
% ax(i).color         = {colors.data2,colors.right}; 
% ax(i).lineStyle     = ["-","-"]; 
% ax(i).xLabel        = 'Position (cm)';
% i=i+1;
% 
% %Cue Region, split by outcome
% ax(i).title         = "Rewarded";
% ax(i).comparison    = "cueRegion-outcome";
% ax(i).trigger       = "cueRegion";
% ax(i).trialType     = "correct";
% ax(i).varName       = []; %Empty if non-event
% ax(i).window        = [-50, 300];
% ax(i).color         = {colors.data2,colors.correct}; 
% ax(i).lineStyle     = ["-","-"]; 
% ax(i).xLabel        = 'Position (cm)';
% i=i+1;
% ax(i).title         = "Error";
% ax(i).comparison    = "cueRegion-outcome";
% ax(i).trigger       = "cueRegion";
% ax(i).trialType     = "error";
% ax(i).varName       = []; %Empty if non-event
% ax(i).window        = [-50, 300];
% ax(i).color         = {colors.data2,colors.err}; 
% ax(i).lineStyle     = ["-","-"]; 
% ax(i).xLabel        = 'Position (cm)';
% i=i+1;
% ax(i).title         = "Prior Reward";
% ax(i).comparison    = "cueRegion-outcome";
% ax(i).trigger       = "cueRegion";
% ax(i).trialType     = "priorCorrect";
% ax(i).varName       = []; %Empty if non-event
% ax(i).window        = [-50, 300];
% ax(i).color         = {colors.data2,colors.correct}; 
% ax(i).lineStyle     = ["-","-"]; 
% ax(i).xLabel        = 'Position (cm)';
% i=i+1;
% ax(i).title         = "Prior Error";
% ax(i).comparison    = "cueRegion-outcome";
% ax(i).trigger       = "cueRegion";
% ax(i).trialType     = "priorError";
% ax(i).varName       = []; %Empty if non-event
% ax(i).window        = [-50, 300];
% ax(i).color         = {colors.data2,colors.err}; 
% ax(i).lineStyle     = ["-","-"]; 
% ax(i).xLabel        = 'Position (cm)';
% i=i+1;
% 
% %Cue Region, split by Choice
% ax(i).title         = "Left Choice";
% ax(i).comparison    = "cueRegion-choice";
% ax(i).trigger       = "cueRegion";
% ax(i).trialType     = "left";
% ax(i).varName       = []; %Empty if non-event
% ax(i).window        = [-50, 300];
% ax(i).color         = {colors.data2,colors.left}; 
% ax(i).lineStyle     = ["-","-"]; 
% ax(i).xLabel        = 'Position (cm)';
% i=i+1;
% ax(i).title         = "Right Choice";
% ax(i).comparison    = "cueRegion-choice";
% ax(i).trigger       = "cueRegion";
% ax(i).trialType     = "right";
% ax(i).varName       = []; %Empty if non-event
% ax(i).window        = [-50, 300];
% ax(i).color         = {colors.data2,colors.right}; 
% ax(i).lineStyle     = ["-","-"]; 
% ax(i).xLabel        = 'Position (cm)';
% i=i+1;
% ax(i).title         = "Prior Left Choice";
% ax(i).comparison    = "cueRegion-choice";
% ax(i).trigger       = "cueRegion";
% ax(i).trialType     = "priorLeft";
% ax(i).varName       = []; %Empty if non-event
% ax(i).window        = [-50, 300];
% ax(i).color         = {colors.data2,colors.left}; 
% ax(i).lineStyle     = ["-","-"]; 
% ax(i).xLabel        = 'Position (cm)';
% i=i+1;
% ax(i).title         = "Prior Right Choice";
% ax(i).comparison    = "cueRegion-choice";
% ax(i).trigger       = "cueRegion";
% ax(i).trialType     = "priorRight";
% ax(i).varName       = []; %Empty if non-event
% ax(i).window        = [-50, 300];
% ax(i).color         = {colors.data2,colors.right}; 
% ax(i).lineStyle     = ["-","-"]; 
% ax(i).xLabel        = 'Position (cm)';
% i=i+1;

[ax(:).yLabel]          = deal('Cellular Fluorescence (dF/F)');