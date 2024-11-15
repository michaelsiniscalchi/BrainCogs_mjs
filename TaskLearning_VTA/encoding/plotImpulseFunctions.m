%First, load glm from session
resultsPath = "X:\michael\tactile2visual-vta\results\";
session = "230922-m105-maze7";
glm = load(fullfile(resultsPath, session,"encoding.mat"),"impulse");
img_beh = load(fullfile(resultsPath, session,"img_beh.mat"), "t");
figure;
plot(img_beh.t, glm.impulse.firstLeftPuff);
ylabel("Event occurence");
xlabel("Time (s)");
title("Impulse Function, First Left Puff");
axis square tight;
