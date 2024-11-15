 
%First, load glm from session
resultsPath = "X:\michael\tactile2visual-vta\results\";
session = "230922-m105-maze7";
glm = load(fullfile(resultsPath,session,"encoding.mat"),"bSpline","kernel");
t = glm.kernel(1).reward.t; %proxy for all

figure;
plot(t, glm.bSpline);
 ylabel("Value (au)");
 xlabel("Time (s)");
 title("Basis Functions");
 axis square tight;
