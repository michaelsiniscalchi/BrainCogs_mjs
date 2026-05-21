function ax = specBootAvgPanels_plt( params )

% switch figID
%     case 'bootAvg_choice'
%     case 'bootAvg_cue'
%     case 'bootAvg_outcome'
% end

colors = params.all.colors;

%Specify struct 'ax' containing variables and plotting params for each figure panel:

i=1;

%---CUE RESPONSES----------------------------------------------------------
ax(i).title      = 'Cue Side (Puffs)';
ax(i).comparison   = 'cue-side';
ax(i).trigger    = "firstCue";
ax(i).trialType  = ["leftPuffs", "rightPuffs"];
ax(i).window     = [-inf, inf];
ax(i).color      = {colors.left, colors.right}; 
ax(i).lineStyle  = {'-','-'};
ax(i).xLabel = 'Time from first cue (s)';  % XLabel
i=i+1;
ax(i).title      = 'Cue Side (Towers)';
ax(i).comparison   = 'cue-side';
ax(i).trigger    = "firstCue";
ax(i).trialType  = ["leftTowers", "rightTowers"];
ax(i).window     = [-inf, inf];
ax(i).color      = {colors.left, colors.right}; 
ax(i).lineStyle  = {'-','-'};
ax(i).xLabel = 'Time from first cue (s)';  % XLabel
i=i+1;

ax(i).title      = 'Cue Modality';
ax(i).comparison   = 'cue-modality-side';
ax(i).trigger       = "firstCue";
ax(i).trialType     = ["visualCS", "tactileCS"];
ax(i).window        = [-inf, inf];
ax(i).color         = {colors.visual, colors.tactile}; %Choice: left/hit/sound vs right/hit/sound
ax(i).lineStyle  = {'-','-'};
ax(i).xLabel = 'Time from first cue (s)';  % XLabel
i=i+1;
ax(i).title      = 'Cue Modality';
ax(i).comparison   = 'cue-modality-side';
ax(i).trigger       = "firstCue";
ax(i).trialType     = ["leftCS", "rightCS"];
ax(i).window        = [-inf, inf];
ax(i).color         = {colors.left, colors.right}; %Choice: left/hit/sound vs right/hit/sound
ax(i).lineStyle  = {'-','-'};
ax(i).xLabel = 'Time from first cue (s)';  % XLabel
i=i+1;



%%---OUTCOME RESPONSES-----------------------------------------------------
ax(i).title         = 'Outcome Responses';
ax(i).comparison    = "outcome";
ax(i).trigger       = "outcome";
ax(i).trialType     = ["rewarded", "unrewarded"];
ax(i).window        = [-1, 5];
ax(i).color         = {colors.green, colors.pink}; %Outcome: hit/priorHit vs err/priorHit
ax(i).lineStyle     = {'-','-'};
ax(i).xLabel        = 'Time from outcome (s)';  % XLabel
i=i+1;
ax(i).title         = 'Rewarded, by Cue Side';
ax(i).comparison    = "outcome";
ax(i).trigger       = "outcome";
ax(i).trialType     = ["leftCS_rewarded", "rightCS_rewarded"];
ax(i).window        = [-1, 5];
ax(i).color         = {colors.left, colors.right}; %Outcome: hit/priorHit vs err/priorHit
ax(i).lineStyle     = {'-','-'};
ax(i).xLabel        = 'Time from outcome (s)';  % XLabel
i=i+1;
ax(i).title         = 'Unrewarded, by Cue Side';
ax(i).comparison    = "outcome";
ax(i).trigger       = "outcome";
ax(i).trialType     = ["leftCS_unrewarded", "rightCS_unrewarded"];
ax(i).window        = [-1, 5];
ax(i).color         = {colors.left2, colors.right2}; %Outcome: hit/priorHit vs err/priorHit
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

%--- Cue Entry RESPONSES---------------------------------------------------
ax(i).title         = 'Cue Entry';
ax(i).comparison    = "cue-entry";
ax(i).trigger       = "cueEntry";
ax(i).trialType     = "forward";
ax(i).window        = [-1, 5];
ax(i).color         = {colors.data}; %Outcome: hit/priorHit vs err/priorHit
ax(i).lineStyle     = {'-','-'};
ax(i).xLabel        = 'Time from entry (s)';  % XLabel
i=i+1;



[ax(:).yLabel]          = deal('Cellular Fluorescence (dF/F)');
[ax(:).verboseLegend]   = deal(false);