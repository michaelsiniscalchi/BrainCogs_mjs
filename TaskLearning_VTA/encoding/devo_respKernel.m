Analyze_Tactile2Visual_VTA('230922');
%%
for varName = eventNames
    if size(predictors.(varName),2)>1
        kernel.(varName) = bSpline*mdl.Coefficients.Estimate(idx.(varName)); %Make sure that mat product is what we want!
    end
end

for i=1:numel(glm.kernel)
figure; plot(glm.kernel(i).leftPuffs.estimate)
end