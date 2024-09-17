meanITI = 5; 
minITI = 3;
maxPrctile = 95;

ITI=[];
for i=1:10000
ITI(i) = expInterTrialInterval( meanITI, minITI, maxPrctile );
end


figure; histogram(ITI,1:15,'Normalization','probability');
ylim([0,0.5]);
ylabel('Proportion of trials')
xlabel('ITI(s)')
figure; histogram(3+rand(size(ITI))*10,1:15,'Normalization','probability');
ylim([0,0.5]);
ylabel('Proportion of trials')
xlabel('ITI(s)')


%%

std(rand(size(ITI))*20)
std(exprnd(10,size(ITI)))
