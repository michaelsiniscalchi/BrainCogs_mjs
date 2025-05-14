function p = plotSessionGLM( session_struct, glmName, colors )

%Abbreviate
S = session_struct;

%Extract data
factors = S.(glmName).predictors;
for i = 1:numel(factors)
    data(i) = S.(glmName).(factors(i)).beta;
    sem(:,i) = S.(glmName).(factors(i)).se(2); %Upper se bar
end

%Make bar graph 
bar(1:numel(factors),data,'FaceColor',colors.blue,'LineStyle','none'); hold on
errorbar(data, sem, 'Color', colors.blue, 'LineWidth', 1, 'LineStyle','none'); %symmetric error bars
% ylim([-4,4]);
% if string(glmName)=="glm1"
%     ylim([-1.5,1.5]);
% end

%Title and Axis Labels
title('Logistic Regression');
ylabel('Regression Coef.');
ax = gca;
ax.XTickLabels = factors;
xlim([0,numel(factors)+1]);

axis square tight;

