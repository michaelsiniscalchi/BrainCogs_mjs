clearvars;

%Breakpoint in virmen
vr.state


vr.iterFcn(vr.logger.iterationStamp(vr))

vr.state
iOutcome = vr.logger.currentTrial.iOutcome;


disp(newline);
disp(newline);
disp('---Breakpoint at outcome---'); disp(newline);
disp(['iOutcome:', num2str(vr.logger.currentTrial.iOutcome)]); disp(newline);
disp(['Current iteration:', num2str(vr.logger.currentIt)]); disp(newline);
disp('vr.logger.currentTrial.time(iOutcome:iOutcome+1):'); disp(newline);
disp(vr.logger.currentTrial.time(vr.iOutcome:vr.iOutcome+1));

disp(newline);
disp(newline);
disp('---Breakpoint at iOutcome+1---'); disp(newline);
disp(['iOutcome:', num2str(vr.logger.currentTrial.iOutcome)]); disp(newline);
disp(['Current iteration:', num2str(vr.logger.currentIt)]); disp(newline);
disp('vr.logger.currentTrial.time(iOutcome:iOutcome+1):'); disp(newline);
disp(vr.logger.currentTrial.time(vr.iOutcome:vr.iOutcome+1));


startTime = vr.logger.currentTrial.start;
outcomeTime = vr.logger.currentTrial.time(iOutcome);
disp(newline);
disp('---Breakpoint at iOutcome---'); disp(newline);
disp(['vr.timeElapsed: ' num2str(vr.timeElapsed)]);
disp(['time(iOutcome) + trial.start: ' num2str(startTime+outcomeTime)]);


t = vr.logger.currentTrial.time;
nIter = vr.logger.currentTrial.iterations;

vr.cueOnset

figure; 
plot(diff(t(1:nIter-1)))

%Logfile
load('D:\task-learning\data\sbolkan_test\mjs_tactile2visual_T2Vtest_VRTrain5_sbolkan_test_T_20251124_0.mat');

blk=3;
i=1;
iOutcome = log.block(blk).trial(i).iOutcome;
disp(iOutcome);
disp(log.block(blk).trial(i).time(iOutcome:iOutcome+3));


t = log.block(blk).trial(i).time;
figure; plot(diff(t));

