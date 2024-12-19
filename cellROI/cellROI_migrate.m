%%% cellROI v2
% PURPOSE: Graphical user interface for selecting regions of interest (ROIs) from motion-corrected calcium imaging data.
% AUTHORS: MJ Siniscalchi & AC Kwan 181105 
%
%***FUTURE EDITS:
%-Use dispRelFluo function from selectROI() to implement neuropil masks...
%-Allow dispRelFluo to be called by select circle function as well...
%-ASAP: 'roiData' names a function and a local variable in different places...fix!
%-Get rid of Checkbox: 'repeat ROI selection after save'
%-Keypress function (arrows): nudge ROI L-R-U-D using circshift().
%-Uses of histc --> histcounts
%
%---------------------------------------------------------------------------------------------------

function varargout = cellROI(varargin)
%To edit/open this program, use "File --> New --> GUI"

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @cellselect_OpeningFcn, ...
    'gui_OutputFcn',  @cellselect_OutputFcn, ...
    'gui_LayoutFcn',  [] , ...
    'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT

% --- Executes just before GUI is made visible.
function cellselect_OpeningFcn(hObject, eventdata, handles, varargin)

%Default command line output
handles.output = hObject;

%Allow passage of stack, mean_proj, var_proj, max_proj, as fields of struct as INPUT ARG #1
if numel(varargin)>0
    if isinteger(varargin{1})
        handles.stack = varargin{1};
    elseif isstruct(varargin{1})
        fields = fieldnames(varargin{1});
        for i = 1:numel(fields)
            handles.(fields{i}) = varargin{1}.(fields{i});
        end %fields = {'stack','mean_proj','var_proj','max_proj','filename'};
    end
end

if all(isfield(handles,{'stack','filename','pathname'}))
    handles = loadImageStack(handles);
    refresh_Axis((1:4),handles); %Refresh left & right axes
end

% Update handles structure
guidata(hObject, handles);

% --- Outputs from this function are returned to the command line.
function varargout = cellselect_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% ---PUSHBUTTON: LOAD STACK (executes on button press).
function pushbutton_loadimagestack_Callback(hObject, eventdata, handles)

%Clear data from any previous loaded stack
fields = {'stack','mean_proj','max_proj','var_proj'};
for i = find(isfield(handles,fields))
    handles = rmfield(handles,fields{i});
end

%Prompt user to select a .TIF stack containing calcium imaging data
[handles.filename, handles.pathname] = ...
    uigetfile('*.tif', 'Select a time-lapse image stack (*.TIF).'); %Get filename and path

%Load stack and generate projections
handles = loadImageStack(handles); %pathname and filename for stack as .TIF

guidata(hObject, handles); %Save user data
refresh_Axis((1:4),handles); %Refresh left & right axes

% ---Load Image Stack------------------------------------------------------
%Load stack from file or input argument and generate associated projections
function handles = loadImageStack(handles)

%Check for saved data file roiData.mat
handles.save_dir = fullfile(handles.pathname,... 
    strcat('ROI_',handles.filename));                       %Path for ROI directory
roiData_fname = fullfile(handles.save_dir,'roiData.mat');
if exist(roiData_fname,'file')
    S = load(roiData_fname,'stack','max_proj','mean_proj','var_proj');
    disp(['Loading saved data from ' roiData_fname ':']);
    
    fields = fieldnames(S); 
    disp(fields);
    for i = 1:numel(fields)
        handles.(fields{i}) = S.(fields{i}); %fields = {'stack','mean_proj','var_proj','max_proj',...};
    end
else
    mkdir(handles.save_dir); %Setup subdir for saving files
    S = struct('filename',handles.filename);
    save(roiData_fname,'-struct','S','-v7.3');
end

%Load stack using custom function loadtiffseq.m
if ~isfield(handles,'stack')
    disp(['Loading ' handles.pathname handles.filename '...']); tic
    stack = double(loadtiffseq(fullfile(handles.pathname,handles.filename))); toc
    handles.stack = stack-min(stack(:)); %Recenter so all values are positive
end

%Calculate mean, max, and variance projections to aid in ROI selection
if ~isfield(handles,'var_proj'), tic;
    handles.text_stackSize.String = 'Getting projections...';
    disp('Getting mean projection...');
    handles.mean_proj = mean(handles.stack,3);
    disp('Getting variance projection...');
    handles.stack = permute(handles.stack,[3,1,2]); %Time-dimension to D1 to speed calculation (tested 3-20x faster)
    handles.var_proj = squeeze(var(handles.stack,0,1));
    handles.stack = permute(handles.stack,[2,3,1]); %Time-dimension back to D3
    disp('Getting maximum projection...');
    handles.max_proj = max(handles.stack,[],3); toc
    %Save projections in roiData.mat
    disp(['Saving all projections in ' roiData_fname '...']);
    S = struct('mean_proj',handles.mean_proj,'var_proj',handles.var_proj,...
        'max_proj',handles.max_proj);
    save(roiData_fname,'-struct','S','-append'); disp('Done.');
end

%Project data onto Axes 1 (left) & 2 (right)
for i=1:2 %Check radio buttons and get specified projection
    handles.img{i} = getProjection(i,handles); %img = getProjection(axisID,handles)
end

%Initialize user data structure and populate text/edit fields
handles = initUserData(handles);
handles.edit_nROIsToLoad.String = num2str(numel(handles.save_names)); %Last cell ID
handles.edit_cellID.String = '1'; %Cell ID for save
handles.figure1.Name = ['cellROI 2.0     ' handles.filename];
[nY,nX,nZ] = size(handles.stack);
handles.text_stackSize.String = [num2str(nZ) ' frames of ' num2str(nX) 'x' num2str(nY) ' loaded.']; %Display stack dimensions

% --- RADIO BUTTONS: PROJECTION TYPE (executes on mouse-click) ------------
function radiobutton_meanAxis1_Callback(hObject, eventdata, handles) %Switch to MEAN projection on Axes 1 (left)
handles.img{1} = getProjection(1,handles); %img = getProjection(axisID,handles)
guidata(hObject, handles); %Save user data
refresh_Axis(1,handles);
function radiobutton_maxAxis1_Callback(hObject, eventdata, handles) %Switch to MAX projection on Axes 1 (left)
handles.img{1} = getProjection(1,handles); %img = getProjection(axisID,handles)
guidata(hObject, handles); %Save user data
refresh_Axis(1,handles);
function radiobutton_varAxis1_Callback(hObject, eventdata, handles) %Switch to VARIANCE projection on Axes 1 (left)
handles.img{1} = getProjection(1,handles); %img = getProjection(axisID,handles)
guidata(hObject, handles); %Save user data
refresh_Axis(1,handles);
function radiobutton_redAxis1_Callback(hObject, eventdata, handles) %Switch to RED CHANNEL projection on Axes 1 (left)
[filename, pathname] = ...
    uigetfile('*.tif', 'Select a z-projection from the structural (red) channel (*.TIF).'); %Load single-frame tiff
handles.red_proj = double(imread(fullfile(pathname,filename)));
handles.img{1} = getProjection(1,handles); %img = getProjection(axisID,handles)
guidata(hObject, handles); %Save user data
refresh_Axis(1,handles);

function radiobutton_meanAxis2_Callback(hObject, eventdata, handles) %Switch to MEAN projection on Axes 2 (right)
handles.img{2} = getProjection(2,handles); %img = getProjection(axisID,handles)
guidata(hObject, handles); %Save user data
refresh_Axis(2,handles);
function radiobutton_maxAxis2_Callback(hObject, eventdata, handles)  %Switch to MAX projection on Axes 2 (right)
handles.img{2} = getProjection(2,handles); %img = getProjection(axisID,handles)
guidata(hObject, handles); %Save user data
refresh_Axis(2,handles);
function radiobutton_varAxis2_Callback(hObject, eventdata, handles) %Switch to VAR projection on Axes 2 (right)
handles.img{2} = getProjection(2,handles); %img = getProjection(axisID,handles)
guidata(hObject, handles); %Save user data
refresh_Axis(2,handles);

% --- SLIDERS: WHITE LEVEL (executes on mouse-click) ----------------------
function slider_whiteLevelAxis1_Callback(hObject, eventdata, handles)
%Get projection of data, apply white level, then refresh Axis 1
handles.text_whiteLevelAxis1.String = num2str(handles.slider_whiteLevelAxis1.Value);
handles.img{1} = getProjection(1,handles); %img = getProjection(axisID, handles)
refresh_Axis(1,handles); %Refresh graphics and make current axis
guidata(hObject, handles); %Store user data
function slider_whiteLevelAxis2_Callback(hObject, eventdata, handles)
%Get projection of data, apply white level, then refresh Axis 1
handles.text_whiteLevelAxis2.String = num2str(handles.slider_whiteLevelAxis2.Value); %Update display
handles.img{2} = getProjection(2,handles); %img = getProjection(axisID, handles)
refresh_Axis(2,handles); %Refresh graphics and make current axis
guidata(hObject, handles); %Save user data

% --- SLIDERS: TRANSLATION (X-Y shift for reference image, Axis 1) (executes on mouse-click) --
function slider_shiftX_Callback(hObject, eventdata, handles)
handles.text_shiftX.String = ['dx = ' num2str(round(handles.slider_shiftX.Value))]; %Update display
handles.img{1} = getProjection(1,handles); %img = getProjection(axisID, handles)
guidata(hObject, handles); %Save user data
refresh_Axis(1,handles);
function slider_shiftY_Callback(hObject, eventdata, handles)
handles.text_shiftY.String = ['dy = ' num2str(round(handles.slider_shiftY.Value))]; %Update display
handles.img{1} = getProjection(1,handles); %img = getProjection(axisID, handles)
guidata(hObject, handles); %Save user data
refresh_Axis(1,handles);

% --- PUSHBUTTON: SELECT CIRCLE (executes on button press.)
function pushbutton_selectCircle_Callback(hObject, eventdata, handles)

%Store active select-function
handles.selectCircle_active = true; %Circle ROI
handles.recalcCorr_active = false; %Pixel-correlation --> ROI

%Refresh axes
%handles.curr_ROI = [];
refresh_Axis([1:4],handles);

%Get selected pixel and test against frame boundaries
[nY,nX,~] = size(handles.stack);
[X,Y] = ginput(1);
if (X<0) || (X>nX) || (Y<0) || (Y>nY), return, end

%Determine the approx. circular logical mask
r = str2double(get(handles.edit_circRadius,'String'));
[rr,cc] = meshgrid(1:nX);
handles.cellMask = sqrt((rr-X).^2+(cc-Y).^2)<=r; %Get grids within circle radius
%Store cellF and patch vertices in memory
[handles.curr_ROI, handles.curr_cellf] = roiData(handles);

guidata(hObject, handles); %Save user data
refresh_Axis((1:3),handles); %Display patch and corresponding DFF

% --- PUSHBUTTON: SELECT POLYGON (executes on corresponding button press.)
function pushbutton_selectPolygon_Callback(hObject, eventdata, handles)

%Refresh axes
%handles.curr_ROI = [];
refresh_Axis((1:4),handles);

%Get arbitrary polygonal ROI from user input
handles.cellMask = roipoly; %Get logical mask approximation of polygon drawn by user

%Display patch and corresponding DFF
[handles.curr_ROI, handles.curr_cellf] = roiData(handles); %Store cellF and patch vertices in memory

refresh_Axis((1:3),handles); %Refresh left & right axes
guidata(hObject, handles); %Save user data

%--- PUSHBUTTON: SELECT PIXEL for correlation (executes on corresponding button press)
function pushbutton_selectCorrPixel_Callback(hObject, eventdata, handles)

%Refresh axes
refresh_Axis((1:4),handles);

%Get seed pixel specified by user
[handles.ginput{1},handles.ginput{2}] = ginput(1); %[X,Y] = ginput(nPoints);

%Calculate pixel-wise correlation with
pushbutton_recalcCorr_Callback(handles.pushbutton_recalcCorr,eventdata,handles); %Callback function for 'Recalc' pushbutton
handles = guidata(hObject); %Expicitly set handles assigned by callback function for different uicontrol

guidata(hObject, handles); %Save user data

%--- PUSHBUTTON: RECALC pixel correlation (executes on corresponding button press)
%    note: also performs initial calculation after pushbutton SELECT PIXEL is pressed.
function pushbutton_recalcCorr_Callback(hObject, eventdata, handles)

%Store active select-function
handles.recalcCorr_active = true; %Pixel-correlation --> ROI
handles.selectCircle_active = false; %Circle ROI

%Determine square to correlate
[nX,nY,~] = size(handles.stack);
X = handles.ginput{1}; %ginput from SELECT PIXEL pushbutton callback
Y = handles.ginput{2};

if (X<0) || (X>nX) || (Y<0) || (Y>nY), return, end

width = str2double(get(handles.edit_boxWidthXCorr,'String'));
if isempty(width)
    %Get correlation with all pixels in frame
    x = [1,nX];
    y = [1,nY];
else
    %Get X and Y boundaries of pixel region to correlate
    x = round(X + [-width/2, width/2]); %ginput from Select Pixel pushbutton callback
    y = round(Y + [-width/2, width/2]);
    %Set values outside frame to nearest pixel
    x = max([x;1,1]); x = min([x;nX,nX]);
    y = max([y;1,1]); y = min([y;nY,nY]);
end

%Calculate matrix of correlation coefficients between seed and each pixel
cc_mat = zeros(nY,nX);
seedPixel = squeeze(handles.stack(round(Y),round(X),:)); %Seed pixel
for i = x(1):x(2)
    for j = y(1):y(2)
        cc_mat(j,i) = corr2(...
            seedPixel, squeeze(handles.stack(j,i,:))); %Pixel (j,i)
    end
end

%Threshold by percentile specified in edit box
temp = cc_mat(cc_mat>0);
thresh_perc = min([max([0,str2double(handles.edit_XCorrLowerBound.String)*100]),100]);
low_bound = prctile(temp,thresh_perc); %Get lower bound from edit box

%Plot histogram of R-values
cla(handles.axes4);
hold(handles.axes4,'on');
edges = [-1:0.02:1];
counts = histc(cc_mat(:),edges);
bar(handles.axes4,edges,counts,'histc');
plot(handles.axes4,[low_bound low_bound],[0 1.1*max(counts)],'r','LineWidth',1);
xlim(handles.axes4,[0,1]);
temp = max(counts(edges>low_bound));

if isempty(temp)
    return
else
    %Display patch and corresponding DFF
    ylim(handles.axes4,[0,1.1*temp]); %ylim set to 1.1 * maximum count above threshold
    BW = (cc_mat>low_bound); %Get logical mask of pixels exceeding threshold
    BW = ~bwareaopen(~BW,10,8); %Remove small holes from pixel mask
    handles.cellMask = bwareafilt(BW,1,4); %Keep only the largest region; 'conn'=4

    [handles.curr_ROI, handles.curr_cellf] = roiData(handles); %Store cellF and patch vertices in memory

    guidata(hObject, handles); %Save user data
    refresh_Axis((1:3),handles); %Refresh left & right axes
end

%--- PUSHBUTTON: SAVE (executes on corresponding button press) ------------
function pushbutton_savetraces_Callback(hObject, eventdata, handles)

%Check for necessary variables
if isempty(handles.cellMask) %Eg if error in constructing mask or if saved cell selected
    return
end

%Check if save would overwrite; verify with user before continuing
save_name = getSaveName(handles,str2double(handles.edit_cellID.String));
handles.check_overwrite = true; %Set back to default: check before overwriting

%Save data for current ROI
S = struct('cellf',handles.curr_cellf,'bw',handles.cellMask);
save(fullfile(handles.save_dir,save_name),'-struct','S');

%Store data in structure
idx = str2double(handles.edit_cellID.String); %Edit box can be changed by function getSaveName(handles,idx)
handles.roi{idx} = handles.curr_ROI; %Store vertices of current ROI patch
handles.cellMasksAll(:,:,idx) = handles.cellMask; %3D array of logical masks: nY x nX x nROIs
handles.cellf{idx} = handles.curr_cellf; %Store cellF from current ROI patch
if ~isempty(handles.curr_cellf)
    handles.excludeROI(idx) = false; %Restore default, eg when transferring longitudinal ROIs
end

handles.save_names{idx} = save_name; %Store save_name
[handles,~] = nxtCellID(handles); %Increment cell ID

%Refresh axes
handles.curr_ROI = []; handles.curr_cellf = []; handles.cellMask = []; %Clear current ROI data
refresh_Axis((1:4),handles);
handles = delete_refFig(handles); %Delete reference figure (longitudinal imaging only)

%Store user data
guidata(hObject, handles);

%Generate filename for save
function save_name = getSaveName(handles,idx)

if ~strcmp(handles.edit_saveNamePrefix.String, 'Prefix for save...') %If other than default
    save_name = fullfile(strcat(handles.edit_saveNamePrefix.String,...
        '_cell',sprintf('%03d',idx),'.mat'));
else
    save_name = fullfile(strcat('cell',sprintf('%03d',idx),'.mat')); %If no prefix entered (default)
end
%Check if already used and if so, get user input: overwrite or generate new filename
if exist(fullfile(handles.save_dir,save_name),'File') && handles.check_overwrite
    A = questdlg(['Overwrite ',save_name,'?'],'Overwrite ROI File','Overwrite.','New Filename.','Overwrite.');
    if strcmp(A,'New Filename.')
        [handles,idx] = nxtCellID(handles); %Increment cell ID for save
        save_name = getSaveName(handles,idx);
    end
end

% --- PUSHBUTTON: LOAD (Executes on button press in pushbutton_loadSavedROIs.)
function pushbutton_loadSavedROIs_Callback(hObject, eventdata, handles)

%If IMPORT box checked, import all ROI dirs in current data dir (for longitudinal imaging)
if handles.checkbox_ImportROIs.Value
    parts = strsplit(handles.pathname,filesep); %Split pathname
    data_dir = strjoin(parts(1:end-2),filesep); %Retrieve parent dir
    handles = transferROIs(data_dir,handles);
    handles = initUserData(handles);
    handles.edit_nROIsToLoad.String = num2str(numel(handles.save_names));
else
    handles = initUserData(handles); %Initialize struct userdata
end

for i = 1:numel(handles.save_names)
    
    %Stop loading ROIs at user-defined cell ID
    if i > str2double(handles.edit_nROIsToLoad.String) %Last three-digit cell ID to load
        break
    elseif isempty(handles.save_names{i})
        continue
    end
    
    %Load saved ROI data
    warning('off','MATLAB:load:variableNotFound');
    try
        S = load(fullfile(handles.save_dir,handles.save_names{i}),...
            'bw','cellf','subtractmask','neuropilf'); %s.bw is logical mask
        S.bw = imresize(S.bw,size(handles.stack,[1,2])); %Resize if necessary
        if isfield(S,'subtractmask')
            S.subtractmask = imresize(S.subtractmask,size(handles.stack,[1,2])); %Resize if necessary
            if handles.checkbox_loadNeuropilData.Value
                handles.neuropilf{i} = S.neuropilf;         %Get saved neuropil data
                handles.npPoly(i) = getNpPoly(S.subtractmask); %Generate polygon representation (graphics object)
            end
        end
        
        handles.cellMasksAll(:,:,i) = S.bw; %3D array of logical masks: nY x nX x nROIs
        bounds = bwboundaries(S.bw); %Generate polygon representation of each cell mask
        handles.roi{i} = [bounds{1}(:,2) bounds{1}(:,1)]; %ROI coordinates in xy
    catch err
        disp(err); beep;
        warning(['Problem with ' handles.save_names{i}...
            '. May require user to manually delete file and reload ROIs.']);
    end
    
    %Generate exclude mask from saved data
    handles.cellf{i} = S.cellf;
    if isempty(S.cellf)
        handles.excludeROI(i) = true; %Excluded ROIs have full cellf timeseries set to NaN
    else
        handles.excludeROI(i) = false;
    end
    
end

[handles,~] = nxtCellID(handles); %Increment cell ID for save

guidata(hObject, handles); %Save user data
refresh_Axis((1:4),handles); %Refresh left & right axes
saveRefImg(handles) %Save a reference image of axes2 including ROIs

% --- PUSHBUTTON: DELETE (Executes on button press in pushbutton_delROI or keypress 'delete')
function pushbutton_delROI_Callback(hObject, ~, handles)
idx = str2double(handles.edit_cellID.String);
A = questdlg(strjoin({'Permanently delete',handles.save_names{idx},'?'}),...
    'Delete ROI','Ok','Cancel','Ok');
if strcmp(A,'Ok')
    %Recycle file
    recycle('on');
    delete(fullfile(handles.save_dir,handles.save_names{idx}));
    %Clear ROI data
    handles.roi{idx} = [];
    handles.cellf{idx} = [];
    handles.cellMasksAll(:,:,idx) = ...
        false(size(handles.stack,1),size(handles.stack,2)); %3D array of logical masks: nY x nX x nROIs
    handles.curr_ROI = [];
    handles.curr_cellf = [];
    handles.excludeROI(idx) = false;
    handles.save_names{idx} = [];
else
    return
end

handles = delete_refFig(handles); %Delete reference figure (longitudinal imaging only)

[handles,~] = nxtCellID(handles); %Increment cell ID for save
guidata(hObject, handles); %Save user data
refresh_Axis((1:4),handles); %Refresh left & right axes

% --- TOGGLEBUTTON: EXCLUDE (Executes on button press in togglebutton_excludeROI.)
function togglebutton_excludeROI_Callback(hObject, eventdata, handles)

idx = str2double(handles.edit_cellID.String); %Get cell ID

if isempty(handles.cellMask)
    S = load(fullfile(handles.save_dir,handles.save_names{idx}),'bw');
    handles.cellMask = S.bw;
end

handles.check_overwrite = false;
if hObject.Value == hObject.Max
    handles.excludeROI(idx) = true; %For refreshing ROI mask
    handles.curr_cellf = []; %Exclude ROI data
elseif hObject.Value == hObject.Min
    %handles.curr_ROI = handles.roi{idx}; %Make these vertices the current ROI
    handles.excludeROI(idx) = false;
    [~, handles.curr_cellf] = roiData(handles); %Get cellf and save to .MAT file
end
pushbutton_savetraces_Callback(handles.pushbutton_saveCellF, [], handles);  %Update .MAT file

handles.togglebutton_excludeROI.Value = handles.togglebutton_excludeROI.Min; %Toggle button off

handles = guidata(hObject); %Explicitly repopulate userdata struct after calling pushbutton functions
guidata(hObject, handles);  %Save user data
refresh_Axis(1:3,handles);

% --- PUSHBUTTON: CALCULATE NEUROPIL SIGNALS... (Executes on button press in pushbutton_calcNeuropil.)
% FUTURE EDITS: move toward high-level functions for area, centroid, etc...
function pushbutton_calcNeuropil_Callback(hObject, eventdata, handles)

%Reload all saved ROIs
handles.edit_nROIsToLoad.String = num2str(numel(handles.save_names)); %Last cell ID
pushbutton_loadSavedROIs_Callback(handles.pushbutton_loadSavedROIs, eventdata, handles);
handles = guidata(hObject);

%For each ROI, get centroid and radius; generate mask for all somata
disp('Getting neuropil data...');
idx = find(~cellfun(@isempty,handles.save_names)); %Cell indices; skip unused save names
centroid = struct('X',cell(numel(idx),1),'Y',cell(numel(idx),1)); %Initialize
r_ROI = NaN(numel(idx),1);
cellMask = false(size(handles.img{1}));
for i = idx
    S = load(fullfile(handles.save_dir,handles.save_names{i}),'bw'); %s.bw is logical mask for ROI
    [Y,X] = find(S.bw);
    centroid(i).X = mean(X);  %Centroid of ROI
    centroid(i).Y = mean(Y);
    r_ROI(i) = sqrt(sum(S.bw(:))/pi); %Circular ROI with r = sqrt(A/pi) used for estimating neuropil mask
    cellMask = cellMask | S.bw; %Incorporate ROI into logical mask for all cell bodies
end
clearvars X Y

for i = find(~cellfun(@isempty,handles.save_names) & ~handles.excludeROI) %Skip excluded ROIs and unused save names
    disp(['Calculating neuropil signal for cell ' num2str(i) '...']);
    %Construct neuropil mask as annulus with user-defined inside and outside
    subtractmask = false(size(cellMask));
    circle = cell(2,1); %Cell array for the inner and outer circle
    R(1) = str2double(handles.edit_calcNeuropil_Ri.String); %Number of cell radii for inner diameter
    R(2) = str2double(handles.edit_calcNeuropil_Ro.String); %Number of cell radii for outer diameter
    for j = 1:2
        %Get grids within R(j) cell radii of centroid
        [X,Y] = meshgrid(1:length(subtractmask));
        circle{j} = sqrt((X - centroid(i).X).^2 + (Y - centroid(i).Y).^2)...
            <= R(j) * r_ROI(i);   %Inner or outer radius of annulus in units of cell radius
    end
    subtractmask = circle{2} & ~circle{1} & ~cellMask; %Exclude inner circle and somata mask
    subtractmaskRadii = R; %Record radii for later reference
    
    %Get neuropil fluorescence and save
    neuropilf = nan(size(handles.stack,3),1); %Vector for neuropil signal
    idx = reshape(subtractmask,[],1); %Get linear logical indices for subtractmask
    for j = 1:size(handles.stack,3)
        img_vect = reshape(handles.stack(:,:,j),[],1); %Convert the j-th frame to vector
        neuropilf(j) = mean(img_vect(idx)); %Get mean pixel intensity
    end
    save(fullfile(handles.save_dir,handles.save_names{i}),'neuropilf','subtractmask','subtractmaskRadii','-append');
    
    handles.neuropilf{i} = neuropilf; %Store neuropil data
    handles.npPoly(i) = getNpPoly(subtractmask); %Generate polygon representation (graphics object)
end
disp('Done!');
guidata(hObject, handles); %Save user data
refresh_Axis(1:3,handles); %Plot the annuli used for estimation of neuropil signal

%--- KEYPRESS FUNCTIONS (executes on keypress with focus on cellROI.fig) ---
function figure1_WindowKeyPressFcn(hObject, eventdata, handles)

keyPressed = eventdata.Key; %Determine the key that was pressed
if strcmpi(keyPressed,'s') %Save ROI and associated cellF
    pushbutton_savetraces_Callback(handles.pushbutton_saveCellF,[],handles);
elseif strcmpi(keyPressed,'c') %Draw ROI with 'draw circle' callback function
    pushbutton_selectCircle_Callback(handles.pushbutton_selectCircle, [], handles);
elseif strcmpi(keyPressed,'x') %Draw ROI with pixel correlation callback function
    pushbutton_selectCorrPixel_Callback(handles.pushbutton_selectCorrPixel, [], handles);
elseif strcmpi(keyPressed,'z') %Draw ROI with 'draw polygon callback function
    pushbutton_selectPolygon_Callback(handles.pushbutton_selectPolygon, [], handles);
elseif strcmpi(keyPressed,'e') %Draw ROI with previous pushbutton callback function
    handles.togglebutton_excludeROI.Value = abs(handles.togglebutton_excludeROI.Value-1); %Toggle button on/off
    togglebutton_excludeROI_Callback(handles.togglebutton_excludeROI, [], handles);
elseif strcmpi(keyPressed,'delete') || strcmpi(keyPressed,'d')%Delete ROI data
    pushbutton_delROI_Callback(handles.pushbutton_delROI,[],handles); %DELETE ROI
elseif (strcmpi(keyPressed,'uparrow') || strcmpi(keyPressed,'downarrow'))...
        && all(strcmp(eventdata.Modifier,'shift')) 
    handles = resizeROI(handles,keyPressed); %Change ROI area by one pixel on each side
    guidata(hObject,handles);
    refresh_Axis((1:3),handles);  %Refresh left & right axes
end

%--- WINDOW BUTTONDOWN FUNCTION (executes on mouse click with focus on cellROI.fig) ---
function figure1_WindowButtonDownFcn(hObject, eventdata, handles)

if strcmp(handles.figure1.SelectionType,'alt')
    handles.curr_ROI = [];
    handles.cellMask = [];
    handles.togglebutton_excludeROI.Value = handles.togglebutton_excludeROI.Min; %Toggle button off
    
    %If using reference figs for longitudinal ROI selection
    if isfield(handles,'ref_fig') && isfield(handles.ref_fig,'figure')
        handles = delete_refFig(handles); %Close ref fig
    end
    [handles, ~] = nxtCellID(handles); %Increment cell ID
    
    guidata(hObject,handles);
    try refresh_Axis(1:4,handles); end %Try is used to avoid error in case user clicks before loading imaging data
end

% --- SCROLL-WHEEL FUNCTION (Executes on scroll wheel click while the figure is in focus)
function figure1_WindowScrollWheelFcn(hObject, eventdata, handles)

%If ROI selected and Pixel-correlation function active
scrollClick = eventdata.VerticalScrollCount;
if ~isempty(handles.curr_ROI)
    %&& all(isfield(handles,["recalcCorr_active","selectCircle_active"])) ~isempty(handles.curr_ROI)
    if handles.recalcCorr_active
        thresh = str2double(get(handles.edit_XCorrLowerBound,'String'));
        thresh = max([min([thresh+0.05*scrollClick, 1]),0]);
        set(handles.edit_XCorrLowerBound,'String',num2str(thresh));
        pushbutton_recalcCorr_Callback(handles.pushbutton_recalcCorr, eventdata, handles)
        %uicontrol(handles.pushbutton_recalcCorr); %Focus on button (clear edit cursor)

    elseif handles.selectCircle_active
        %Increment radius
        r = str2double(get(handles.edit_circRadius,'String')) + scrollClick;
        set(handles.edit_circRadius,'String',num2str(r));
        %Determine the approx. circular logical mask
        X = mean(handles.curr_ROI(:,1)); %XY coordinates of centroid of circular ROI
        Y = mean(handles.curr_ROI(:,2));
        [rr,cc] = meshgrid(1:size(handles.stack,1));
        handles.cellMask = sqrt((rr-X).^2+(cc-Y).^2)<=r; %Get grids within circle radius
        %Store cellF and patch vertices in memory
        [handles.curr_ROI, handles.curr_cellf] = roiData(handles);
        guidata(hObject, handles); %Save user data
        refresh_Axis((1:3),handles); %Display patch and corresponding DFF

    end
end

%--- SIZE CHANGED FUNCTION (executes when figure window is resized.)
function figure1_SizeChangedFcn(hObject, eventdata, handles)
try refresh_Axis(1:4,handles); end

%--- EDIT and CHECK BOXES (mostly unused callback functions) ----------------------
function edit_cellID_Callback(hObject, eventdata, handles)
%Highlight current ROI
idx = str2double(handles.edit_cellID.String); %Make ROI idx current
if size(handles.roi,2)>=idx && ~isempty(handles.roi{idx})
    handles.curr_ROI = handles.roi{idx}; %Make these vertices the current ROI
    handles.curr_cellf = handles.cellf{idx}; %Set corresponding cellF as current cellF
    handles.togglebutton_excludeROI.Value = handles.excludeROI(idx); %Update state of toggle button
else
    handles.curr_ROI = []; %Make these vertices the current ROI
    handles.curr_cellf = []; %Set corresponding cellF as current cellF
    handles.togglebutton_excludeROI.Value = 0; %Update state of toggle button
end

guidata(hObject,handles); %Save userdata
refresh_Axis((1:3),handles);  %Refresh left & right axes

function edit_XCorrLowerBound_Callback(hObject, eventdata, handles)
pushbutton_recalcCorr_Callback(handles.pushbutton_recalcCorr, eventdata, handles)
uicontrol(handles.pushbutton_recalcCorr); %Focus on button (clear edit cursor)

function edit_boxWidthXCorr_Callback(hObject, eventdata, handles)
pushbutton_recalcCorr_Callback(handles.pushbutton_recalcCorr, eventdata, handles)
uicontrol(handles.pushbutton_recalcCorr); %Focus on button (clear edit cursor)

function edit_circRadius_Callback(hObject, eventdata, handles)
pushbutton_selectCircle_Callback(handles.pushbutton_selectCircle, eventdata, handles)
uicontrol(handles.pushbutton_selectCircle); %Focus on button (clear edit cursor)

function edit_nROIsToLoad_Callback(hObject, eventdata, handles)
pushbutton_loadSavedROIs_Callback(handles.pushbutton_loadSavedROIs, eventdata, handles)
uicontrol(handles.pushbutton_loadSavedROIs); %Focus on button (clear edit cursor)

function checkbox_showROIs_Callback(hObject, eventdata, handles)
%If using reference figs for longitudinal ROI selection
if isfield(handles,'ref_fig') && isfield(handles.ref_fig,'figure')
    figure(handles.ref_fig.figure); %refocus on ref fig
end
%In any case, refresh image axes to toggle display/hide ROIs
refresh_Axis(1:2,handles); %refresh_Axis fcn tests value of checkbox

function checkbox_ImportROIs_Callback(hObject, eventdata, handles)
function edit_saveNamePrefix_Callback(hObject, eventdata, handles)
function edit_calcNeuropil_Ri_Callback(hObject, eventdata, handles)
function edit_calcNeuropil_Ro_Callback(hObject, eventdata, handles)
function checkbox_armRepeatSelect_Callback(hObject, eventdata, handles)

%--- CREATE FUNCTIONS ---------------------------------------------------
function edit_cellID_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function edit_boxWidthXCorr_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function edit_circRadius_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function edit_saveNamePrefix_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function edit_XCorrLowerBound_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function edit_nROIsToLoad_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function slider_shiftX_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function slider_shiftY_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function slider_whiteLevelAxis1_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function slider_whiteLevelAxis2_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function edit_calcNeuropil_Ri_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function edit_calcNeuropil_Ro_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%--- ***NON-GUIDE FUNCTIONS*** --------------------------------------------

%--- INITIALIZE USER DATA STRUCTURE (struct 'handles') --------------------
function handles = initUserData(handles)

handles.cmap = colormap(repmat(linspace(0,1,256)',1,3)); %Gray color map for imaging data
handles.roi = {}; %Cell array containing vertices of all ROIs
handles.cellf = {}; %Cell array containing mean cellular fluorescence for each ROI
handles.curr_ROI = []; %Vertices of current ROI patch
handles.curr_cellf = []; %Cellular fluorescence from current ROI
handles.cellMask = false(size(handles.stack,1),size(handles.stack,2)); %Logical mask for the currently selected ROI
handles.cellMasksAll = false(size(handles.stack,1),size(handles.stack,2)); %3D array to store all cell masks
handles.save_names = {}; %Cell array of strings; filenames for save
handles.check_overwrite = true; %Check before overwriting file on save
handles.excludeROI = false; %Logical vector indicating excluded regions (excluded from neuropil and flagged in ROI file)
handles.neuropilf = {}; %Cell array for each cell's neuropil signal as a function of time
handles.npPoly = polyshape(); %Polygon vertices for the neuropil 'subtractmask' for each ROI polyshape

f_list = dir(fullfile(handles.save_dir,'*cell*.mat'));
for i = 1:numel(f_list) %Number of ROIs in data dir.
    idx = str2double(f_list(i).name(end-6:end-4)); %Get three-digit cell ID
    handles.save_names{idx} = f_list(i).name; %Populate cell array of save names
end

%--- GET PROJECTION ASSOCIATED WITH EACH SET OF AXES -----------------------
function img = getProjection(axisID, handles)

%Find active radio button and get white level for specified axis
if axisID == 1
    radioOn = find([handles.radiobutton_meanAxis1.Value,...
        handles.radiobutton_maxAxis1.Value,...
        handles.radiobutton_varAxis1.Value,...
        handles.radiobutton_redAxis1.Value]);
    whiteLevel = handles.slider_whiteLevelAxis1.Value; %White levels
else
    radioOn = find([handles.radiobutton_meanAxis2.Value,...
        handles.radiobutton_maxAxis2.Value,...
        handles.radiobutton_varAxis2.Value,...
        false]); %No reference on Axes 2 (right)
    whiteLevel = handles.slider_whiteLevelAxis2.Value; %White levels
end

%Get specified projection
switch radioOn
    case 1, img = handles.mean_proj;
    case 2, img = handles.max_proj;
    case 3, img = handles.var_proj;
    case 4
        shift = [-handles.slider_shiftY.Value handles.slider_shiftX.Value];
        img = circshift(handles.red_proj, shift);  %Apply translation if needed
end
%Adjust White Level
img = whiteLevel .* (img./max(img(:))) * 256; %Normalize to max pixel value; 256 shades (see handles.cmap)

%--- REFRESH AXES ---------------------------------------------------------
function refresh_Axis(axis_ID,handles) %axis_ID is a vector of integer values, range: (1:4).

ax = {'axes1','axes2','axes3','axes4'}; %Fieldnames for all axes in handles structure
currIdx = 0; %Current cell ID
for i = axis_ID %Set of int axes_IDs passed to function
    
    %For each axis
    cla(handles.(ax{i})); %Clear axes
    handles.(ax{i}).TickLength = [0.001 0.01];
    handles.(ax{i}).FontSize = 10;
    hold(handles.(ax{i}),'on'); %Hold on
    
    %Axes1 and Axes2 (FOV axes)
    if ismember(ax{i},{'axes1','axes2'})
        image(handles.(ax{i}),handles.img{i});  %Refresh image
        colormap(handles.(ax{i}),handles.cmap);
        axis(handles.(ax{i}),'off','equal','ij');

        if handles.checkbox_showROIs.Value
            %Refresh ROI patches
            for j = find(~cellfun(@isempty,handles.roi)) %Refresh saved ROIs
                roi = handles.roi{j};
                p = patch(handles.(ax{i}),'XData',roi(:,1),'YData',roi(:,2),...
                    'FaceColor','y','EdgeColor','none','FaceAlpha',0.2); %Display ROI on specified axes
                set(p,'ButtonDownFcn',{@selectROI,handles},...
                    'PickableParts','all','HitTest','on');
                if isequal(handles.roi{j},handles.curr_ROI)
                    p.FaceColor = 'r';                 %Highlight current ROI in red;
                    currIdx = j; %Currently selected cell ID
                    text(handles.axes1,1,3,'Right click to deselect current ROI.','Color','r');
                elseif handles.excludeROI(j)
                    p.FaceColor = 'k'; p.FaceAlpha = 0.5; %Excluded rois in black
                end
                %Make all others transparent while assigning longitudinal ROI
                if isfield(handles,'ref_fig') && isfield(handles.ref_fig,'figure')...
                        && isvalid(handles.ref_fig.figure)...
                        && ~isequal(handles.roi{j},handles.curr_ROI)
                    p.FaceAlpha = 0.05;
                end
            end
            if ~currIdx && ~isempty(handles.curr_ROI) %If newly drawn ROI
                patch(handles.(ax{i}),'XData',handles.curr_ROI(:,1),'YData',handles.curr_ROI(:,2),...
                    'FaceColor','r','EdgeColor','none','FaceAlpha',0.4); %Display ROI on specified axes
            end
            %Refresh neuropil masks if needed
            for j = find(~cellfun(@isempty,{handles.npPoly.Vertices})) %Refresh saved neuropil masks
                plot(handles.(ax{i}),handles.npPoly(j),...
                    'FaceColor','c','EdgeColor','none','FaceAlpha',0.2);
            end
        end
        
    elseif strcmp(ax{i},'axes3') %Refresh axes3 (dF/F plot)
        cellf = NaN(size(handles.stack,3),1);
        if ~isempty(handles.curr_cellf)
            cellf = handles.curr_cellf; 
            cellf = cellf - min(cellf); %Offset cellular fluorescence data by min(F) for approx dF/F0; F0 should be positive
        end
        
        plot(handles.axes3,(1:length(cellf)),... %Plot cell dF/F
            (cellf-median(cellf)) / median(cellf),'k','LineWidth',1);
        axis(handles.axes3,'tight');
        xlim(handles.axes3,[0 length(cellf)]);
        if currIdx && ~isempty(handles.neuropilf) %Plot neuropil signal as dF/F
            npf = handles.neuropilf{currIdx};
            plot(handles.axes3,(1:length(npf)),(npf-median(npf)) / median(cellf),'c'); %Same scale as cellF
        end
        
    elseif strcmp(ax{i},'axes4') %Refresh axes4 (Pearson's R histogram)
        %Nothing yet!
    end
end

%--- GET ROI VERTICES AND ASSOCIATED CELLULAR FLUORESCENCE -----------------
function [roi, cellf] = roiData(handles)

%Display current ROI as patch on left and right axes
bounds = bwboundaries(handles.cellMask); %Boundaries of logical mask for current ROI
roi = [bounds{1}(:,2) bounds{1}(:,1)]; %Boundary coordinates in ij

%Get cellF as mean per-pixel fluorescence and plot the dF/F on bottom panel
cellf = NaN(size(handles.stack,3),1);
for i=1:size(handles.stack,3)
    cellf(i) = sum(sum(handles.stack(:,:,i).*double(handles.cellMask))); %Pre-20018b syntax for back-compatibility
end
cellf = cellf/sum(sum(handles.cellMask));   %Per-pixel fluorescence

%--- SELECT ROI -------------------------------------------------------------
function selectROI(hObject,~,handles) %'eventdata' unused

handles = guidata(handles.figure1); %Update handles struct in case changed since object created.
for i=1:numel(handles.roi)
    if isequal(hObject.Vertices,handles.roi{i}), idx = i; end %Find the index of clicked ROI
end
radius = sqrt(polyarea(hObject.XData,hObject.YData)/pi); %Approximate radius

%Highlight current ROI
handles.curr_ROI = handles.roi{idx}; %Make these vertices the current ROI
handles.curr_cellf = handles.cellf{idx}; %Set corresponding cellF as current cellF
handles.edit_cellID.String = num2str(idx); %Make ROI idx current
handles.togglebutton_excludeROI.Value = handles.excludeROI(idx); %Update state of toggle button

%Update logical mask for current ROI
handles.cellMask = handles.cellMasksAll(:,:,idx); 

%Display approximate radius in pixels
R = ceil(radius*2)/2; %Radius with resolution of 0.5 pixels
handles.edit_circRadius.String = num2str(R); 

%Display distribution of mean pixel intensity for current ROI vs. surround
[Y,X] = find(handles.cellMasksAll(:,:,idx));
centroid.X = mean(X); 
centroid.Y = mean(Y);
R(1) = str2double(handles.edit_calcNeuropil_Ri.String); %Number of cell radii for inner diameter
R(2) = str2double(handles.edit_calcNeuropil_Ro.String); %Number of cell radii for outer diameter
for j = 1:2
    [X,Y] = meshgrid(1:size(handles.stack,2),1:size(handles.stack,1)); %Get grids within R(j) cell radii of centroid
    circle{j} = sqrt((X - centroid.X).^2 + (Y - centroid.Y).^2)...
        <= R(j) * radius;   %Inner or outer radius of annulus in units of cell radius
end
%Get logical masks for current ROI, all other ROIs, and surround
temp = true(size(handles.cellMasksAll,3),1);
temp(idx) = false; %Idx for all except current cell mask
otherCellMask = logical(sum(handles.cellMasksAll(:,:,temp),3)); %Mask for all saved ROIs except current
cellMask = handles.cellMasksAll(:,:,idx) & ~otherCellMask;
surroundMask = circle{2} & ~(circle{1} | cellMask | otherCellMask); %Mask for circular region surrounding ROI, excluding inner circle and somata mask

%Plot histogram of max pixel intensity
cla(handles.axes4);
hold(handles.axes4,'on');
F_cellMask = mean(handles.max_proj(cellMask)); %Grand mean fluorescence within current ROI
F_surround = handles.max_proj(surroundMask);   %Mean fluorescence for each pixel in surround
[counts,edges] = histcounts(F_surround);
bar(handles.axes4,edges(1:end-1),counts,'histc');
plot(handles.axes4,[F_cellMask F_cellMask],[0 1.1*max(counts)],'r','LineWidth',1);
text(handles.axes4,mean(xlim),max(ylim),{'Hist of max intensity for surrounding pixels';'line: current ROI'});

temp = [edges,F_cellMask];
rel_F = (F_cellMask - mean(F_surround))/mean(F_surround);
text(handles.axes4,max(temp),max(counts),num2str(rel_F,3));
xlim(handles.axes4,[min(temp),1.2*max(temp)]);
if sum(counts)>0
ylim(handles.axes4,[0,1.1*max(counts)]); %ylim set to 1.1 * maximum count
end
%-----------

%If checkbox 'Import prior ROIs' checked, popup figure with prior ROIs
if handles.checkbox_ImportROIs.Value
    cell_ID = sprintf('%03d',str2double(handles.edit_cellID.String)); %format of cell ID from .mat files, eg '004'
    width = 200;
    handles = refFig_priorROIs(cell_ID, width, handles); %Bring up figure with images of ROI from prior sessions
end

guidata(hObject,handles); %Save userdata
refresh_Axis((1:3),handles);  %Refresh left & right axes

%---RESIZE ROI-------------------------------------------------------------
function handles = resizeROI(handles,keypressed)
%Modify ROI by adding/subtracting pixels to top, bottom, right, left
if strcmp(keypressed,'uparrow')
    dir = 'post';
    val = true;
elseif strcmp(keypressed,'downarrow')
    dir = 'pre';
    val = false;
end

if isempty(handles.cellMask)
    [m,n,~] = size(handles.stack);
    BW = poly2mask(handles.curr_ROI(:,1),handles.curr_ROI(:,2),m,n);
else
    BW = handles.cellMask;
    top = (padarray(logical(diff(BW,1,1)),[1,0],0,dir)); %Find edges from TOP and set logical idx to 1
    bottom = (flip(padarray(logical(diff(flip(BW,1),1,1)),[1,0],0,dir),1)); %BOTTOM
    left = (padarray(logical(diff(BW,1,2)),[0,1],0,dir)); %LEFT
    right = (flip(padarray(logical(diff(flip(BW,2),1,2)),[0,1],0,dir),2)); %RIGHT
    BW(top|bottom|left|right) = val;
end
handles.cellMask = BW;
[handles.curr_ROI, handles.curr_cellf] = roiData(handles); %Store cellF and patch vertices in memory

%--- INCREMENT CELL_ID FOR SAVE -------------------------------------------
function [handles, idx] = nxtCellID(handles)

idx = find(cellfun(@isempty,handles.save_names),1,'first'); %Find first unused savename
if isempty(idx)
    idx = numel(handles.save_names)+1;
end
handles.edit_cellID.String = num2str(idx); %Set edit field for cell ID in GUI

%--- GENERATE ANNULUS REPRESENTING NEUROPIL MASK --------------------------
%Generate polygon representation of neuropil mask (graphics object)
function poly = getNpPoly(mask)
B = bwboundaries(mask);
warning('off','MATLAB:polyshape:repairedBySimplify');
if size(B,1)==1 %Eg if annulus is interrupted and has no holes
    poly = polyshape(B{1}(:,2),B{1}(:,1)); %X-,Y-coordinates
else
    nPoints = cellfun(@(C) size(C,1),B)'; %Number of points in each polygon
    start_idx = cumsum([0 nPoints+1])+1; %Starting idx for each series of points (series separated by NaN)
    X = NaN(sum(nPoints)+numel(nPoints)-1,1); %Initialize vector with space for NaN between each series of points
    Y = X;
    for i=1:numel(nPoints)
        X(start_idx(i):start_idx(i)+nPoints(i)-1) = B{i}(:,2);
        Y(start_idx(i):start_idx(i)+nPoints(i)-1) = B{i}(:,1);
    end
    poly = polyshape(X,Y);
end

%--- SAVE FULL FOV REFERENCE IMAGE WITH ROIS ------------------------------
%   -Can be used eg for longitudinal imaging
function saveRefImg(handles)
%Plot all ROIs
f = figure('Visible','off','Position',[100, 100, size(handles.stack,1), size(handles.stack,2)]);
ax = copyobj(handles.axes2,f); 
ax.YLim = [0 size(handles.stack,1)];
ax.XLim = [0 size(handles.stack,2)]; 
%Label with cellIDs
for i = 1:numel(handles.save_names)
    if isempty(handles.save_names{i}) 
        continue 
    else
    saveNum = join(string(regexp(handles.save_names{i},'\d','match')),'');
    pos = mean(handles.roi{i}); 
    text(pos(1),pos(2),saveNum,"HorizontalAlignment","center","Color",'c');
    end
end
%Write image to file
set(ax,'Units','pixels','Position',[0, 0, ax.YLim(2), ax.XLim(2)],'LooseInset',[0,0,0,0]);
img = getframe(ax);
imwrite(img.cdata,fullfile(handles.save_dir,'ROI_Image.tif'),'tif');

%--------------------------------------------------------------------------
%--- SPECIALIZED FUNCTIONS FOR LONGITUDINAL IMAGING -----------------------
%--------------------------------------------------------------------------

% (Please see documentation for how to use these features.)

%--- TRANSFER ROIS FROM ADDITIONAL SESSION(S) -----------------------------
%ROI dir(s) to load must be in same directory as current ROI dir.
function handles = transferROIs(data_dir,handles)

subject_ID = char(inputdlg('Enter search filter (eg experimental subject ID).','Find Prior ROIs')); %User enters subject name, or other string to use as filter for dirs to search

temp = dir(fullfile(data_dir,['*' subject_ID '*']));
for i = 1:numel(temp)
    dirs.sessions{i} = fullfile(data_dir,temp(i).name);
end

% MAT file to save all ROIs from a given subject
handles.masterROIs_filename = fullfile(data_dir,['master_rois_' subject_ID '.mat']); %Master ROI file

for i=1:numel(dirs.sessions)
    temp = dir(fullfile(dirs.sessions{i},'ROI*.tif'));
    temp = temp(temp.isdir); %Get only the directories
    if ~isempty(temp)
        dirs.roi{i} = fullfile(dirs.sessions{i},temp.name);
    end
end

%Call getPriorROIs() to aggregate all ROIs from previous sessions
roiData = getPriorROIs(dirs.roi,handles.masterROIs_filename);
cell_IDs = unique(roiData.cell_ID);

%Load first chronological instance of each ROI
disp(['Loading ' num2str(numel(cell_IDs)) ' ROIs saved from previous sessions...']);
for i = 1:numel(cell_IDs)
    temp_idx = find(ismember(roiData.cell_ID, cell_IDs{i})); %All indices from masterfile for current cell
    save_name = strcat('cell', cell_IDs{i}, '.mat');
    
    %ROIs from first session in which identified (unless excluded)
    idx = temp_idx(find(~cellfun(@isempty,roiData.cellf(temp_idx)),1,'first')); 
    if ~exist(fullfile(handles.save_dir, save_name),'file') && ~isempty(idx)
        S = struct('cellf', [], 'bw', roiData.bw{idx}); %Store cell mask and dummy var for cellf in a structure
        save(fullfile(handles.save_dir, save_name),'-struct','S'); %Save as eg 'cell004'
    end
end

%Get all ROIs from previous sessions
function roiData = getPriorROIs( roi_dirs, master_filename ) %Direct copy of getMasterROIs.m

nROIs = 0; %Initialize counter
for i = 1:numel(roi_dirs)
    file_list = dir(fullfile(roi_dirs{i},'*cell*.mat'));
    
    for j = 1:numel(file_list)
        S = load(fullfile(roi_dirs{i},file_list(j).name));
        fields = fieldnames(S);
        for k = 1:numel(fields)
            roiData.(fields{k}){nROIs+1} = S.(fields{k});
        end
        [startIdx,endIdx] = regexp(file_list(j).name,'cell\d{3}');
        roiData.cell_ID{nROIs+1} = file_list(j).name(startIdx+4:endIdx);
        
        [~,name,ext] = fileparts(roi_dirs{i});
        temp = strjoin({name,ext},'');
        roiData.fname_stack{nROIs+1} = temp(5:end); %Remove prefix: 'ROI_'
        nROIs = nROIs+1;
    end
end

if isfile(master_filename)
    save(master_filename,'-STRUCT','roiData','-append');
else, save(master_filename,'-STRUCT','roiData');
end

%--- CREATE REFERENCE IMAGES FROM PRIOR ROIS ------------------------------
% Generate interactive figure containing reference images from prior sessions
function handles = refFig_priorROIs( cell_ID, width, handles )

%Clear any prior reference figure
handles = delete_refFig(handles); 

%Retrieve image segment from each prior session containing ROI
load(handles.masterROIs_filename,'frameSegment','bw'); %frameSegment is a struct generated by script screenROIs.m

if ~exist('frameSegment') %Alert Message
    warndlg('No reference image for current ROI. Always update longitudinal data by running the script "screenROIs.m" before starting a new ROI selection session.','Warning');
    return
end

idx = find(strcmp({frameSegment.cell_ID}, cell_ID),1,'first'); %cell_ID = '001'
frameSegment = frameSegment(idx); %Abridge struct to include only current cell
[nY,~] = size(bw{1});

%Warn if ROI not found in prior sessions
if isempty(idx)
    warning('No prior sessions found containing this cell_ID. Check directory structure, then run script "screenROIs.m" to obtain reference images.');
    return
end

%Figure position
Y = frameSegment.centroid{1}(2);
if Y < 0.5*nY
    fig_pos = [100,100,width,width];
else fig_pos = [100,800,width,width];
end

%Image ROI and surrounding pixels for each session
handles.ref_fig = frameSegment; %Store frames to advance on mouse click
handles.ref_fig.curr_idx = 1; %Initialize image index
handles.ref_fig.end_idx = numel(frameSegment.pix); %Idx of last session (chronological)

fig = figure('Visible','on','NumberTitle','off','WindowStyle','normal'); %Create figure window
fig.Position = fig_pos;
fig.MenuBar = 'none';
fig.ToolBar = 'none';
fig.Name = 'Reference Image';
handles.ref_fig.figure = fig; %Store figure for later reference

handles.ref_fig.figure.WindowButtonDownFcn =...
    {@plotROI_refFig,handles}; %On mouse click, create ROI ref image from next session
handles.ref_fig.figure.WindowKeyPressFcn =...
    {@refocus_mainFig,handles}; %Focus on main GUI window if user presses a key
handles.ref_fig.figure.CloseRequestFcn =...
    {@closeReq_refFig,handles}; %Focus on main GUI window if user presses a key

plotROI_refFig([],[],handles);
txt_y = size(frameSegment.pix{1},1) - 3; %y-position of message
text(1,txt_y,{'Left click on image'; 'advances to next session.'},'Color','r'); %First frame displays message

%Generate reference image for current ROI
function plotROI_refFig(~,~,handles)

idx = handles.ref_fig.curr_idx;
cla; 
imagesc(handles.ref_fig.pix{idx}); hold on
plot(handles.ref_fig.roi{idx}(:,1),...
    handles.ref_fig.roi{idx}(:,2),'r');
text(1,3,handles.ref_fig.date{idx}); %Tag img with session date

ax = gca; 
ax.Position = [0,0,1,1]; %Eliminate white space
ax.YTickLabel = []; ax.XTickLabel = [];
axis square;

%Increment session index
i = handles.ref_fig.curr_idx;
if i < handles.ref_fig.end_idx
    i = i+1;
else
    i = 1;
end
handles.ref_fig.curr_idx = i;
handles.ref_fig.figure.WindowButtonDownFcn = {@plotROI_refFig,handles}; %Update ButtonDownFcn

function refocus_mainFig(~,eventdata,handles)
figure(handles.figure1);
handles = guidata(handles.figure1);
figure1_WindowKeyPressFcn(handles.figure1,eventdata,handles);

function closeReq_refFig(~,~,handles)
handles = guidata(handles.figure1);
delete(handles.ref_fig.figure);
handles = rmfield(handles,'ref_fig');
%handles = delete_refFig(handles); %Close ref fig
refresh_Axis(1:2,handles);

function handles = delete_refFig(handles)
%Clear any prior reference figure
if isfield(handles,'ref_fig') && isfield(handles.ref_fig,'figure')
    if isvalid(handles.ref_fig.figure)
        handles.ref_fig.figure.CloseRequestFcn =...
            {@closeReq_refFig,handles}; %Update handles before close request.
        delete(handles.ref_fig.figure);
    end
    handles = rmfield(handles,'ref_fig');
end

%--------------------------------------------------------------------------
%--------------------------------------------------------------------------



