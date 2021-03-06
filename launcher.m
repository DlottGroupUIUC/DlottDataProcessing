function varargout = launcher(varargin)
% LAUNCHER MATLAB code for launcher.fig
%      LAUNCHER, by itself, creates a new LAUNCHER or raises the existing
%      singleton*.
%
%      H = LAUNCHER returns the handle to a new LAUNCHER or the handle to
%      the existing singleton*.
% 
%      LAUNCHER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in LAUNCHER.M with the given input arguments.
%
%      LAUNCHER('Property','Value',...) creates a new LAUNCHER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before launcher_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to launcher_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help launcher

% Last Modified by GUIDE v2.5 30-Sep-2019 16:39:24

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @launcher_OpeningFcn, ...
                   'gui_OutputFcn',  @launcher_OutputFcn, ...
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


% --- Executes just before launcher is made visible.
function launcher_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to launcher (see VARARGIN)

% Choose default command line output for launcher
handles.output = hObject;

if (~isdeployed)
    addpath(genpath('./Enum'));
    addpath(genpath('./Functions'));
    addpath(genpath('./GUI'));
    addpath(genpath('./Image'));
    addpath(genpath('./Main Classes'));
    addpath(genpath('./Help'));
    addpath(genpath('./SaveData'));
end

hObject.CurrentAxes=handles.Logo;
[A,map,~]  = imread('Metroid.png','BackGroundColor',get(handles.figure1,'Color'));
imshow(A,map);
handles.logo.HandleVisibility='off';
handles.logo.Visible='off';
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes launcher wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = launcher_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in PDVbutton.
function PDVbutton_Callback(hObject, eventdata, handles)
% hObject    handle to PDVbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    mainPDV();
    delete(handles.figure1);

% --- Executes on button press in PMTbutton.
function PMTbutton_Callback(hObject, eventdata, handles)
% hObject    handle to PMTbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
mainPMT();
delete(handles.figure1);


% --- Executes when figure1 is resized.
function figure1_SizeChangedFcn(hObject, eventdata, handles)
%{
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
images={'mario.ico','yoshi.png',};
buttons={'PDVbutton','PMTbutton'};

for i=1:length(images)
    %read the images
    if isempty(strfind(images{i},'png'))
        images{i}=imread(images{i});
    else
        images{i}=imread(images{i},'BackGroundColor',Colors.BackGround.getColor());        
    end
    
    %get the button new button sizes and resize images accordingly
    handles.(buttons{i}).Units='pixels';
    images{i}=imresize(images{i},fliplr(handles.(buttons{i}).Position(1,3:4)));
    handles.(buttons{i}).Units='normalized';
    handles.(buttons{i}).CData=images{i};
end
%}


% --- Executes on button press in iCMOSlauncher.
function iCMOSlauncher_Callback(hObject, eventdata, handles)
% hObject    handle to iCMOSlauncher (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
CMOS_Processor();
delete(handles.figure1);