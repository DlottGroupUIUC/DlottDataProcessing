function varargout = CMOS_Processor(varargin)
% CMOS_PROCESSOR MATLAB code for CMOS_Processor.fig
%      CMOS_PROCESSOR, by itself, creates a new CMOS_PROCESSOR or raises the existing
%      singleton*.
%
%      H = CMOS_PROCESSOR returns the handle to a new CMOS_PROCESSOR or the handle to
%      the existing singleton*.
%
%      CMOS_PROCESSOR('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CMOS_PROCESSOR.M with the given input arguments.
%
%      CMOS_PROCESSOR('Property','Value',...) creates a new CMOS_PROCESSOR or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before CMOS_Processor_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to CMOS_Processor_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help CMOS_Processor

% Last Modified by GUIDE v2.5 30-Sep-2019 18:58:19

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @CMOS_Processor_OpeningFcn, ...
                   'gui_OutputFcn',  @CMOS_Processor_OutputFcn, ...
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


% --- Executes just before CMOS_Processor is made visible.
function CMOS_Processor_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to CMOS_Processor (see VARARGIN)

% Choose default command line output for CMOS_Processor
handles.output = hObject;
handles.CMOSController = mainCMOScontroller(handles.CMOSFigure);
% Update handles structure
guidata(hObject, handles);


% UIWAIT makes CMOS_Processor wait for user response (see UIRESUME)
% uiwait(handles.CMOSFigure);


% --- Outputs from this function are returned to the command line.
function varargout = CMOS_Processor_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --------------------------------------------------------------------
function FileTag_Callback(hObject, eventdata, handles)
% hObject    handle to FileTag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function SifLoad_Callback(hObject, eventdata, handles)
% hObject    handle to SifLoad (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.CMOSController.LoadSif();

% --------------------------------------------------------------------
function TifSave_Callback(hObject, eventdata, handles)
% hObject    handle to TifSave (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function TifLoad_Callback(hObject, eventdata, handles)
% hObject    handle to TifLoad (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes when selected cell(s) is changed in FileTable.
function FileTable_CellSelectionCallback(hObject, eventdata, handles)
% hObject    handle to FileTable (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.TABLE)
%	Indices: row and column indices of the cell(s) currently selecteds
% handles    structure with handles and user data (see GUIDATA)
idx = eventdata.Indices(1); %retrieve selected row.
handles.CMOSController.SelectImage(idx); %write it to controller instance
