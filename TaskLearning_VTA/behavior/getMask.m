function combinedMask = getMask( trials, fieldNames )
% % geMask %
%PURPOSE:   Get trial mask defined by conjunction of unlimited trial conditions
%AUTHORS:   MJ Siniscalchi, 170113
%
%INPUT ARGUMENTS
%   trials:         structure generated by getTrialMask()
%   fieldNames:     the field names involved
%
%OUTPUT ARGUMENTS
%   combinedMask:   mask where all fields are satisfied, i.e. an AND operation

temp = [];
for i = 1:length(fieldNames)
    temp = [temp trials.(fieldNames{i})(:)]; %#ok<AGROW> %trialMasks as columns of array
end
combinedMask = all(temp,2); %true if all elements are non-zero

%Exclude trials if specified
if isfield(trials,'exclude')
    combinedMask = combinedMask & ~trials.exclude(:);
end