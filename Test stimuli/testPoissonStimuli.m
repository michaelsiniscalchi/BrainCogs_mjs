clear all;
addGitRepo('TankMouseVR','U19-pipeline-matlab');
startup_no_datajoint;

saveDir = fullfile('C:','Users','mjs20','Documents','Witten Lab','ViRMEn');

stim.poisson = generatePoissonStimuli('poisson_blocks_reboot_3m_PuffAndTower_mjsTest.mat', @PoissonBlocksCondensed3m);
stim.bugfix = generatePoissonStimuli('poisson_blocks_reboot_3m_PuffAndTower_mjsTest.mat', @PoissonBlocksCondensed3m_mjsTest1);
%stim.uniform = generateUniformStimuli('poisson_blocks_reboot_3m_PuffAndTower_mjsTest.mat', @PoissonBlocksCondensed3m_mjsTest2);


%%
mazeID = 10;

for dist = string(fieldnames(stim))'
    for i = 1:size(stim.(dist).perSession, 2)
        positions.(dist){i} = [stim.(dist).perSession(mazeID,i).cuePos{1}]; %Consider only the "salient" towers (non-distractor)
        intervals.(dist){i} = diff(sort([stim.(dist).perSession(mazeID,i).cuePos{1}]));
        nCues.(dist)(i) = numel([stim.(dist).perSession(mazeID,i).cuePos{1}]); %Total number of cues
    end
    allPositions.(dist) = [positions.(dist){:}];
    allIntervals.(dist) = [intervals.(dist){:}];
    %Get theoretical mu for exponential distribution
    cfg = stim.(dist).config(mazeID);
    effectiveLength = cfg.lCue - cfg.cueVisAt - (cfg.meanSalient * cfg.minCueSep); %Length of cue segment available for randomization, after neglecting offsets
    mu = effectiveLength/(cfg.meanSalient-1);
    pd.(dist) = truncate(makedist('Exponential','mu',mu), 0, effectiveLength); %Truncated at "effective length," 

end

dist = string(fieldnames(stim));
distStr = struct('poisson',"(Poisson)",'bugfix',"(BugFix)",'uniform',"(Constant)");

for i = 1:numel(dist)
    figs(i) = figure('Position',[100 100 1000 400],'Name',join(['Tower Position','- maze', num2str(mazeID), dist(i)]));
    
    subplot(1,4,1)     %Histogram of intervals between towers
    h = histogram(allIntervals.(dist(i)),'Normalization','probability'); hold on;
    %Plot minimum separation value
    cfg = stim.(dist(i)).config(mazeID);
    plot([1,1]*cfg.minCueSep,[0,max(ylim)],':r','LineWidth',1);
    %Plot PDF for exp(mu==cfg.meanSalient)
    X = pd.(dist(i)).Truncation(1):pd.(dist(i)).Truncation(2);
    Y = pdf(pd.(dist(i)), X) * h.BinWidth; %Predicted distribution of inter-cue intervals across "effective length"
    p = plot(X+cfg.minCueSep, Y); %Offset X by cfg.minCueSep
    %Annotate
    ylabel("Proportion of Intervals")
    xlabel("Inter-cue interval (cm)")
    text(0.9,0.5,{'Y = pdf(Exp), with mu=='; [num2str(pd.(dist(i)).mu+cfg.minCueSep, 3) 'cm']},...
        'FontSize',6,'Color',p.Color,'Units','normalized','HorizontalAlignment','right');
    title("Inter-Tower Intervals");
    %Xlim
    xlim([0,h.BinLimits(2)]);

    subplot(1,4,2)
    histogram(allPositions.(dist(i)),(0:10:200),'Normalization','probability');
    title("Tower Positions");
    ylabel("Proportion of Towers")
    xlabel("Position (cm)");

    ax(3) = subplot(1,4,3);
    histogram(nCues.(dist(i)));
    title(["Cues Per Trial"  distStr.(dist(i))]);
    ylabel("Number of trials")
    xlabel("Number of cues")

    ax(4) = subplot(1,4,4);
    T = table(...
        [{'MazeID'};fieldnames(stim.(dist(i)).config(mazeID))],...
        [{mazeID};struct2cell(stim.(dist(i)).config(mazeID))],...
        'VariableNames',["Parameter","Value"]);

    uitable('Data',T{:,:},'ColumnName',T.Properties.VariableNames,...
        'RowName',T.Properties.RowNames,'Units', 'Normalized', 'Position',...
        [ax(4).Position(1:2),ax(3).Position(3:4)]); % set table on top
    delete(ax(4)); %No axis for uitable
end

save_multiplePlots(figs,saveDir);
