function p = plotSessionGLM( session_struct, glmName, colors )

%Abbreviate
S = session_struct;

%Extract data
factors = S.(glmName).predictors;
for i = 1:numel(factors)
    data(i) = S.(glmName).(factors(i)).beta;
    sem(:,i) = S.(glmName).(factors(i)).se;
end

%Make bar graph 
bar(1:numel(factors),data,'FaceColor',colors.blue,'LineStyle','none'); hold on
errorbar(data,sem-data,'Color',colors.blue,'LineWidth',1,'LineStyle','none');
ylim([-3,3]);

%Title and Axis Labels
title('Logistic Regression');
ylabel('Regression Coef.');
ax = gca;
ax.XTickLabels = factors;

axis square;

