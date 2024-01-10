function mjs_runCohort_VTA1(numDataSync, varargin)

if nargin < 1
    numDataSync = [];
end

name = getenv('COMPUTERNAME');
switch name
    case 'homePC' %Edit for home Desktop
    dataPath = 'J:\Data & Analysis\Task Learning';
    case 'PNI-F4W2YM2' %PNI Desktop for DEVO
    dataPath = 'C:\Data\Task Learning';
    otherwise %Training Rigs, etc.
    dataPath = 'C:\Data\msiniscalchi';   
end

experName = 'mjs_taskLearning';
cohortName = 'VTA_1';
runCohortExperiment(dataPath, experName, cohortName, numDataSync, varargin{:});

%Call Rig Tester to drain reservoirs, check puffs, etc.
TestVRRig_2('TowersTask');

end