function params = specEncodingParams(params)

%Predictors for full/partial models
%Initialize
params.positionSpline = false;
params.initFcn_position = @nan; %ITI position

%Default B-spline parameters
%Position
bSpline.position.degree      = 3; %degree for position splines
bSpline.position.binWidth    = 1; %bin width in cm
bSpline.position.df          = 5; %number of terms for position splines

%Cues
bSpline.cue.degree      = 3; %degree of each (Bernstein polynomial) term
bSpline.cue.nSamples    = 60; %N time points for spline basis set;
bSpline.cue.df          = 6; %number of terms:= order + N internal knots

%Reward
bSpline.outcome.degree      = 3; %degree of each (Bernstein polynomial) term
bSpline.outcome.nSamples    = 150; %N time points for spline basis set; 
bSpline.outcome.df          = 15; %number of terms:= order + N internal knots
params.bSpline = bSpline;

switch params.modelName

    case 'FM'
        params.predictorNames = ["start",...
            "firstLeftPuff","firstRightPuff","firstLeftTower","firstRightTower",...
            "leftPuffs","rightPuffs","leftTowers","rightTowers",...
            "towerSide_position", "puffSide_position", "position",...
            "reward","noReward",...
            "heading","speed"];
        params.positionSpline = true;

    case 'FM_noAllCues'
        params.predictorNames = ["start",...
            "firstLeftPuff","firstRightPuff","firstLeftTower","firstRightTower",...
            "towerSide_position", "puffSide_position", "position",...
            "reward","noReward",...
            "heading","speed"];
        params.positionSpline = true;

    case 'FM_cueTypeXpos'
        params.predictorNames = ["start",...
            "firstLeftPuff","firstRightPuff","firstLeftTower","firstRightTower",...
            "leftPuffs_position","rightPuffs_position","leftTowers_position","rightTowers_position",...
            "reward","noReward",...
            "heading","speed"];
        params.positionSpline = true;

    %Minimal Models
    case 'only_position'
        params.predictorNames = "position";
        params.positionSpline = true; 

    case 'only_cues'
        params.predictorNames = [...
            "firstLeftPuff","firstRightPuff","firstLeftTower","firstRightTower",...
            "leftPuffs","rightPuffs","leftTowers","rightTowers",...
            ];
         
    case 'only_allCues'
        params.predictorNames = [...
            "leftPuffs","rightPuffs","leftTowers","rightTowers"...
            ];
    
    case 'only_firstCues'
        params.predictorNames = [
            "firstLeftPuff","firstRightPuff","firstLeftTower","firstRightTower"...
            ];
   
    case 'only_posXcueSide'
        params.predictorNames = [...
            "towerSide_position","puffSide_position"...
            ];
        params.positionSpline = true;
   
    case 'only_posXcueType'
        params.predictorNames = [...
            "leftPuffs_position","rightPuffs_position","leftTowers_position","rightTowers_position",...
            ];
        params.positionSpline = true;

    case 'posXcueSide_pos' %Minimal posXcueSide model with position term
        params.predictorNames = [...
            "towerSide_position","puffSide_position","position",...
            ];
        params.positionSpline = true;

end

%List variables by type
pNames = params.predictorNames;
varNames.eventVars = ["start",...
            "firstLeftPuff","firstRightPuff","firstLeftTower","firstRightTower",...
            "leftPuffs","rightPuffs","leftTowers","rightTowers",...
            "reward","noReward"];
varNames.positionVars = [...
    "position",...
    "towerSide_position","puffSide_position"...
    "leftPuffs_position","rightPuffs_position",...
    "leftTowers_position","rightTowers_position"];
varNames.indicatorVars = ["ITI","trialIdx","accuracy","priorOutcome"];
varNames.kinematicVars = ["heading","speed","velocity","acceleration"];

for f = string(fieldnames(varNames))'
    params.(f) = []; %Initialize
    if any(ismember(pNames, varNames.(f)))
        params.(f) = pNames(ismember(pNames,varNames.(f)));
    end
end

%Assign bSpline params to associated predictor types
% for f = ["position",...
%         "towerSide_position","puffSide_position"...
%         "leftPuffs_position","rightPuffs_position",...
%         "leftTowers_position","rightTowers_position"]
%     params.bSpline.(f) = bSpline.position;
% end
% for f = ["start",...
%             "firstLeftPuff","firstRightPuff","firstLeftTower","firstRightTower",...
%             "leftPuffs","rightPuffs","leftTowers","rightTowers"]
%         params.bSpline.(f) = bSpline.cues;
% end
% for f = ["reward", "noReward"]
%         params.bSpline.(f) = bSpline.outcome;
% end

%Subtypes (for referencing bSpline params)
params.cueVarNames = ["start",...
            "firstLeftPuff","firstRightPuff","firstLeftTower","firstRightTower",...
            "leftPuffs","rightPuffs","leftTowers","rightTowers"];
params.outcomeVarNames = ["reward","noReward"];
params.positionVarNames = ["position",...
        "towerSide_position","puffSide_position"...
        "leftPuffs_position","rightPuffs_position",...
        "leftTowers_position","rightTowers_position"];

% %Assign bSpline params to active predictors
% for f = pNames
%     if ismember(f, ["towerSide_position","puffSide_position"...
%             "leftPuffs_position","rightPuffs_position",...
%             "leftTowers_position","rightTowers_position"])
%         params.bSpline.(f) = bSpline.position;
%     elseif ismember(f, ["start",...
%             "firstLeftPuff","firstRightPuff","firstLeftTower","firstRightTower",...
%             "leftPuffs","rightPuffs","leftTowers","rightTowers"])
%         params.bSpline.(f) = bSpline.cues;
%     elseif ismember(f, ["reward", "noReward"])
%         params.bSpline.(f) = bSpline.outcome;
%     end
% end

