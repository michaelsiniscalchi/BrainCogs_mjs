%%% fig_populationNeuroBehCorr()
%
% PURPOSE:  To plot a histogram of correlation coefficients between behavioral metrics (psytrack coefs, performance variables, etc.)    
%                  and neural estimates/measures (temporal kernel AUC, encoding coefs, etc.)
%
% AUTHORS: MJ Siniscalchi 260105
%
% INPUT ARGS:
%
%--------------------------------------------------------------------------

function fig = fig_populationNeuroBehCorr( meanCoef_AUC, panelSpec, params )

% Set up figure properties and restrict number of cells, if desired
setup_figprops('')  %set up default figure plotting parameters
lineWidth = 1;

% Initialize figures
fig_pos = [100,400,500,500]; %LBWH
legend_loc = 'bestoutside'; %'bestoutside';'layout'

% Restrict to cells with minimal number of sessions
neuroName = panelSpec.encVar(2);
idx = meanCoef_AUC.(panelSpec.behVar).(neuroName).N >= params.minNumSessions;
coefs = meanCoef_AUC.(panelSpec.behVar).(neuroName).rho(idx); %Correlation coefficients
med = median(coefs);

%Abbreviate psytrack variable
behName = panelSpec.behVar;
idx = regexp(behName,'(_)');
if ~isempty(idx) && ~isempty(regexp(behName,'(psyTrack)','once'))
    behName = ['psy', upper(behName{1}(idx(1)+1)), behName{1}(idx(1)+2:idx(end)-1)]; %truncate prefix 'psyTrack' and lose suffix 'meanCoef'
end

%Generate Histogram
fig = figure("Name",strjoin(["Rho", panelSpec.encVar(2), behName],'-'),"Position",fig_pos);
h = histogram(coefs, 10,...
    "LineWidth", lineWidth, "FaceColor", panelSpec.color{2}, "EdgeColor",panelSpec.color{1}); 
hold on

ylims = [0, 1.1*max(h.Values)];
plot([med,med], ylims,'-m',"LineWidth",lineWidth);
title(strjoin([neuroName 'vs.' behName]),'Interpreter','none');
xlabel("Correlation coef. (Spearman's rho)");
ylabel("Number of cells");
ylim(ylims);
axis square;
