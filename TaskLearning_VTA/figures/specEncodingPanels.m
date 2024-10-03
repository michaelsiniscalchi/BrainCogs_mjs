function ax = specEncodingPanels( params )

colors = params.all.colors;

%Specify struct 'ax' containing variables and plotting params for each figure panel:

i=1;

%Summary Figure for Encoding Model (glm coefficents)
ax(i).title         = "Start Trial";
ax(i).varName       = "start";
ax(i).color         = {colors.data}; %Choice: left/hit/sound vs right/hit/sound
ax(i).lineStyle     = ["-","-"]; 
i=i+1;
ax(i).title         = "Tower Onset";
ax(i).varName       = ["leftTowers", "rightTowers"];
ax(i).color         = {colors.left,colors.right}; 
ax(i).lineStyle     = ["-","-"]; 
i=i+1;
ax(i).title         = "Puff Onset";
ax(i).varName       = ["leftPuffs", "rightPuffs"];
ax(i).color         = {colors.left,colors.right}; 
ax(i).lineStyle     = ["-","-"]; 
i=i+1;
ax(i).title         = "Outcome Onset";
ax(i).varName       = ["reward", "noReward"];
ax(i).color         = {colors.correct,colors.err}; 
ax(i).lineStyle     = ["-","-"]; 
i=i+1;
