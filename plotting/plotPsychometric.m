function lgd = plotPsychometric(psychStruct, cueName, colors, title_str)

c.all = colors.black;
c.congruent = colors.gray;
c.conflict = colors.red;

c.data = colors.black;
c.model = colors.green;

f = string(fieldnames(psychStruct))';
if ~isempty(f)
    for i = 1:numel(f)
        %Plot p(right) as f(nCuesR-nCuesL)
        X = psychStruct.(f(i)).(cueName).counts;
        Y = psychStruct.(f(i)).(cueName).pRight;

        if isempty(X)
           p(i) = plot(NaN,NaN,"Color", c.(f(i))); hold on;
           continue
        end

        p(i) = plot(X,Y,'.',"LineStyle","none","MarkerSize",10,"Color", c.(f(i))); hold on;

        %Plot binned frequencies
        X = psychStruct.(f(i)).(cueName).bins;
        Y = psychStruct.(f(i)).(cueName).pRight_binned;
        err = psychStruct.(f(i)).(cueName).se_binned;

        %Plot line between values
        errorbar(X,Y,err,"LineWidth",1.5, "Color", c.(f(i))); hold on;

        %Horizontal line for each bin
        width = X(end) - X(end-1); %bin width
        for j = 1:numel(X)
            plot(X(j)+[-width/4, width/4], [Y(j), Y(j)],...
                "Marker", "none", "LineWidth", 1.5, "Color", c.(f(i))); hold on;
        end

        %Plot fit lines
        %         plot(psychStruct.(f(i)).(cueName).bins, psychStruct.(f(i)).(cueName).curvefit, "Color", c.(f(i)));

    end

    lgd = legend(p,f);

end

title(title_str);
xlabel('nRightCues-nLeftCues');
ylabel('P(chose right)');
axis square;