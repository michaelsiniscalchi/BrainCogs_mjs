%% align2Position()
%
% PURPOSE: To align cellular fluorescence to a specified behavioral/physiological
%               event repeated within an imaging session.
%
% AUTHOR: MJ Siniscalchi, 190910
%
% INPUT ARGS:
%           struct 'cells', containing fields 'dFF' and 't'.
%
% OUTPUTS:
%           'aligned, struct containing fields:
%                   -'(params.trigTimes).dFF', a cell array (nCells x 1) containing aligned
%                       cellular fluorescence as a matrix (nTriggers x nTimepoints).
%           'position', a vector representing time relative to the specified event.
%
%--------------------------------------------------------------------------

function [ aligned, position ] = alignFluoByPosition( cells, trialData, params )

% Center position reference within bins
position = trialData.positionRange(:) + 0.5*params.binWidth.*[1;-1]; %Full length of maze 
position = position(1):params.binWidth:position(2);

% Distribute dFF into bins according to Y-position
dFF = cell2mat(cells.dFF');
t = cells.t; %Abbreviate

timeIdx = 1:params.binWidth:diff(trialData.positionRange(:))+1; %Downsample positional edges
trialTimes = trialData.time_trajectory(timeIdx,:)'; %transpose-->Trials x Position-bin (cm)

aligned = NaN(size(trialTimes,1), size(trialTimes,2)-1, numel(cells.dFF));
for i = 1:size(trialTimes,1)
    binIdx = discretize(t, trialTimes(i,:));
    for j = unique(binIdx(~isnan(binIdx)))' %Loop through each bin
        aligned(i,j,:) = mean(dFF(binIdx==j,:),1,"omitnan"); %Take mean of dFF in each bin
    end
end

% Convert to cell array
dim = {size(aligned,1),size(aligned,2),ones(1,numel(cells.dFF))}; %Dimensions of each cell: trials x time, one cell per neuron
aligned = mat2cell(aligned,dim{:});
aligned = squeeze(aligned); %Column array

