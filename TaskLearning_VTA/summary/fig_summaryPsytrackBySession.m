function fig = fig_summaryPsytrackBySession( psyStruct, session, subjectID, params )

setup_figprops('placeholder'); %Customize for performance plots
colors = setPlotColors('mjs_tactile2visual');

%% Plot Psytrack Coefficients as a function of Session Number
fig(1) = figure('Name', strjoin(["PsyTrack", subjectID],'-'));

%Domain, session date or session number
X = 1:numel(psyStruct.session_date);
% imgIdx = psyStruct.session_date behStruct.session_date);%Temporary

%Plot Psytrack Weights with SD (all sessions)
% Next, img sessions only
psyVar = ["bias","leftPuffs","rightPuffs","leftTowers","rightTowers"];
for i=1:numel(psyVar)
    sdHi = psyStruct.sd.(psyVar(i))(:,1);
    sdLo = psyStruct.sd.(psyVar(i))(:,2);
    errorshade(X, sdLo, sdHi, colors.(psyVar(i)), 0.1); hold on
    p(i) = plot(X, psyStruct.meanCoef.(psyVar(i)),"Color",colors.(psyVar(i)),'DisplayName',psyVar(i));
end

ruleNames = ["tactile","visual"];
ruleIdx = ([session.taskRule]=="visual")+1; %{tactile,visual}:={1,2}
switchIdx = [1, find(diff(ruleIdx))+1]; %First session in new rule
ruleSeq = ruleNames(ruleIdx(switchIdx));

switchX = switchIdx-0.5; %place dotted line before first session on new rule
for i=1:numel(ruleSeq)
h(i) = plot([switchX(i),switchX(i)],[min(ylim),max(ylim)],':','Color', colors.gray, 'LineWidth',1);
txtY = min(ylim)+0.05*range(ylim);
text(switchX(i)+0.01*range(xlim), txtY, ruleSeq(i),'HorizontalAlignment','left','Color',colors.taskRule.(ruleSeq(i)));
end
uistack(h,"bottom");
xlabel("Session number");
ylabel("PsyTrack coef.");
box off;

%Mark imaging sessions
imgIdx = find([session.isImgSession]);
symbolY = max(ylim)-0.1*diff(ylim);
for i=1:numel(imgIdx)
    plot(imgIdx(i),symbolY,'v',"Color",colors.gray,"MarkerSize",3);
end

%Legend
lgd = legend(p);
lgd.Location = 'eastoutside';

%Title
% title("PsyTrack Coefficients");

