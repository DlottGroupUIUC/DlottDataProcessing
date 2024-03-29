% %%Main PMT Module Notes
%Author: Larry Salvati, utilizing code based on programs by Will Bassett
%salvati3@illinois.edu
%This program immediately passes the figure handle to a class instance
%MainData (from MainPMTData.m classdef function). This effectively
%minimizes the use of the mainPMT.m script in the code, which in future
%updates will be further minimized. 
%
%MainData contains various methods and is the main area where new routines
%are written. Properties and Methods Notes follow:
%Properties:
%mainFig - Figure handle passed from this code (does so upon opening)
%cFilter - matrix of calibration filter pulled from a text file in the
%           'save data' folder. Change these values BEFORE opening mainPMT.m for
%           changes to come into effect. Data is based on integration
%           sphere measurements
%eFilter - matrix of emission data passed into code, see cFilter notes.
%handles - GUI handle pulled out of mainFig, this only exists for brevity
%           of script writing, mainFig is basically never used again after this is
%           created
%DataStorage - Cell array of derived data, populated once a
%                           calculation is performed. Data storage is
%                           talked about more specifically later, but take
%                           note that this creates an instance of a data
%                           class based on what kind of data needs
%                           interpreted. Right now this only does standard
%                           pyrometry experiments, but new data classes can
%                           be created, eventually this will be made into a
%                           datastorage superclass and subclass instances
%                           of specific data interpretations.
%LampVal - Integration sphere calibration lamp values for
%                       experimental calibrations.
%UnitConv - correction factor ratio for calibrating data based on LampVal and
%                       calibration current
%PDVData - Current plan for implementing PDV data integration in
%                       PMT analysis. Right now only populates when main PDV module
%                       executes 'Export to PMT' menu option.

%There are also various methods available, more details in mainPMTData
%module:
%Methods: Public methods - universally accessible in Matlab. Used if the
    %GUI program needs to initiate a data operation of some kind. I try to
    %minimize the need for these, but am working on it.
    %Private methods - functions only accessible within the mainPMTData
    %module. Limits programming overhead to localize literally everything
    %that other programs don't ever need to see or deal with, so if GUI doesn't need to directly access it make it private.

%General Notes on how it operates:
%handles.MainData instance is created immediately upon opening, and the
%figure handle of the GUI is passed to it. 
%Most data from the gui figure can be accessed directly from the
%handles.MainData instance (via obj.handles.xxx). When the File -> Load
%option is selected, fileNames and filePath properties are populated, and
%DataStorage array is cleared and replaced in memory with an empty cell
%array with length equal to number of files selected.
%Radiance binning works as follows: .tdms file is opened, full data matrix
%extracted, and used to create an instance of PMTData as a DataStorage entry,
%indexed by its position on the list of files loaded in.
%All subsequent operations are performed within PMTData instance (named Datastorage{idx}) 
%binning occurs according to set parameters of binning.
%If no calibration matrix exists (always the case on the first file interpreted)
%it prompts user for one. 
%Binning delay is determined using Channel 15. setting peak at target is
%done by finding the maximum peak within the +/-2 us of scope data
%collection that meets minimum peak value threshold integer x RMS. 
%Once binning is performed, original unbinned data is cleared from memory
%to preserve system memory, which becomes a big deal at file batches
%larger than 20.

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

% Last Modified by GUIDE v2.5 25-Mar-2021 11:57:28

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
hObject.CurrentAxes=handles.Logo; %Create the fun logos and stuff
[A,map,~]  = imread('Metroid.png','BackGroundColor',get(handles.PMTFigure,'color'));
imshow(A,map);
handles.logo.HandleVisibility='off';
handles.logo.Visible='off';
%tabmanager is a downloaded matlab file that
%allows for tab structures to be easily implemented.
handles.tabManager = TabManager( hObject );
%selectedIndex gives the file targeted for viewing/analysis
%this variable is actually practically obsolete.
handles.selectedIndex = 1;
% Set-up a selection changed function on the create tab groups
tabGroups = handles.tabManager.TabGroups;
for tgi=1:length(tabGroups)
    set(tabGroups(tgi),'SelectionChangedFcn',@tabChangedCB)
end
%set callback
%handles.axes5.ButtonDownFcn=@(hObject,eventdata)mainPMT('axes5_ButtonDownFcn',hObject,eventdata,guidata(hObject));
%creates the mainPMTData instance that proceeds to handle most of the
%loaded and analyzed data thereafter.
if ~isempty(varargin)
    handles.MainData = MainPMTData(handles.PMTFigure,varargin{1},varargin{2});
else
    handles.MainData = MainPMTData(handles.PMTFigure);
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

%{
% --- Executes on selection change in FileList.
function FileList_Callback(hObject, eventdata, handles)
% hObject    handle to FileList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns FileList contents as cell array
%        contents{get(hObject,'Value')} returns selected item from FileList
%selectedFiles is relevant when multiple items are selected on the file
%list. However, the use of it at the GUI level is becoming obsolete, will
%eventually all be moved to the data handle class.
handles.selectedFiles = get(hObject,'Value');
handles.selectedIndex = min(handles.selectedFiles);
guidata(hObject,handles);
try
    %plotting routines in MainData structure.
handles.MainData.RadianceSemiLogPlot(handles.selectedIndex);
handles.MainData.TempPlot(handles.selectedIndex);
handles.MainData.EmissivityPlot(handles.selectedIndex);
handles.MainData.SpectrumPlot(handles.selectedIndex);
catch
end
guidata(hObject,handles);
%}


% --- Executes when selected cell(s) is changed in FileList.
function FileList_CellSelectionCallback(hObject, eventdata, handles)
% hObject    handle to FileList (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.TABLE)
%	Indices: row and column indices of the cell(s) currently selecteds
% handles    structure with handles and user data (see GUIDATA)
try
idx = eventdata.Indices(:,1); %retrieve selected row.
handles.selectedIndex = min(idx);
handles.selectedFiles = idx;
handles.MainData.selectedFiles = idx;
guidata(hObject,handles);
catch
end
try
%plotting routines in MainData structure.
handles.MainData.RadianceSemiLogPlot(handles.selectedIndex);
handles.MainData.TempPlot(handles.selectedIndex);
handles.MainData.EmissivityPlot(handles.selectedIndex);
handles.MainData.SpectrumPlot(handles.selectedIndex);
catch
end
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

handles.MainData.LoadRoutine(); %populates the MainData.fileNames and filePath properties

guidata(hObject,handles);

% --------------------------------------------------------------------
function saveRad_Callback(hObject, eventdata, handles)
% hObject    handle to saveRad (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.MainData.SaveAsTxt(); %this actually saves all the selected derived 
%quantities from analysis. More detail in the MainData.SaveAsTxt method


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
try handles.MainData;
catch
    LoadTab_Callback(hObject,eventdata,handles);
end
idx = handles.selectedFiles(1:end);
for i = 1:length(idx)
    handles.MainData.BinPMTData(idx(i),get(handles.ManualDelay,'Value'));
end
guidata(hObject,handles);

% --- Executes on button press in peakButton.
function peakButton_Callback(hObject, eventdata, handles)
% hObject    handle to peakButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.riseButton,'Value',0);
set(handles.PDVdelayButton,'Value',0);
set(handles.ManualDelay,'Value',0);
% Hint: get(hObject,'Value') returns toggle state of peakButton


% --- Executes on button press in riseButton.
function riseButton_Callback(hObject, eventdata, handles)
% hObject    handle to riseButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.peakButton,'Value',0);
set(handles.PDVdelayButton,'Value',0);
set(handles.ManualDelay,'Value',0);
% Hint: get(hObject,'Value') returns toggle state of riseButton


% --- Executes on button press in PDVdelayButton.
function PDVdelayButton_Callback(hObject, eventdata, handles)
% hObject    handle to PDVdelayButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.peakButton,'Value',0);
set(handles.riseButton,'Value',0);
set(handles.ManualDelay,'Value',0);
% Hint: get(hObject,'Value') returns toggle state of PDVdelayButton

% --- Executes on button press in ManualDelay.
function ManualDelay_Callback(hObject, eventdata, handles)
% hObject    handle to ManualDelay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.peakButton,'Value',0);
set(handles.riseButton,'Value',0);
set(handles.PDVdelayButton,'Value',0);
% Hint: get(hObject,'Value') returns toggle state of ManualDelay

% --- Executes when entered data in editable cell(s) in FileList.
function FileList_CellEditCallback(hObject, eventdata, handles)
% hObject    handle to FileList (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.TABLE)
%	Indices: row and column indices of the cell(s) edited
%	PreviousData: previous data for the cell(s) edited
%	EditData: string(s) entered by the user
%	NewData: EditData or its converted form set on the Data property. Empty if Data was not changed
%	Error: error string when failed to convert EditData to appropriate value for Data
% handles    structure with handles and user data (see GUIDATA)
%upon edit re-bin data with new delay
handles.selectedIndex = eventdata.Indices(1); %find current cell that was changed
handles.MainData.BinPMTData(handles.selectedIndex,1)
guidata(hObject,handles);

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
    handles.MainData.BinAll();
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


% --- Executes on button press in runGray.
function runGray_Callback(hObject, eventdata, handles)
% hObject    handle to runGray (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%idx = handles.selectedIndex;
for idx = handles.selectedFiles(1:end)
    handles.MainData.calcTemp(idx)
end



function ConfBound_Callback(hObject, eventdata, handles)
% hObject    handle to ConfBound (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ConfBound as text
%        str2double(get(hObject,'String')) returns contents of ConfBound as a double


% --- Executes during object creation, after setting all properties.
function ConfBound_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ConfBound (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in runTempAll.
function runTempAll_Callback(hObject, eventdata, handles)
% hObject    handle to runTempAll (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    handles.MainData.calcTempAll();
    guidata(hObject,handles);


% --------------------------------------------------------------------
function settings_tag_Callback(hObject, eventdata, handles)
% hObject    handle to settings_tag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function channelList_Callback(hObject, eventdata, handles)
% hObject    handle to channelList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function mSave_Callback(hObject, eventdata, handles)
% hObject    handle to mSave (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
curr_dir = pwd;
cd(handles.MainData.filePath);
[mName,mPath] = uiputfile('*.mat','Save Session');
mFile = fullfile(mPath,mName);
save(string(mFile));
cd(curr_dir);

% --------------------------------------------------------------------
function mLoad_Callback(hObject, eventdata, handles)
% hObject    handle to mLoad (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[mName,mPath] = uigetfile('*.mat','Load Previous Session');
mFile = fullfile(mPath,mName);
if ~strcmp(string(mPath),'0')
    delete(handles.PMTFigure);
    load(mFile,'-mat');
end


% --------------------------------------------------------------------
function SaveList_Callback(hObject, eventdata, handles)
% hObject    handle to SaveList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function RadSave_Callback(hObject, eventdata, handles)
% hObject    handle to RadSave (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
SaveListClick(hObject)
guidata(hObject,handles);

% --------------------------------------------------------------------
function TempSave_Callback(hObject, eventdata, handles)
% hObject    handle to TempSave (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
SaveListClick(hObject)
guidata(hObject,handles);

% --------------------------------------------------------------------
function EmissivitySave_Callback(hObject, eventdata, handles)
% hObject    handle to EmissivitySave (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
SaveListClick(hObject)
guidata(hObject,handles);

% --------------------------------------------------------------------
function SpectrumSave_Callback(hObject, eventdata, handles)
% hObject    handle to SpectrumSave (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
SaveListClick(hObject)
guidata(hObject,handles);


function SaveListClick(hObject)
    switch get(hObject,'Checked')
        case 'on'
            set(hObject,'Checked','off');
        case 'off'
            set(hObject,'Checked','on');
    end


% --- Executes on selection change in PDVFileList.
function PDVFileList_Callback(hObject, eventdata, handles)
% hObject    handle to PDVFileList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns PDVFileList contents as cell array
%        contents{get(hObject,'Value')} returns selected item from PDVFileList
handles.MainData.PlotPDV();

% --- Executes during object creation, after setting all properties.
function PDVFileList_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PDVFileList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ExcChannelEdit_Callback(hObject, eventdata, handles)
% hObject    handle to ExcChannelEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ExcChannelEdit as text
%        str2double(get(hObject,'String')) returns contents of ExcChannelEdit as a double


% --- Executes during object creation, after setting all properties.
function ExcChannelEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ExcChannelEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in TempAVG_Button.
function TempAVG_Button_Callback(hObject, eventdata, handles)
% hObject    handle to TempAVG_Button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.selectedIndex = min(handles.selectedFiles);
handles.MainData.TempAverage(handles.selectedFiles);


% --- Executes on mouse press over axes background.
function axes5_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to axes5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

coordinates = get(handles.axes5,'CurrentPoint');
coordinates = coordinates(1,1:2);
disp(coordinates)

function RadAxis_ButtonDownFcn(hObject,eventdata,handles)

function SpectrumAxis_ButtonDownFcn(hObject,eventdata,handles)
disp('Clicked')


% --- Executes on button press in PDVPlot_Box.
function PDVPlot_Box_Callback(hObject, eventdata, handles)
% hObject    handle to PDVPlot_Box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    handles.MainData.PlotPDV();

% Hint: get(hObject,'Value') returns toggle state of PDVPlot_Box


% --- Executes on button press in DelayAdjustButton.
function DelayAdjustButton_Callback(hObject, eventdata, handles)
% hObject    handle to DelayAdjustButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    idx = min(handles.selectedFiles);
    handles.MainData.BinPMTData(idx,2);


% --------------------------------------------------------------------
function VelocitySave_Callback(hObject, eventdata, handles)
% hObject    handle to VelocitySave (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
SaveListClick(hObject)
guidata(hObject,handles);


% --------------------------------------------------------------------
function NewCalFile_Callback(hObject, eventdata, handles)
% hObject    handle to NewCalFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.MainData.NewCalibration();


% --- Executes on selection change in GraphDecadeDropDown.
function GraphDecadeDropDown_Callback(hObject, eventdata, handles)
% hObject    handle to GraphDecadeDropDown (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns GraphDecadeDropDown contents as cell array
%        contents{get(hObject,'Value')} returns selected item from GraphDecadeDropDown


% --- Executes during object creation, after setting all properties.
function GraphDecadeDropDown_CreateFcn(hObject, eventdata, handles)
% hObject    handle to GraphDecadeDropDown (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function GraphEndDecadeEdit_Callback(hObject, eventdata, handles)
% hObject    handle to GraphEndDecadeEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of GraphEndDecadeEdit as text
%        str2double(get(hObject,'String')) returns contents of GraphEndDecadeEdit as a double


% --- Executes during object creation, after setting all properties.
function GraphEndDecadeEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to GraphEndDecadeEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
