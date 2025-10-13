function struct_out = psytrack_pickle2Mat(pklfile_psytrack, predictor_names)

pickle = py.importlib.import_module('pickle');
py.importlib.import_module('numpy');

%Load data from PKL file
%Open in binary read mode
h = py.open(pklfile_psytrack, 'rb'); %Handle to pkl file; eg, 'X:\michael\tactile2visual-vta\summary\913_psytrack_all_sessions.pkl';
S = struct(pickle.load(h)); %Convert Python dictionary to MATLAB struct
data = struct(S.new_dat);
h.close(); % Close the file handle

%Get session dates
sessionID = datetime(string(data.session.tolist),'InputFormat','yyyyMMdd'); %One datetime for per trial...

%Two-way dictionary to translate Vanessa's psytrack predictor names
t2vNames = ["leftTowers","rightTowers","leftPuffs","rightPuffs"];
psyNames = ["tower_left","tower_right","puff_left","puff_right"];
D = dictionary([t2vNames,psyNames],[psyNames,t2vNames]);

%Get model predictor names from Python dictionary for weights
pNames = string(fieldnames(struct(S.weights))); 
pNames = pNames(ismember(pNames, D(predictor_names))); %Exclude any predictor names not specified in function call
weightStruct = cell2struct(cell(size(pNames)), cellstr(D(pNames))); %Assign t2v conventional names to psytrack weights

%Extract weights
W = double(S.wMode); %Trial-by-trial weights on each predictor
W_std = double(S.W_std); %Same for sd

%Struct array: one for each session
sessionList = unique(sessionID(:),'stable'); %Get list of unique session dates
struct_out =...
    struct("session_date", NaT(size(sessionList)), "meanCoef", weightStruct, "se", weightStruct);
for i = 1:numel(sessionList)
    struct_out.session_date(i) = sessionList(i); 
    idx = sessionID==sessionList(i);
    for j = 1:numel(pNames)
        struct_out.meanCoef.(D(pNames(j)))(i,:) = mean(W(j,idx)); %Mean weight across trials for each session
        mse = (W_std(j, idx)).^2; %MSE for each session  
        struct_out.se.(D(pNames(j)))(i,:) = mean(W(j,idx)) + [-1;1]*sqrt(mean(mse)); %Take square root to yield aggregate SE for each session
    end
end







