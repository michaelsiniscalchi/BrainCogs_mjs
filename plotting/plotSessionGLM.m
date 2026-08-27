function p = plotSessionGLM( glmStruct, colors )

%Extract data
factors = glmStruct.predictors;
for i = 1:numel(factors)
    data(i) = glmStruct.(factors(i)).beta;
    sem(:,i) = glmStruct.(factors(i)).se(2); %Upper se bar
end

%Make bar graph 
bar(1:numel(factors),data,'FaceColor',colors.blue,'LineStyle','none'); hold on
errorbar(data, sem, 'Color', colors.blue, 'LineWidth', 1, 'LineStyle','none'); %symmetric error bars

%Stars for significance 
for i = 1:numel(factors)
    ticklabels(i) = factors(i);
    if glmStruct.(factors(i)).p<0.05
        ticklabels(i) = join([factors{i},"*"],'');
    end
end

%Title and Axis Labels
title('Logistic Regression');
ylabel('Regression Coef.');
ax = gca;
ax.XTickLabels = ticklabels;
xlim([0,numel(factors)+1]);

axis square tight;

