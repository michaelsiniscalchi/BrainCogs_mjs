%Load encoding model and validation results
clearvars;

%Load data
results_path = fullfile('X:','michael','tactile2visual-vta','results');
sub_dir = '230922-m105-maze7';
encoding = load(fullfile(results_path,sub_dir,'encoding.mat'), 'model', 'kernel', 'cellID');
   
simulated = load(fullfile(results_path,sub_dir,'encoding_simulation.mat'), 'model', 'kernel');
t = encoding.kernel(1).start.t;

%Colors
colors = getFigColors();
colors.start = colors.purple;
[colors.leftTowers, colors.leftPuffs] = deal(colors.left);
[colors.rightTowers, colors.rightPuffs] = deal(colors.right);
colors.reward = colors.correct;
colors.noReward = colors.err;
%Plotting params
offset = 0.2; %offset for coef. plot


%% Plot response kernels and coefficients for all predictors

kernelNames = fieldnames(encoding.kernel(1));
predNames = ["(Intercept)","viewAngle","position","velocity","acceleration"];

for i = 1:numel(encoding.kernel)
    
    %Response kernels
    figs(i) = figure('Name',['cell',encoding.cellID{i}],'Position',[0,0,1400,700]);
    
    T = tiledlayout(2,4,'TileSpacing','compact');
    for j = 1:numel(kernelNames)
        nexttile();
        
        plot(t, encoding.kernel(i).(kernelNames{j}).estimate,...
            'Color',colors.(kernelNames{j}),'DisplayName','Imaging data'); hold on
        plot(t, simulated.kernel(i).(kernelNames{j}).estimate,'k:','DisplayName','Simulation');
        title([upper(kernelNames{j}(1)), kernelNames{j}(2:end)]);
        xlabel('Time (s)');
        ylabel('Norm. kernel magnitude');
        legend("Location","best");
        axis square
    end

    %Coefficient estimates
    nexttile();
    for j = 1:numel(predNames)
        errorbar(j, encoding.model{i}.Coefficients.Estimate(predNames{j}),...
            encoding.model{i}.Coefficients.SE(predNames{j}),...
            'LineWidth',2,'Color','k','DisplayName','Imaging'); 
        hold on
        errorbar(j+offset, simulated.model{i}.Coefficients.Estimate(predNames{j}),...
            simulated.model{i}.Coefficients.Estimate(predNames{j}),...
            'LineWidth',2,'Color','r','DisplayName','Simulation');
    end
    text(0.6,0.8,'Imaging','Color','k','Units','normalized');
    text(0.6,0.7,'Simulation','Color','r','Units','normalized');
    title('VR Coefficients');
    ylabel('Regression coefficient')
    xticks(1:numel(predNames));
    xticklabels(predNames);
    axis square
end

save_dir = ...
    (fullfile('X:','michael','tactile2visual-vta','figures',...
    'Encoding model','validation',sub_dir));
save_multiplePlots(figs,save_dir); %Save figure

%fitglm