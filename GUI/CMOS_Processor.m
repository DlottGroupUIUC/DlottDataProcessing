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

% Last Modified by GUIDE v2.5 08-Nov-2019 15:44:33

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
hObject.CurrentAxes=handles.Logo;
[A,map,~]  = imread('Metroid.png','BackGroundColor',get(handles.CMOSFigure,'color'));
imshow(A,map);
handles.logo.HandleVisibility='off';
handles.logo.Visible='off';
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
handles.CMOSController.Save2Tif();

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
try
idx = eventdata.Indices(1); %retrieve selected row.
handles.CMOSController.SelectImage(idx); %write it to controller instance
catch
end


% --------------------------------------------------------------------
function Save2TiffAll_Callback(hObject, eventdata, handles)
% hObject    handle to Save2TiffAll (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.CMOSController.Save2TifAll();



function SaveIntensityZero_Callback(hObject, eventdata, handles)
% hObject    handle to SaveIntensityZero (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of SaveIntensityZero as text
%        str2double(get(hObject,'String')) returns contents of SaveIntensityZero as a double
handles.CMOSController.SelectImage(0);

% --- Executes during object creation, after setting all properties.
function SaveIntensityZero_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SaveIntensityZero (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function SaveIntensityMax_Callback(hObject, eventdata, handles)
% hObject    handle to SaveIntensityMax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of SaveIntensityMax as text
%        str2double(get(hObject,'String')) returns contents of SaveIntensityMax as a double
handles.CMOSController.SelectImage(0);

% --- Executes during object creation, after setting all properties.
function SaveIntensityMax_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SaveIntensityMax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function FlyerLaunchEdit_Callback(hObject, eventdata, handles)
% hObject    handle to FlyerLaunchEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of FlyerLaunchEdit as text
%        str2double(get(hObject,'String')) returns contents of FlyerLaunchEdit as a double
handles.CMOSController.SetDelay();

% --- Executes during object creation, after setting all properties.
function FlyerLaunchEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to FlyerLaunchEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in ParamLabel.
function ParamLabel_Callback(hObject, eventdata, handles)
% hObject    handle to ParamLabel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ParamLabel


% --- Executes on button press in DelayLabel.
function DelayLabel_Callback(hObject, eventdata, handles)
% hObject    handle to DelayLabel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of DelayLabel


% --- Executes when entered data in editable cell(s) in FileTable.
function FileTable_CellEditCallback(hObject, eventdata, handles)
% hObject    handle to FileTable (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.TABLE)
%	Indices: row and column indices of the cell(s) edited
%	PreviousData: previous data for the cell(s) edited
%	EditData: string(s) entered by the user
%	NewData: EditData or its converted form set on the Data property. Empty if Data was not changed
%	Error: error string when failed to convert EditData to appropriate value for Data
% handles    structure with handles and user data (see GUIDATA)
index = eventdata.Indices(1);
handles.CMOSController.ChangeDelay(index);


% --------------------------------------------------------------------
function b16Load_Callback(hObject, eventdata, handles)
% hObject    handle to b16Load (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.CMOSController.LoadB16();


% --- Executes on selection change in ObjectiveList.
function ObjectiveList_Callback(hObject, eventdata, handles)
% hObject    handle to ObjectiveList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns ObjectiveList contents as cell array
%        contents{get(hObject,'Value')} returns selected item from ObjectiveList


% --- Executes during object creation, after setting all properties.
function ObjectiveList_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ObjectiveList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --------------------------------------------------------------------
function FileTable_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to FileTable (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
try
idx = eventdata.Indices(1); %retrieve selected row.
handles.CMOSController.SelectImage(idx); %write it to controller instance
catch
end



function ExposureInput_Callback(hObject, eventdata, handles)
% hObject    handle to ExposureInput (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ExposureInput as text
%        str2double(get(hObject,'String')) returns contents of ExposureInput as a double


% --- Executes during object creation, after setting all properties.
function ExposureInput_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ExposureInput (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function GainInput_Callback(hObject, eventdata, handles)
% hObject    handle to GainInput (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of GainInput as text
%        str2double(get(hObject,'String')) returns contents of GainInput as a double


% --- Executes during object creation, after setting all properties.
function GainInput_CreateFcn(hObject, eventdata, handles)
% hObject    handle to GainInput (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in ScaleBar.
function ScaleBar_Callback(hObject, eventdata, handles)
% hObject    handle to ScaleBar (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ScaleBar
