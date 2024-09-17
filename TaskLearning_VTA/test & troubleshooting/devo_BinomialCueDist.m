clearvars;
meanNumCues = 8;
maxNumCues = 16;
pZeroCueTrials = 0.05;

%Find sigma of N(meanNumCues, sigma) where p(n<0) is equal to desired
%proportion of zero-cues trials
p = 0:0.01:1;
for i = 1:numel(p)
    pd = truncate(makedist('Binomial','N', maxNumCues,'p', p(i)), 0, maxNumCues);
    P0(i) = pdf(pd,0); %Evaluate PDF at 0
end
p = p(sum(P0>pZeroCueTrials)+1);

dist.norm = truncate(makedist('Binomial','N', maxNumCues,'p', p), 0, maxNumCues);
dist.pois = truncate(makedist('Poisson','lambda', meanNumCues), 0, maxNumCues);

%%
figure; 

subplot(1,2,1)
x = 0:maxNumCues;
plot(x, pdf(dist.norm, x),'b','LineWidth', 2, 'DisplayName', 'Normal'); hold on;
plot(x, pdf(dist.pois, x),'m','LineWidth', 2, 'DisplayName', 'Poisson');
plot(x,ones(size(x))*0.05,':k','LineWidth', 2);

axis square tight;
% xlabel("Total number of cues");
xlabel("Number of cues/m");
ylabel("Probability density");
title("Cue Freq. Distributions"); 
legend('Location','eastoutside');

subplot(1,2,2)
plot(x, cdf(dist.norm, x),'b','LineWidth', 2, 'DisplayName', 'Normal'); hold on;
plot(x, cdf(dist.pois, x),'m','LineWidth', 2, 'DisplayName', 'Poisson');
plot(x,ones(size(x))*0.05,':k','LineWidth', 2);

axis square tight;
% xlabel("Total number of cues");
xlabel("Number of cues/m");
ylabel("Cumulative density");
title("Cue Freq. CDFs");
legend('Location','eastoutside');

%%


