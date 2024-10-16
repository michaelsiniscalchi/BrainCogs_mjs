%Generate simulated data to validate encoding model

clearvars;
sub_dir = '230922-m105-maze7';
img_beh = load(fullfile('X:','michael','tactile2visual-vta','results',sub_dir,'img_beh.mat'),...
    'trials', 'trialData', 't');
encoding = load(fullfile('X:','michael','tactile2visual-vta','results',sub_dir,'encoding.mat'),...
    'model', 'kernel');

%Unpack
trials = img_beh.trials;
trialData = img_beh.trialData;
eventTimes = img_beh.trialData.eventTimes;
t = img_beh.t;

%Obtain simulated dFF for each neuron, using predicted response from glm
dFF = cell(numel(encoding.kernel),1);
for i = 1:numel(encoding.kernel) %For each neuron
    %Convolve impulse function with each event's response kernel from model
    %Then take sum to generate simulated dF/F signal
    dFF{i} = encoding.model{i}.Fitted.Response;
end

%% Run encoding model on simulated data
%Be sure to match model params!
simulated_img_beh = struct("dFF",{dFF},"trials",trials,"trialData",trialData,"t",t);
params.bSpline_nSamples = 120; %N time points for spline basis set
params.bSpline_degree = 3; %degree of each (Bernstein polynomial) term
params.bSpline_df = 7; %number of terms:= order + N internal knots

glm = encodingModel( simulated_img_beh, params );

saveName = (fullfile('X:','michael','tactile2visual-vta','results',sub_dir,'encoding_simulation.mat'));
save(saveName,"-struct","glm");
save(saveName,"dFF", "trials","trialData",'-append');

