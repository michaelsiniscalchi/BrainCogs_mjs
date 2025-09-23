
clearvars;

pickle = py.importlib.import_module('pickle');
np = py.importlib.import_module('numpy');
pd = py.importlib.import_module('pandas');

% Open the pickle file in binary read mode
filename = 'X:\michael\tactile2visual-vta\summary\913_psytrack_all_sessions.pkl';
fh = py.open(filename, 'rb');

% Load data from the pickle file
S = struct(pickle.load(fh)); %Convert Python dictionary to MATLAB struct
metaData = struct(S.new_dat);

weights = struct(S.weights); %Python dictionary for weights
nTrials = int64(metaData.dayLength); %Trials per session

% Close the file handle
fh.close();

%% Functionalize
clearvars;
fname = 'X:\michael\tactile2visual-vta\summary\913_psytrack_all_sessions.pkl';
predictors = ["tower_left","tower_right","puff_left","puff_right"];
struct_out = psytrack_pickle2Mat(fname, predictors);


