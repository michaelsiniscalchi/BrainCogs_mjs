%%% getTrialTrajectories()
% Find the trajectory in x or theta as a function of y-position in maze.
% Modified from original sampleViewAngleVsY.m (au:Sue Ann Koay) to handle x-position or view angle
% Michael Siniscalchi, PNI, 220503

function [time_mat, maxY, iter] = getTimebyPosition(trialData, eventTimes, ySample)

%Abbreviate
position = {trialData.position};
time = cellfun(@(t,st) t+st,{trialData.time},{eventTimes.logStart},'UniformOutput',false);

%Get times corresponding to input sample y-positions
maxY            = cellfun(@(pos) cummax(pos(:,2)), position, 'UniformOutput', false); %Take cumulative max
iter            = accumfun(2, @(x) binarySearch(x, ySample, 1, 1)', maxY);
time_mat        = accumfun(2, @(x) time{x}(iter(:,x)), 1:numel(position));

%Main method taken from sampleViewAngleVsY(), written by Sue Ann Koay
%   A couple issues with cummax(y) strategy for dealing with
%   trials where the mouse turns back:
%   (1) disjointed trajectories, and
%   (2) x-position output for arms of the maze is a little weird.