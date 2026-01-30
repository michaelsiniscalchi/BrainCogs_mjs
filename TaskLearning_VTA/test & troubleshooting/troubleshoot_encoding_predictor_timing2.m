figure;
E = "outcome";
event_times = [eventTimes.(E)];
plot(t, predictors.ITI,"LineWidth",2); hold on;
for i=1:numel(event_times)
    plot([event_times(i), event_times(i)], ylim);
end
xlabel("Time (s)")
