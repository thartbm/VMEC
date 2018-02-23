function varargout = Visuomotor(varargin)
% VISUOMOTOR MATLAB code for Visuomotor.fig
%      VISUOMOTOR, by itself, creates a new VISUOMOTOR or raises the existing
%      singleton*.
%
%      H = VISUOMOTOR returns the handle to a new VISUOMOTOR or the handle to
%      the existing singleton*.
%
%      VISUOMOTOR('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in VISUOMOTOR.M with the given input arguments.
%
%      VISUOMOTOR('Property','Value',...) creates a new VISUOMOTOR or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Visuomotor_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Visuomotor_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Visuomotor
% Last Modified by GUIDE v2.5 07-Oct-2014 12:35:24

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Visuomotor_OpeningFcn, ...
                   'gui_OutputFcn',  @Visuomotor_OutputFcn, ...
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



% --- Executes just before Visuomotor is made visible.
function Visuomotor_OpeningFcn(hObject, eventdata, handles, varargin)
global cfg
global editor
global loader
global fileload
global editdone



warning('off');
cfg.taskdir = 'Task/';
mkdir(cfg.taskdir)
warning('on');

if iscell(editdone) == 1
%     disp('Edit is done')
else
    fileload = 0;
end
loader = 0;
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Visuomotor (see VARARGIN)
if editor == 1;
    set(handles.Task_Name_Text, 'String', cfg.TaskName);
    if iscell(cfg.target) == 0
        set(handles.Num_Targ_Text, 'String', cfg.target);
    else
        set(handles.Num_Targ_Text, 'String', size(cfg.target));
    end
    set(handles.Rot_Type_Text, 'String', cfg.Rot_type);
    set(handles.Feedback_Type_Text, 'String', cfg.Feed_type);
    uitable_data = [];
    if iscell(cfg.target) == 1
        for i = 1:size(cfg.target,1)    
            uitable_data = [uitable_data; cfg.target{i,1}.trials, cfg.target{i,1}.angle_locate, cfg.target{i,1}.targ_dist, cfg.target{i,1}.rot_degree, cfg.target{i,1}.rot_direct]; 
        end
        set(handles.Target_Info_Table, 'Data', uitable_data);
    else
        set(handles.Target_Info_Table, 'Data', []);
    end
end

% cfg.subject_id = '';
% cfg.windowSize = [0 0 1024 768];
% cfg.TaskName = 'None';
% cfg.Rot_type = 'None';
% cfg.Feed_type = 'None';
% for MaxTarg = 1:8
%     cfg.target{MaxTarg,1}.trials = 0;
%     cfg.target{MaxTarg,1}.angle_locate = 0;
%     cfg.target{MaxTarg,1}.targ_dist = 0;
%     cfg.target{MaxTarg,1}.rot_degree = 0;
%     cfg.target{MaxTarg,1}.rot_direct = 0;
% end
% cfg
% afg = cfg


% Choose default command line output for Visuomotor
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Visuomotor wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = Visuomotor_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% disp('hi');

% Get default command line output from handles structure
varargout{1} = handles.output;



function Input_ID_Textbox_Callback(hObject, eventdata, handles)
% hObject    handle to Input_ID_Textbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
cfg.subject_id = get(hObject, 'String');

% Hints: get(hObject,'String') returns contents of Input_ID_Textbox as text
%        str2double(get(hObject,'String')) returns contents of Input_ID_Textbox as a double


% --- Executes during object creation, after setting all properties.
function Input_ID_Textbox_CreateFcn(hObject, eventdata, handles)
global cfg
% hObject    handle to Input_ID_Textbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
set(hObject, 'String', 'Input Subject ID')
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Run_Task_Button.
function Run_Task_Button_Callback(hObject, eventdata, handles)
global cfg
cfg.subject_id = get(handles.Input_ID_Textbox, 'String');
current_task = cfg.TaskName;
if strcmp(cfg.subject_id,'Input Subject ID') == 1;
    disp('Please Input a Subject ID')
else
    if iscell(cfg.target) == 1;
        save(cfg.TaskName, 'cfg')
        runStimulus(current_task)
        delete([current_task, '.mat'])
        clc; disp('End of Experiment');
    else
        disp('Experiment variables incomplete')
        disp('Unable to run experiment')
    end
end
% hObject    handle to Run_Task_Button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
cfg.subject_id = get(handles.Input_ID_Textbox, 'String');
% clc
% cfg

% --- Executes on selection change in Task_Listbox.
function Task_Listbox_Callback(hObject, eventdata, handles)
global cfg
global Select_List
global loader
% hObject    handle to Task_Listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
loader = 1;
cfg.taskdir = 'Task/';
directory = dir(sprintf('%s%s',cfg.taskdir, '*.mat'));
List = {directory.name};
set(handles.Task_Listbox, 'String', List);
if get(hObject, 'Value') <= length(get(hObject, 'String'));
    Select_List = get(hObject, 'String');
    Select_List = Select_List(get(hObject, 'Value'));
    Select_List = cell2mat(Select_List);
else
    set(hObject, 'Value', 1)
end


% Hints: contents = cellstr(get(hObject,'String')) returns Task_Listbox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from Task_Listbox


% --- Executes during object creation, after setting all properties.
function Task_Listbox_CreateFcn(hObject, eventdata, handles)
global cfg
% hObject    handle to Task_Listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

%% THIS CHECKS THE DIRECTORY FOR EXISTING MATLAB FILES CONTAINING TASK INFORMATION
cfg.taskdir = 'Task/';
directory = dir(sprintf('%s%s',cfg.taskdir, '*.mat'));
List = {directory.name};
set(hObject, 'String', List);

%%


% guidata(hObject, handles.output)



% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Create_Button.
function Create_Button_Callback(hObject, eventdata, handles)
warning off
clear all
warning on
global cfg
global editor

cfg.subject_id = '';
cfg.windowSize = [0 0 0 0];
cfg.TaskName = 'None';
cfg.Rot_type = 'None';
cfg.Feed_type = 'None';
cfg.max_angle = 140;
cfg.min_angle = 40;
cfg.total_trials = 0;
% cfg.target = 'None';
for MaxTarg = 1:11
    cfg.target{MaxTarg,1}.trials = 0;
    cfg.target{MaxTarg,1}.angle_locate = 0;
    cfg.target{MaxTarg,1}.targ_dist = 1;
    cfg.target{MaxTarg,1}.rot_degree = 0;
    cfg.target{MaxTarg,1}.rot_direct = 0;
end

editor = 0;
VMEclass
% hObject    handle to Create_Button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in Load_Button.
function Load_Button_Callback(hObject, eventdata, handles)
global cfg
global Select_List
global loader
global fileload

if loader == 1
    load(sprintf('%s%s',cfg.taskdir,Select_List(1:end-4)));
    fileload = 1;
    set(handles.Task_Name_Text, 'String', cfg.TaskName);
    set(handles.Num_Targ_Text, 'String', size(cfg.target));
    set(handles.Rot_Type_Text, 'String', cfg.Rot_type);
    set(handles.Feedback_Type_Text, 'String', cfg.Feed_type);
    uitable_data = [];
    if iscell(cfg.target) == 1
        for i = 1:size(cfg.target,1)    
            uitable_data = [uitable_data; cfg.target{i,1}.trials, cfg.target{i,1}.angle_locate, cfg.target{i,1}.targ_dist, cfg.target{i,1}.rot_degree, cfg.target{i,1}.rot_direct]; 
        end
        set(handles.Target_Info_Table, 'Data', uitable_data);
    end
else
    disp('Please select a file to load')
end
    

% hObject    handle to Load_Button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in Save_Button.
function Save_Button_Callback(hObject, eventdata, handles)
global cfg

if isfield(cfg,'target') == 1
    if iscell(cfg.target) == 1
        save(sprintf('%s%s',cfg.taskdir,cfg.TaskName),'cfg');
    %     save(cfg.TaskName, 'cfg')
        directory = dir(sprintf('%s%s',cfg.taskdir, '*.mat'));
        List = {directory.name};
        set(handles.Task_Listbox, 'String', List);
    else
        disp('Incomplete Task')
    end
else
    disp('There is no data to save')
end
% hObject    handle to Save_Button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in Edit_Button.
function Edit_Button_Callback(hObject, eventdata, handles)
global cfg
global editor
global fileload

if fileload == 0;
    disp('Please load a file to edit')
% elseif cfg.target == 'None';
%     disp('Please load a file to edit')
else
    editor = 1;
    VMEclass
end
% hObject    handle to Edit_Button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in Info_Button.
function Info_Button_Callback(hObject, eventdata, handles)
VMEinfo
% hObject    handle to Info_Button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on key press with focus on Target_Info_Table and none of its controls.
function Target_Info_Table_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to Target_Info_Table (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)
