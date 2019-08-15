function varargout = mainPDV(varargin)
% MAINPDV MATLAB code for mainPDV.fig
%      MAINPDV, by itself, creates a new MAINPDV or raises the existing
%      singleton*.
%
%      H = MAINPDV returns the handle to a new MAINPDV or the handle to
%      the existing singleton*.
%
%      MAINPDV('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MAINPDV.M with the given input arguments.
%
%      MAINPDV('Property','Value',...) creates a new MAINPDV or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before mainPDV_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to mainPDV_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help mainPDV

% Last Modified by GUIDE v2.5 15-Aug-2019 13:01:44

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @mainPDV_OpeningFcn, ...
                   'gui_OutputFcn',  @mainPDV_OutputFcn, ...
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


% --- Executes just before mainPDV is made visible.
function mainPDV_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to mainPDV (see VARARGIN)

% Choose default command line output for mainPDV
handles.output = hObject;
hObject.CurrentAxes=handles.Logo;
[A,map,~]  = imread('Metroid.png','BackGroundColor',get(handles.figure1,'color'));
imshow(A,map);
handles.logo.HandleVisibility='off';
handles.logo.Visible='off';

handles.tabManager = TabManager( hObject );

% Set-up a selection changed function on the create tab groups
tabGroups = handles.tabManager.TabGroups;
for tgi=1:length(tabGroups)
    set(tabGroups(tgi),'SelectionChangedFcn',@tabChangedCB)
end
handles.PDV_Data = [];
handles.selectedIndex = 0;

guidata(hObject, handles);

% UIWAIT makes mainPDV wait for user response (see UIRESUME)
% uiwait(handles.figure1);

% Called when a user clicks on a tab
function tabChangedCB(src, eventdata)

disp(['Changing tab from ' eventdata.OldValue.Title ' to ' eventdata.NewValue.Title ] );

% --- Outputs from this function are returned to the command line.
function varargout = mainPDV_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function CutoffEdit_Callback(hObject, eventdata, handles)
% hObject    handle to CutoffEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of CutoffEdit as text
%        str2double(get(hObject,'String')) returns contents of CutoffEdit as a double


% --- Executes during object creation, after setting all properties.
function CutoffEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to CutoffEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in buttonSelectMain.
function buttonSelectMain_Callback(hObject, eventdata, handles)
% hObject    handle to buttonSelectMain (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
tabMan = handles.tabManager;
tabMan.Handles.TabA.SelectedTab = tabMan.Handles.TabC01Main;
tabMan.Handles.TabB.SelectedTab = tabMan.Handles.TabC02Supplementary;


% --- Executes during object creation, after setting all properties.
function Time0Text_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Time0Text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called



function TimeWindow_Callback(hObject, eventdata, handles)
% hObject    handle to TimeWindow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of TimeWindow as text
%        str2double(get(hObject,'String')) returns contents of TimeWindow as a double


% --- Executes during object creation, after setting all properties.
function TimeWindow_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TimeWindow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function TransWindowEdit_Callback(hObject, eventdata, handles)
% hObject    handle to TransWindowEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of TransWindowEdit as text
%        str2double(get(hObject,'String')) returns contents of TransWindowEdit as a double


% --- Executes during object creation, after setting all properties.
function TransWindowEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TransWindowEdit (see GCBO)
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


% --- Executes on button press in RunSTFT.
function RunSTFT_Callback(hObject, eventdata, handles)
% hObject    handle to RunSTFT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if handles.selectedIndex == 0
    LoadTab_Callback(hObject, eventdata, handles);
end
idx = handles.selectedIndex;
handles.PDV_Data.Transform(idx);
set(handles.Vel_Save,'Enable','On')
guidata(hObject,handles);

% --- Executes on button press in RunPeakAlg.
function RunPeakAlg_Callback(hObject, eventdata, handles)
% hObject    handle to RunPeakAlg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if handles.selectedIndex == 0
    LoadTab_Callback(hObject, eventdata, handles);
end
idx = handles.selectedIndex;
handles.PDV_Data.PeakAlg(idx);
set(handles.Vel_Save,'Enable','On')
guidata(hObject,handles);

% --- Executes on selection change in FileList.
function FileList_Callback(hObject, eventdata, handles)
% hObject    handle to FileList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns FileList contents as cell array
%        contents{get(hObject,'Value')} returns selected item from FileList
handles.selectedIndex = get(hObject,'Value');
handles.PDV_Data.PlotData(handles.selectedIndex);
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
function FileTab_Callback(hObject, eventdata, handles)
% hObject    handle to FileTab (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function LoadTab_Callback(hObject, eventdata, handles)
% hObject    handle to LoadTab (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[fnames,fpath] = uigetfile('*Ch1.txt','multiselect','on','Select PDV files');
if fpath ==0
    error('LoadData:NoData',...
        'No file input')
end
if ischar(fnames)
    fnames = {fnames};
end
try
    delete(handles.PDV_Data); %Delete old data
catch
    handles.PDV_Data = [];
end
handles.fileNames = fnames; handles.filePath = fpath;
set(handles.FileList,'Value',1); 
set(handles.FileList,'String',fnames');
handles.selectedIndex = 1;
guidata(hObject,handles)
handles.PDV_Data = MainPDVData(handles.figure1);
guidata(hObject,handles);


% --- Executes on button press in RunSTFTAll.
function RunSTFTAll_Callback(hObject, eventdata, handles)
% hObject    handle to RunSTFTAll (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.selectedIndex = 1;
for i = 1:length(handles.fileNames)
    RunSTFT_Callback(hObject,eventdata,handles);
    handles.selectedIndex = i+1;
end



% --------------------------------------------------------------------
function Vel_Save_Callback(hObject, eventdata, handles)
% hObject    handle to Vel_Save (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if ~isempty(handles.PDV_Data)
    handles.PDV_Data.Vel2Text();
end



function xfEdit_Callback(hObject, eventdata, handles)
% hObject    handle to xfEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of xfEdit as text
%        str2double(get(hObject,'String')) returns contents of xfEdit as a double


% --- Executes during object creation, after setting all properties.
function xfEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to xfEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function xiEdit_Callback(hObject, eventdata, handles)
% hObject    handle to xiEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of xiEdit as text
%        str2double(get(hObject,'String')) returns contents of xiEdit as a double


% --- Executes during object creation, after setting all properties.
function xiEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to xiEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in UpdatePlotBtn.
function UpdatePlotBtn_Callback(hObject, eventdata, handles)
% hObject    handle to UpdatePlotBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if ~isempty(handles.PDV_Data)
    handles.PDV_Data.PlotData(handles.selectedIndex)
end


% --- Executes on button press in RunPeakAlgAll.
function RunPeakAlgAll_Callback(hObject, eventdata, handles)
% hObject    handle to RunPeakAlgAll (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.selectedIndex = 1;
for i = 1:length(handles.fileNames)
    RunPeakAlg_Callback(hObject,eventdata,handles);
    handles.selectedIndex = i+1;
end