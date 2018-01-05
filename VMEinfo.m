function varargout = VMEinfo(varargin)
% VMEINFO MATLAB code for VMEinfo.fig
%      VMEINFO, by itself, creates a new VMEINFO or raises the existing
%      singleton*.
%
%      H = VMEINFO returns the handle to a new VMEINFO or the handle to
%      the existing singleton*.
%
%      VMEINFO('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in VMEINFO.M with the given input arguments.
%
%      VMEINFO('Property','Value',...) creates a new VMEINFO or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before VMEinfo_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to VMEinfo_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help VMEinfo

% Last Modified by GUIDE v2.5 29-Jul-2014 11:13:26

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @VMEinfo_OpeningFcn, ...
                   'gui_OutputFcn',  @VMEinfo_OutputFcn, ...
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


% --- Executes just before VMEinfo is made visible.
function VMEinfo_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to VMEinfo (see VARARGIN)
text1 = sprintf('Visuomotor Experiment Creator v1.0');
text2 = sprintf('Experiment Originator:\nDr. Denise Henriques\nhttp://deniseh.lab.yorku.ca/');
text3 = sprintf('Created by:\nDr. Bernard Marius ’t Hart (mariusthart@gmail.com)\nErrol Cheong (ec@neorennie.com)');
text4 = sprintf('Contact Errol to report any bugs.\nScreenshots of the problems would be very helpful.');

Output_Text = sprintf('%s\n\n%s\n\n%s\n\n%s', text1, text2, text3, text4);

set(handles.text,'String',Output_Text)

% Choose default command line output for VMEinfo
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes VMEinfo wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = VMEinfo_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes during object creation, after setting all properties.
function text_CreateFcn(hObject, eventdata, handles)
% hObject    handle to text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
