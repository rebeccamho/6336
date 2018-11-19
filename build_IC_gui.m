function varargout = build_IC_gui(varargin)
% BUILD_IC_GUI MATLAB code for build_IC_gui.fig
%      BUILD_IC_GUI, by itself, creates a new BUILD_IC_GUI or raises the existing
%      singleton*.
%
%      H = BUILD_IC_GUI returns the handle to a new BUILD_IC_GUI or the handle to
%      the existing singleton*.
%
%      BUILD_IC_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in BUILD_IC_GUI.M with the given input arguments.
%
%      BUILD_IC_GUI('Property','Value',...) creates a new BUILD_IC_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before build_IC_gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to build_IC_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help build_IC_gui

% Last Modified by GUIDE v2.5 18-Nov-2018 17:33:47

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @build_IC_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @build_IC_gui_OutputFcn, ...
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


% --- Executes just before build_IC_gui is made visible.
function build_IC_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to build_IC_gui (see VARARGIN)

% Choose default command line output for build_IC_gui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes build_IC_gui wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = build_IC_gui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function nLayersBox_Callback(hObject, eventdata, handles)
% hObject    handle to nLayersBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of nLayersBox as text
%        str2double(get(hObject,'String')) returns contents of nLayersBox as a double
guidata(hObject,handles);



% --- Executes during object creation, after setting all properties.
function nLayersBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to nLayersBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function nPointsBox_Callback(hObject, eventdata, handles)
% hObject    handle to nPointsBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of nPointsBox as text
%        str2double(get(hObject,'String')) returns contents of nPointsBox as a double
nPoints = str2double(get(hObject,'Value'));
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function nPointsBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to nPointsBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in showICButton.
function showICButton_Callback(hObject, eventdata, handles)
% hObject    handle to showICButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
nLayers = str2double(get(handles.nLayersBox,'String'));
nPoints = str2double(get(handles.nPointsBox,'String'));
[x_start,u,p,otherParams] = build_network_gui_code(handles,nLayers,nPoints);


% --- Executes on button press in showTempButton.
function showTempButton_Callback(hObject, eventdata, handles)
% hObject    handle to showTempButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
nLayers = str2double(get(handles.nLayersBox,'String'));
nPoints = str2double(get(handles.nPointsBox,'String'));
simTime = str2double(get(handles.simTimeBox,'String'));
dt = str2double(get(handles.dtBox,'String'));
[x_start,u,p,otherParams] = build_network_gui_code(handles,nLayers,nPoints);
run_w_gui_code(handles,x_start,u,p,otherParams,simTime,dt);



function simTimeBox_Callback(hObject, eventdata, handles)
% hObject    handle to simTimeBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of simTimeBox as text
%        str2double(get(hObject,'String')) returns contents of simTimeBox as a double
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function simTimeBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to simTimeBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function dtBox_Callback(hObject, eventdata, handles)
% hObject    handle to dtBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of dtBox as text
%        str2double(get(hObject,'String')) returns contents of dtBox as a double
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function dtBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dtBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
