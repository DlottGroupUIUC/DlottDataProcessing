function varargout = mainPMT(varargin)
% MAINPMT MATLAB code for mainPMT.fig
%      MAINPMT, by itself, creates a new MAINPMT or raises the existing
%      singleton*.
%
%      H = MAINPMT returns the handle to a new MAINPMT or the handle to
%      the existing singleton*.
%
%      MAINPMT('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MAINPMT.M with the given input arguments.
%
%      MAINPMT('Property','Value',...) creates a new MAINPMT or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before mainPMT_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to mainPMT_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help mainPMT

% Last Modified by GUIDE v2.5 23-Aug-2019 11:03:09

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @mainPMT_OpeningFcn, ...
                   'gui_OutputFcn',  @mainPMT_OutputFcn, ...
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


% --- Executes just before mainPMT is made visible.
function mainPMT_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to mainPMT (see VARARGIN)

% Choose default command line output for mainPMT
handles.output = hObject;

hObject.CurrentAxes=handles.Logo;
[A,map,~]  = imread('Metroid.png','BackGroundColor',get(handles.PMTFigure,'color'));
imshow(A,map);
handles.logo.HandleVisibility='off';
handles.logo.Visible='off';

handles.tabManager = TabManager( hObject );
handles.selectedIndex = 1;
% Set-up a selection changed function on the create tab groups
tabGroups = handles.tabManager.TabGroups;
for tgi=1:length(tabGroups)
    set(tabGroups(tgi),'SelectionChangedFcn',@tabChangedCB)
end


% Update handles structure
guidata(hObject, handles);

% UIWAIT makes mainPMT wait for user response (see UIRESUME)
% uiwait(handles.PMTFigure);


% --- Outputs from this function are returned to the command line.
function varargout = mainPMT_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in FileList.
function FileList_Callback(hObject, eventdata, handles)
% hObject    handle to FileList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns FileList contents as cell array
%        contents{get(hObject,'Value')} returns selected item from FileList
handles.selectedIndex = get(hObject,'Value');
guidata(hObject,handles);
handles.MainData.RadianceSemiLogPlot(handles.selectedIndex)
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function FileList_CreateFcn(hObject, eventdata, handles)
% hObject    handle to FileList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --------------------------------------------------------------------
function fileTab_Callback(hObject, eventdata, handles)
% hObject    handle to fileTab (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function LoadTab_Callback(hObject, eventdata, handles)
% hObject    handle to LoadTab (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[fNames,fPath] = uigetfile('*.tdms','Load PMT Files','multiselect','on');
if strcmp(string(fPath),'0')
    error('LoadData:NoData',...
        'No file input')
end
if ischar(fNames)
    fNames = {fNames};
end
%{
try
    delete(handles.PDV_Data); %Delete old data
catch
    handles.PDV_Data = [];
end
%}
handles.PMTfileNames = fNames; handles.PMTfilePath = fPath;
guidata(hObject,handles);
handles.MainData = MainPMTData(handles.PMTFigure);
set(handles.FileList,'Value',1); 
set(handles.FileList,'String',fNames');
handles.selectedIndex = 1;
guidata(hObject,handles);

% --------------------------------------------------------------------
function saveRad_Callback(hObject, eventdata, handles)
% hObject    handle to saveRad (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function binRes_Callback(hObject, eventdata, handles)
% hObject    handle to binRes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of binRes as text
%        str2double(get(hObject,'String')) returns contents of binRes as a double


% --- Executes during object creation, after setting all properties.
function binRes_CreateFcn(hObject, eventdata, handles)
% hObject    handle to binRes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit2_Callback(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit2 as text
%        str2double(get(hObject,'String')) returns contents of edit2 as a double


% --- Executes during object creation, after setting all properties.
function edit2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit3_Callback(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit3 as text
%        str2double(get(hObject,'String')) returns contents of edit3 as a double


% --- Executes during object creation, after setting all properties.
function edit3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit4_Callback(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit4 as text
%        str2double(get(hObject,'String')) returns contents of edit4 as a double


% --- Executes during object creation, after setting all properties.
function edit4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in runBinning.
function runBinning_Callback(hObject, eventdata, handles)
% hObject    handle to runBinning (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.MainData.BinPMTData(handles.selectedIndex);
guidata(hObject,handles);

% --- Executes on button press in peakButton.
function peakButton_Callback(hObject, eventdata, handles)
% hObject    handle to peakButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.riseButton,'Value',0);
set(handles.PDVdelayButton,'Value',0);
% Hint: get(hObject,'Value') returns toggle state of peakButton


% --- Executes on button press in riseButton.
function riseButton_Callback(hObject, eventdata, handles)
% hObject    handle to riseButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.peakButton,'Value',0);
set(handles.PDVdelayButton,'Value',0);
% Hint: get(hObject,'Value') returns toggle state of riseButton


% --- Executes on button press in PDVdelayButton.
function PDVdelayButton_Callback(hObject, eventdata, handles)
% hObject    handle to PDVdelayButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.peakButton,'Value',0);
set(handles.riseButton,'Value',0);
% Hint: get(hObject,'Value') returns toggle state of PDVdelayButton



function binStart_Callback(hObject, eventdata, handles)
% hObject    handle to binStart (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of binStart as text
%        str2double(get(hObject,'String')) returns contents of binStart as a double


% --- Executes during object creation, after setting all properties.
function binStart_CreateFcn(hObject, eventdata, handles)
% hObject    handle to binStart (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function binEnd_Callback(hObject, eventdata, handles)
% hObject    handle to binEnd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of binEnd as text
%        str2double(get(hObject,'String')) returns contents of binEnd as a double


% --- Executes during object creation, after setting all properties.
function binEnd_CreateFcn(hObject, eventdata, handles)
% hObject    handle to binEnd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in binAll.
function binAll_Callback(hObject, eventdata, handles)
% hObject    handle to binAll (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    for i = 1:length(handles.PMTfileNames)
        handles.selectedIndex = i;guidata(hObject,handles);
        runBinning_Callback(hObject,eventdata,handles);
    end
    guidata(hObject,handles);


function delayTarget_Callback(hObject, eventdata, handles)
% hObject    handle to delayTarget (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of delayTarget as text
%        str2double(get(hObject,'String')) returns contents of delayTarget as a double


% --- Executes during object creation, after setting all properties.
function delayTarget_CreateFcn(hObject, eventdata, handles)
% hObject    handle to delayTarget (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ThreshEdit_Callback(hObject, eventdata, handles)
% hObject    handle to ThreshEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ThreshEdit as text
%        str2double(get(hObject,'String')) returns contents of ThreshEdit as a double


% --- Executes during object creation, after setting all properties.
function ThreshEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ThreshEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in calFiltList.
function calFiltList_Callback(hObject, eventdata, handles)
% hObject    handle to calFiltList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns calFiltList contents as cell array
%        contents{get(hObject,'Value')} returns selected item from calFiltList


% --- Executes during object creation, after setting all properties.
function calFiltList_CreateFcn(hObject, eventdata, handles)
% hObject    handle to calFiltList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in expFiltList.
function expFiltList_Callback(hObject, eventdata, handles)
% hObject    handle to expFiltList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns expFiltList contents as cell array
%        contents{get(hObject,'Value')} returns selected item from expFiltList


% --- Executes during object creation, after setting all properties.
function expFiltList_CreateFcn(hObject, eventdata, handles)
% hObject    handle to expFiltList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
