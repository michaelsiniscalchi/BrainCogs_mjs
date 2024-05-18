function ax = plotPsychometric(psychStruct, cueName, color, title_str)

%DEVO-------------
cueName = "puffs";
c = setPlotColors('mjs_tactile2visual');
color = c.series(1,:);

figure;
setup_figprops('placeholder');
tiledlayout(1,1)
ax = nexttile;
%-----------------

X = psychStruct.(cueName).diff;
Y = psychStruct.(cueName).pRight;
plot(X,Y,'o',"LineStyle","none","Color",color)

title(title_str);
xlabel('nRightCues-nLeftCues');
ylabel('P(chose right)');

axis square;