function varargout = GUI_Portfolio_Analysis(varargin)
% Simple GUI created with the use of Guide and takes inputs from the user
% GUI_PORTFOLIO_ANALYSIS M-file for GUI_Portfolio_Analysis.fig
%      GUI_PORTFOLIO_ANALYSIS, by itself, creates a new GUI_PORTFOLIO_ANALYSIS or raises the existing
%      singleton*.
%
%      H = GUI_PORTFOLIO_ANALYSIS returns the handle to a new GUI_PORTFOLIO_ANALYSIS or the handle to
%      the existing singleton*.
%
%      GUI_PORTFOLIO_ANALYSIS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUI_PORTFOLIO_ANALYSIS.M with the given input arguments.
%
%      GUI_PORTFOLIO_ANALYSIS('Property','Value',...) creates a new GUI_PORTFOLIO_ANALYSIS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before GUI_Portfolio_Analysis_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to GUI_Portfolio_Analysis_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% Copyright 2002-2003 The MathWorks, Inc.

% Edit the above text to modify the response to help GUI_Portfolio_Analysis

% Last Modified by GUIDE v2.5 04-Jul-2008 12:55:50

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GUI_Portfolio_Analysis_OpeningFcn, ...
                   'gui_OutputFcn',  @GUI_Portfolio_Analysis_OutputFcn, ...
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


% --- Executes just before GUI_Portfolio_Analysis is made visible.
function GUI_Portfolio_Analysis_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to GUI_Portfolio_Analysis (see VARARGIN)

% Choose default command line output for GUI_Portfolio_Analysis
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes GUI_Portfolio_Analysis wait for user response (see UIRESUME)
% uiwait(handles.figure1);


 
%get the string data from the popupmenu
%notice the string data is in a cell format
stringPath = get(handles.path_edit,'String');

% --- Outputs from this function are returned to the command line.
function varargout = GUI_Portfolio_Analysis_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in Method_popupmenu.
function Method_popupmenu_Callback(hObject, eventdata, handles)
% hObject    handle to Method_popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns Method_popupmenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from Method_popupmenu


% --- Executes during object creation, after setting all properties.
function Method_popupmenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Method_popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function Pathedit_Callback(hObject, eventdata, handles)
% hObject    handle to Pathedit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Pathedit as text
%        str2double(get(hObject,'String')) returns contents of Pathedit as a double


% --- Executes during object creation, after setting all properties.
function Pathedit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Pathedit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on button press in graph_pushbutton.
function graph_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to graph_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in Op_pushbutton.
function Op_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to Op_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB

% get the Path of the XLS file
stringPath = get(handles.path_edit,'String');

%get the Method/strategy value of the current selection
choiceValueMethod = get(handles.Method_popupmenu,'Value');
%get the string of the current selection
choiceStringMethod = get(handles.Method_popupmenu,'String');
Method = choiceStringMethod{choiceValueMethod};

%get the simulation value of the current selection
simuValueMethod = get(handles.Simu_popupmenu,'Value');
%get the string of the current selection
simuStringMethod = get(handles.Simu_popupmenu,'String');
Simulation = simuStringMethod{simuValueMethod};

% get the Risk free rate
RisklessRate = str2num(get(handles.Riskfree_edit,'String'));

% get the transaction cost
TransactionCostRate = str2num(get(handles.Txn_edit,'String'));


set(gcf,'Pointer','watch')
[ret_string,Xvalues,CumPNL,CumPNLminusTXN,PNL10day,VAR95,VAR99,CVAR95,CVAR99]=...
    Engine_Pf_Analysis(stringPath,Method,Simulation,RisklessRate,TransactionCostRate);
set(handles.Output_text,'String',ret_string);

%reset(handles.Pnl_axes);
%reset(handles.Var_axes);
%clf('reset');
create_graph_pnl(handles.Pnl_axes,Xvalues',[CumPNL' CumPNLminusTXN']);
create_graph_var(handles.Var_axes,Xvalues',[abs(PNL10day') abs(VAR95') abs(VAR99') abs(CVAR95') abs(CVAR99')]);
set(gcf,'Pointer','arrow')
%create_graph(handles.Pnl_axes,handles.Var_axes,Xvalues',CumPNL',[abs(PNL10day') abs(VAR95') abs(VAR99') abs(CVAR95') abs(CVAR99')]);

%handles.output = hObject;
% Update handles structure
%guidata(hObject, handles);


% --- Executes on selection change in Simu_popupmenu.
function Simu_popupmenu_Callback(hObject, eventdata, handles)
% hObject    handle to Simu_popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns Simu_popupmenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from Simu_popupmenu


% --- Executes during object creation, after setting all properties.
function Simu_popupmenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Simu_popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end





function Riskfree_edit_Callback(hObject, eventdata, handles)
% hObject    handle to Riskfree_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Riskfree_edit as text
%        str2double(get(hObject,'String')) returns contents of Riskfree_edit as a double


% --- Executes during object creation, after setting all properties.
function Riskfree_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Riskfree_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function Txn_edit_Callback(hObject, eventdata, handles)
% hObject    handle to Txn_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Txn_edit as text
%        str2double(get(hObject,'String')) returns contents of Txn_edit as a double


% --- Executes during object creation, after setting all properties.
function Txn_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Txn_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


