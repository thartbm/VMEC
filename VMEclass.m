function varargout = VMEclass(varargin)
%VMECLASS M-file for VMEclass.fig
%      VMECLASS, by itself, creates a new VMECLASS or raises the existing
%      singleton*.
%
%      H = VMECLASS returns the handle to a new VMECLASS or the handle to
%      the existing singleton*.
%
%      VMECLASS('Property','Value',...) creates a new VMECLASS using the
%      given property value pairs. Unrecognized properties are passed via
%      varargin to VMEclass_OpeningFcn.  This calling syntax produces a
%      warning when there is an existing singleton*.
%
%      VMECLASS('CALLBACK') and VMECLASS('CALLBACK',hObject,...) call the
%      local function named CALLBACK in VMECLASS.M with the given input
%      arguments.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help VMEclass

% Last Modified by GUIDE v2.5 12-Feb-2014 15:32:53

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @VMEclass_OpeningFcn, ...
                   'gui_OutputFcn',  @VMEclass_OutputFcn, ...
                   'gui_LayoutFcn',  [], ...
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


% --- Executes just before VMEclass is made visible.
function VMEclass_OpeningFcn(hObject, eventdata, handles, varargin)
global cfg
global editor
global NumTarg

% editor
NumTarg = 1;
current_targ = 1;
% editor = 0;
if editor == 1;
    if iscell(cfg.target) ~= 1
    %         disp('Please load a file to edit')
        cfg.target = cell(1);
        cfg.target{1,1}.trials = 0;
        cfg.target{1,1}.angle_locate = 0;
        cfg.target{1,1}.targ_dist = 1;
        cfg.target{1,1}.rot_degree = 0; 
        cfg.target{1,1}.rot_direct = 0;
        NumTarg = 1;
    else
        total_trials = 0;
        MaxTarg = size(cfg.target, 1);
        NumTarg = MaxTarg;
        set(handles.Taskname_textbox, 'String', cfg.TaskName)
        set(handles.NumTarg_popmenu, 'Value', MaxTarg)
        set(handles.Feedtype_popmenu, 'String', {'Cursor','No Cursor'})
        if strcmp(cfg.Feed_type, 'Cursor') == 1
            set(handles.Feedtype_popmenu, 'Value', 1)
        elseif strcmp(cfg.Feed_type, 'No_Cursor') == 1
            set(handles.Feedtype_popmenu, 'Value', 2)
        end
    
    set(handles.Total_trial_popmenu, 'Value', NumTarg);
    set(handles.Max_range_popmenu, 'String', 40:5:140);
    set(handles.Min_range_popmenu, 'String', 40:5:140);
    set(handles.Targ_dist_popmenu, 'String', 50:10:100);
    set(handles.Rot_deg_popmenu, 'String', [0, 30, 45, 60, 75])
    
  
    
%     (cfg.target{1,1}.trials + 10)/10
    for i = 1:NumTarg
%         cfg.target{NumTarg,1}.trials
        total_trials = total_trials + cfg.target{i,1}.trials;        
    end
    set(handles.Total_trial_popmenu, 'Value', (total_trials + 10)/10);
    set(handles.Max_range_popmenu, 'Value', ((cfg.max_angle - 35)/5));
    set(handles.Min_range_popmenu, 'Value', ((cfg.min_angle - 35)/5));
    set(handles.Targ_dist_popmenu, 'Value', round((cfg.target{1,1}.targ_dist - 0.4) * 10));
    
    if cfg.target{1,1}.rot_degree == 0
        set(handles.Rot_deg_popmenu, 'Value', 1)
    else
        set(handles.Rot_deg_popmenu, 'Value', (cfg.target{1,1}.rot_degree - 15)/15 + 1);
    end
    
    if cfg.target{1,1}.rot_direct == 0
        set(handles.Rot_direct_popmenu, 'Value', 1)
        set(handles.Rot_direct_popmenu, 'String', 'None')
    elseif cfg.target{1,1}.rot_direct == -1
        set(handles.Rot_direct_popmenu, 'Value', 1)
        set(handles.Rot_direct_popmenu, 'String', {'Clockwise', 'Counterclockwise'})
    elseif cfg.target{1,1}.rot_direct == 1
        set(handles.Rot_direct_popmenu, 'Value', 2)
        set(handles.Rot_direct_popmenu, 'String', {'Clockwise', 'Counterclockwise'})
    end
    
    if strcmp(cfg.Rot_type, 'Abrupt') == 1
        set(handles.Rot_type_popmenu, 'Value', 1)
        set(handles.Rot_type_popmenu, 'String', {'Abrupt', 'Gradual'})
    elseif strcmp(cfg.Rot_type, 'Gradual') == 1
        set(handles.Rot_type_popmenu, 'Value', 2)
        set(handles.Rot_type_popmenu, 'String', {'Abrupt', 'Gradual'})
    elseif strcmp(cfg.Rot_type, 'None') == 1
        set(handles.Rot_type_popmenu, 'Value', 1)
        set(handles.Rot_type_popmenu, 'String', 'None')
    end
    end
end
editor = 1;

% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   unrecognized PropertyName/PropertyValue pairs from the
%            command line (see VARARGIN)

% Choose default command line output for VMEclass
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes VMEclass wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = VMEclass_OutputFcn(hObject, eventdata, handles)
global cfg
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in Done_pushbutton.
function Done_pushbutton_Callback(hObject, eventdata, handles)
global cfg
global NumTarg
global editdone
% hObject    handle to Done_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% cfg
if cfg.target{1,1}.trials == 0
    disp('Please complete variables for a workable experiment!')
else


cfg.TaskName = get(handles.Taskname_textbox, 'String');
if NumTarg ~= 0;
    for DelTarg = 1:size(cfg.target,1)
        if DelTarg > NumTarg
            cfg.target{DelTarg,1} = [];
        end
    end
else
     cfg.target = 'None';   
end
if strcmp(cfg.target, 'None') ~= 1;
    cfg.target = cfg.target(~cellfun('isempty',cfg.target));
end
% Set variables for each target
for i = 1:NumTarg
    cfg.target{i,1}.targ_dist = cfg.target{1,1}.targ_dist;
    cfg.target{i,1}.rot_degree = cfg.target{1,1}.rot_degree;
    cfg.target{i,1}.rot_direct = cfg.target{1,1}.rot_direct;
end


% Calculation for angle of each target
angle_range = cfg.max_angle - cfg.min_angle;
if NumTarg < 2
    cfg.target{1,1}.angle_locate = angle_range/2 + cfg.min_angle;
elseif NumTarg == 2
        cfg.target{1,1}.angle_locate = cfg.min_angle;
        cfg.target{2,1}.angle_locate = cfg.max_angle;
else    
    angle_per_targ = angle_range/(NumTarg-1);
    cfg.target{1,1}.angle_locate = cfg.min_angle;
    for i = 2:(NumTarg-1)
        cfg.target{i,1}.angle_locate = cfg.min_angle + (angle_per_targ * (i-1));
    end
    cfg.target{NumTarg,1}.angle_locate = cfg.max_angle;
end
% cfg
editdone = cell(1);
close(handles.figure1);
Visuomotor
end
% --- Executes on selection change in Rot_deg_popmenu.
function Rot_deg_popmenu_Callback(hObject, eventdata, handles)
global cfg
% hObject    handle to Rot_deg_popmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
rot_deg = get(hObject, 'Value') - 1;
if rot_deg == 0;
    cfg.target{1,1}.rot_degree = 0;
    cfg.target{1,1}.rot_direct = 0;
    cfg.Rot_type = 'None';
else
    cfg.target{1,1}.rot_degree = rot_deg * 15 + 15;
    cfg.target{1,1}.rot_direct = -1;
    cfg.Rot_type = 'Abrupt';
    set(handles.Feedtype_popmenu, 'Value', 1);
    cfg.Feed_type = 'Cursor';
end
if rot_deg == 0;
    set(handles.Rot_direct_popmenu, 'Value', 1);
    set(handles.Rot_type_popmenu, 'Value', 1);
    set(handles.Rot_direct_popmenu, 'String', 'None')
    set(handles.Rot_type_popmenu, 'String', 'None')
else
    if cfg.total_trials < (rot_deg * 15 + 15)
        set(handles.Rot_direct_popmenu, 'String', {'Clockwise', 'Counterclockwise'})
        set(handles.Rot_type_popmenu, 'Value', 1);
        set(handles.Rot_type_popmenu, 'String', 'Abrupt')
    else
        set(handles.Rot_direct_popmenu, 'String', {'Clockwise', 'Counterclockwise'})
        set(handles.Rot_type_popmenu, 'String', {'Abrupt', 'Gradual'})
    end
end
% cfg.target{1,1}.rot_degree
% cfg.target{1,1}.rot_direct

% Hints: contents = cellstr(get(hObject,'String')) returns Rot_deg_popmenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from Rot_deg_popmenu


% --- Executes during object creation, after setting all properties.
function Rot_deg_popmenu_CreateFcn(hObject, eventdata, handles)
global cfg
% hObject    handle to Rot_deg_popmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
set(hObject, 'String', [0, 30, 45, 60, 75]);
% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in Rot_direct_popmenu.
function Rot_direct_popmenu_Callback(hObject, eventdata, handles)
global cfg
% hObject    handle to Rot_direct_popmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if get(hObject, 'Value') == 1;
    if strcmp(get(hObject, 'String'), 'None') == 1;
        cfg.target{1,1}.rot_direct = 0;
    else
        cfg.target{1,1}.rot_direct = -1;
    end
elseif get(hObject, 'Value') == 2;
    cfg.target{1,1}.rot_direct = 1;
end
% cfg.target{1,1}.rot_direct
% Hints: contents = cellstr(get(hObject,'String')) returns Rot_direct_popmenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from Rot_direct_popmenu


% --- Executes during object creation, after setting all properties.
function Rot_direct_popmenu_CreateFcn(hObject, eventdata, handles)
global cfg
% hObject    handle to Rot_direct_popmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
set(hObject, 'String', 'None');
% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in Rot_type_popmenu.
function Rot_type_popmenu_Callback(hObject, eventdata, handles)
global cfg
% hObject    handle to Rot_type_popmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if get(hObject, 'Value') == 1;
    if strcmp(get(hObject, 'String'),'None') == 1;
        cfg.Rot_type = 'None';
    else
        cfg.Rot_type = 'Abrupt';
    end
elseif get(hObject, 'Value') == 2;
    cfg.Rot_type = 'Gradual';
end
% cfg.Rot_type
% Hints: contents = cellstr(get(hObject,'String')) returns Rot_type_popmenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from Rot_type_popmenu


% --- Executes during object creation, after setting all properties.
function Rot_type_popmenu_CreateFcn(hObject, eventdata, handles)
global cfg
% hObject    handle to Rot_type_popmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
set(hObject, 'String', 'None');
% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in Max_range_popmenu.
function Max_range_popmenu_Callback(hObject, eventdata, handles)
global cfg
% hObject    handle to Max_range_popmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if get(hObject, 'Value') == 1 && strcmp(get(hObject, 'String'), 'None') == 1;
%     cfg.target{1,1}.angle_locate = [];
else
    cfg.max_angle = (get(hObject, 'Value') * 5 + 35 );
%     cfg.max_angle
end
% Hints: contents = cellstr(get(hObject,'String')) returns Max_range_popmenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from Max_range_popmenu


% --- Executes during object creation, after setting all properties.
function Max_range_popmenu_CreateFcn(hObject, eventdata, handles)
global cfg
% hObject    handle to Max_range_popmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
set(hObject, 'String', 40:5:140);
set(hObject, 'Value', 21);
% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in Targ_dist_popmenu.
function Targ_dist_popmenu_Callback(hObject, eventdata, handles)
global cfg
% hObject    handle to Targ_dist_popmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

cfg.target{1,1}.targ_dist = get(handles.Targ_dist_popmenu, 'Value')/10 + 0.4;
% cfg.target{1,1}.targ_dist
% Hints: contents = cellstr(get(hObject,'String')) returns Targ_dist_popmenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from Targ_dist_popmenu


% --- Executes during object creation, after setting all properties.
function Targ_dist_popmenu_CreateFcn(hObject, eventdata, handles)
global cfg
% hObject    handle to Targ_dist_popmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
set(hObject, 'String', 50:10:100);
set(hObject, 'Value', 6);  % to change the default value to 100  - AT

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in Min_range_popmenu.
function Min_range_popmenu_Callback(hObject, eventdata, handles)
global cfg
% hObject    handle to Min_range_popmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if get(hObject, 'Value') == 1 && strcmp(get(hObject, 'String'), 'None') == 1;
%     cfg.target{1,1}.angle_locate = [];
else
    cfg.min_angle = (get(hObject, 'Value') * 5 + 35);
%     cfg.min_angle
end
% Hints: contents = cellstr(get(hObject,'String')) returns Min_range_popmenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from Min_range_popmenu


% --- Executes during object creation, after setting all properties.
function Min_range_popmenu_CreateFcn(hObject, eventdata, handles)
global cfg
% hObject    handle to Min_range_popmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
set(hObject, 'String', 40:5:140);

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in NumTarg_popmenu.
function NumTarg_popmenu_Callback(hObject, eventdata, handles)
global cfg
global NumTarg
% hObject    handle to NumTarg_popmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

NumTarg = get(hObject, 'Value');
if NumTarg == 1
    TrialCounter = 3;
elseif NumTarg == 2 
    TrialCounter = 4;
else 
    TrialCounter = NumTarg;
end
set(handles.Total_trial_popmenu, 'String', 0:TrialCounter:200);

for MaxTarg = 1:NumTarg
    if MaxTarg > size(cfg.target,1)
        cfg.target{MaxTarg,1}.trials = 0;
        cfg.target{MaxTarg,1}.angle_locate = 0;
        cfg.target{MaxTarg,1}.targ_dist = 1;
        cfg.target{MaxTarg,1}.rot_degree = 0;
        cfg.target{MaxTarg,1}.rot_direct = 0;
    end
end
cfg.Feed_type = 'Cursor';

if cfg.total_trials > 0;
    total_trials = cfg.total_trials;
    target_trials = floor(total_trials / NumTarg);
    for MaxTarg = 1:NumTarg
        cfg.target{MaxTarg, 1}.trials = target_trials;
    end
    extra_trial = rem(total_trials, NumTarg);
    if extra_trial > 0
        for a = 1:extra_trial
            cfg.target{a,1}.trials = cfg.target{a,1}.trials + 1;
%         cfg.target{a,1}.trials
        end
    end
end
% Hints: contents = cellstr(get(hObject,'String')) returns NumTarg_popmenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from NumTarg_popmenu


% --- Executes during object creation, after setting all properties.
function NumTarg_popmenu_CreateFcn(hObject, eventdata, handles)
global cfg
global NumTarg
% hObject    handle to NumTarg_popmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
set(hObject, 'String', 1:1:11);
% NumTarg = 1
% cfg.target{1,1}.trials = 0;
% cfg.target{1,1}.angle_locate = 0;
% cfg.target{1,1}.targ_dist = 0.5;
% cfg.target{1,1}.rot_degree = 0;
% cfg.target{1,1}.rot_direct = 0;

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Taskname_textbox_Callback(hObject, eventdata, handles)
global cfg
% hObject    handle to Taskname_textbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Taskname_textbox as text
%        str2double(get(hObject,'String')) returns contents of Taskname_textbox as a double


% --- Executes during object creation, after setting all properties.
function Taskname_textbox_CreateFcn(hObject, eventdata, handles)
global cfg
% hObject    handle to Taskname_textbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in Feedtype_popmenu.
function Feedtype_popmenu_Callback(hObject, eventdata, handles)
global cfg
global NumTarg
% hObject    handle to Feedtype_popmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if get(hObject, 'Value') == 1;
    cfg.Feed_type = 'Cursor';
elseif get(hObject, 'Value') == 2;
    cfg.Feed_type = 'No_Cursor';
    set(handles.Rot_deg_popmenu, 'Value', 1)
    set(handles.Rot_direct_popmenu, 'Value', 1)
    set(handles.Rot_direct_popmenu, 'String', 'None')
    set(handles.Rot_type_popmenu, 'Value', 1)
    set(handles.Rot_type_popmenu, 'String', 'None')
    cfg.Rot_type = 'None';
    for i = 1:NumTarg
        cfg.target{i,1}.rot_degree = 0;
        cfg.target{i,1}.rot_direct = 0;
    end
end
% cfg.Feed_type

% Hints: contents = cellstr(get(hObject,'String')) returns Feedtype_popmenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from Feedtype_popmenu


% --- Executes during object creation, after setting all properties.
function Feedtype_popmenu_CreateFcn(hObject, eventdata, handles)
global cfg
% hObject    handle to Feedtype_popmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
set(hObject, 'String', {'Cursor', 'No Cursor'});

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in Total_trial_popmenu.
function Total_trial_popmenu_Callback(hObject, eventdata, handles)
global cfg
global NumTarg
% hObject    handle to Total_trial_popmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
mytrials =  (get(hObject, 'String'));
total_trials = str2double(mytrials((get(hObject, 'Value')),:));
cfg.total_trials = total_trials;
if cfg.target{1,1}.rot_degree ~= 0;
    if cfg.total_trials >= cfg.target{1,1}.rot_degree
        set(handles.Rot_direct_popmenu, 'String', {'Clockwise', 'Counterclockwise'})
        set(handles.Rot_type_popmenu, 'String', {'Abrupt', 'Gradual'})
    else
        set(handles.Rot_direct_popmenu, 'String', {'Clockwise', 'Counterclockwise'})
        set(handles.Rot_type_popmenu, 'String', 'Abrupt')
        set(handles.Rot_type_popmenu, 'Value', 1);
        cfg.Rot_type = 'Abrupt';
    end
end
target_trials = floor(total_trials / NumTarg);
for MaxTarg = 1:NumTarg
cfg.target{MaxTarg, 1}.trials = target_trials;
end
%extra_trial = rem(total_trials, NumTarg);
%if extra_trial > 0
%    for a = 1:extra_trial
%        cfg.target{a,1}.trials = cfg.target{a,1}.trials + 1;
%         cfg.target{a,1}.trials
%    end
%end
% Hints: contents = cellstr(get(hObject,'String')) returns Total_trial_popmenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from Total_trial_popmenu


% --- Executes during object creation, after setting all properties.
function Total_trial_popmenu_CreateFcn(hObject, eventdata, handles)
global cfg
% hObject    handle to Total_trial_popmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

set(hObject, 'String', 0:10:200);

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
