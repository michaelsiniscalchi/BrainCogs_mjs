% AnalysisNotebook_neuroBehCorr

subjectID = "m913";
nbCorr = load(mat_file.summary.neuroBehCorr(subjectID),'cells');
psy = load(mat_file.summary.psyTrack(subjectID));
load(mat_file.summary.behavior(subjectID),'sessions');
load(mat_file.summary.encoding(subjectID),'cells');

params.psyField = ["leftTowers","rightTowers","leftPuffs","rightPuffs"];
params.imgField = ...
        ["firstLeftTower", "firstRightTower", "firstLeftPuff", "firstRightPuff",...
        "leftTowers","rightTowers","leftPuffs","rightPuffs"];

params.minNumSessions = 5;

    
    
    
    %% Histogram of correlation coefficients between each pair of neurobehavioral predictors

figure('Name',strjoin([subjectID,'histogram','meanCoef_L2','R'],'-'));
T = tiledlayout(numel(params.psyField), numel(params.imgField),...
    'Padding','tight','TileSpacing','tight');
i=1; %panel counter
for f = params.psyField
    for ff = params.imgField
        nexttile() 
        data = nbCorr.meanCoef_L2.(f).(ff);
        idx = data.N>=params.minN;
        med = median(data.R(idx));
        h(i) = histogram(data.R(idx),-1:0.2:1); hold on
        plot([med,med],[0,sum(idx)],'m');
        if f==params.psyField(end)
            xlabel('Pearson"s R')
        end
        if ff==params.imgField(1)
            title({...
                strjoin(['PsyTrack',f],' ');...

                strjoin(['vs.',ff,'kernel','L2'],' ')...
                });
            ylabel('Number of neurons')
        else
             title(strjoin(['vs.',ff],' '));
        end
        i=i+1;
    end
end
maxVal = max([h.Values]);
for i=1:numel(T.Children)
T.Children(i).YLim = [0,maxVal];
end

%%
figure('Name',strjoin([subjectID,'histogram','meanCoef_L2','rho'],'-'));
T = tiledlayout(numel(params.psyField), numel(params.imgField),...
    'Padding','tight','TileSpacing','tight');
i=1; %panel counter
for f = params.psyField
    for ff = params.imgField
        nexttile() 
        data = nbCorr.meanCoef_L2.(f).(ff);
        idx = data.N>=params.minN;
        med = median(data.rho(idx));
        h(i) = histogram(data.rho(idx),-1:0.2:1); hold on
        plot([med,med],[0,sum(idx)],'m');
        if f==params.psyField(end)
            xlabel('Spearman"s rho')
        end
        if ff==params.imgField(1)
            title({...
                strjoin(['PsyTrack',f],' ');...

                strjoin(['vs.',ff,'kernel','L2'],' ')...
                });
            ylabel('Number of neurons')
        else
             title(strjoin(['vs.',ff],' '));
        end
        i=i+1;
    end
end
maxVal = max([h.Values]);
for i=1:numel(T.Children)
T.Children(i).YLim = [0,maxVal];
end

% LL = nbCorr.meanCoef_L2.leftTowers.firstLeftTower.R;
% LR = nbCorr.meanCoef_L2.leftTowers.firstRightTower.R;
% RR = nbCorr.meanCoef_L2.rightTowers.firstRightTower.R;
% RL = nbCorr.meanCoef_L2.rightTowers.firstLeftTower.R;
% N = nbCorr.meanCoef_L2.rightTowers.firstLeftTower.N;
% [LL,LR,RR,RL,N];