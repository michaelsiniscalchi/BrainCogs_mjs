function regiment = mjs_runCohort_PavlovianReversal(numDataSync, varargin)

if nargin < 1
    numDataSync = [];
end

name = getenv('COMPUTERNAME');
switch name
    case 'homePC' %Edit for home Desktop
    dataPath = 'J:\Data & Analysis\task-learning';
    case 'PNI-F4W2YM2' %PNI Desktop for DEVO
    dataPath = 'C:\Data\task-learning';
    otherwise %Training Rigs, etc.
    dataPath = 'C:\Data\msiniscalchi';   
end

experName = 'mjs_pavlovianTrack';
cohortName = 'VMR1';
regiment = runCohortExperiment(dataPath, experName, cohortName, numDataSync, varargin{:});

%Call Rig Tester to drain reservoirs, check puffs, etc.
TestVRRig_2('TowersTask_PuffTask');

end