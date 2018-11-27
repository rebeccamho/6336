clear all; close all; clc;

% options = optimoptions('fsolve','PlotFcn',@optimplotfirstorderopt,'Algorithm','levenberg-marquardt','Display','iter-detailed','OptimalityTolerance',1e-8,'StepTolerance',1e-6);
options = optimoptions('fmincon','PlotFcn',@optimplotfirstorderopt,'Algorithm','interior-point','Display','iter-detailed','OptimalityTolerance',1e-12,'StepTolerance',1e-6);
fun = @optimizeIC;
tSi = 0.015;  
tCu = 0.015;
lb = [0.01 ; 0.01];
ub = [0.03 ; 0.03];
% pSi = 1e-04;
% pCu = 1e-04;
% pGr = 3e-3;
% lb = [0.9e-4 ; 0.9e-4 ; 2.9e-3];
% ub = [1.1e-4; 1.1e-4 ; 3.1e-3];
% thicknessFinal = fsolve(fun,[tSi tCu],options)
thicknessFinal = fmincon(fun,[tSi tCu],[],[],[],[],lb,ub,[],options)
% pFinal = fmincon(fun,[pSi pCu pGr],[],[],[],[],lb,ub,[],options)

function objICtemp = optimizeIC(params)
disp(params)
%% User-defined parameters for IC (ONLY MODIFY THESE VARIABLES)
Si = 'Silicon';
Bond = 'Bond';
Cu = 'Copper';
Gr = 'Graphene';
Air = 'Air';


nLayers = 40;
nPoints = 40;

materialLayers = [{Gr} {Cu} {Si}]; % list materials from top to bottom
% materialLayers = [{Cu} {Si}]; % list materials from top to bottom

transState = 1;

tSi = params(1);
tCu = params(2);

thickness = struct; 
thickness.(Si) = tSi; % 0.025
% thickness.(Bond) = 0.05;
thickness.(Cu) = tCu; % 0.02
thickness.(Gr) = 0.005; % 0.005

chipW = 0.01;

Tstart = 298; 
T0 = 298;  % temp of heat sink (K)

t_stop = 10;
timestep = 1;

reduce = 0;

x_start = initializeNodes(nLayers,nPoints,Tstart,reduce);
setInitialParams(x_start,0); % set initial x and t


%% Calculate chip height and make sure the discretization can accomodate for thinnest layer
nUniqueLayers = length(materialLayers);
materialThickness = sym(cell2mat(struct2cell(thickness)));

chipH = 0;
for i = 1:nUniqueLayers
    chipH = chipH + thickness.(materialLayers{i});
end

minLayerThickness = chipH / nLayers;
gcdThickness = double(gcd(materialThickness));

% assert(mod(gcdThickness,minLayerThickness) == 0 , 'ERROR: nLayers is not sufficient to discretize IC');

%% Calculate delta x and delta y 
deltx = chipW/(nPoints-1);
delty = chipH/(nLayers-1);

%% Material Parameters
% Specific heat capacity, units J/(kg*k)
hc = struct; 
hc.(Si) = 0.7e3; 
hc.(Bond) = 0.68e3;
hc.(Cu) = 0.385e3;
hc.(Gr) = 0.7e3; % Graphite specific heat used instead of graphene
hc.(Air) = 1e3;

% Thermal conductivity , units W/(m*K)
k = struct;
k.(Si) = 155; 
k.(Bond) = 1.38; 
k.(Cu) = 400; 
k.(Gr) = 5000; % monolayer graphene
k.(Air) = 0.02; 

% Density, untis kg/m^3
dens = struct;
dens.(Si) = 2.329e3; 
dens.(Bond) = 2.65e3; 
dens.(Cu) = 8.92e3; 
dens.(Gr) = 2.267e3; % monolayer graphene
dens.(Air) = 1.225; 

% Calculate p values
pVals = struct; 
pVals.(Si) = k.(Si)/(dens.(Si)*hc.(Si));
pVals.(Bond) = k.(Bond)/(dens.(Bond)*hc.(Bond));
pVals.(Cu) = k.(Cu)/(dens.(Cu)*hc.(Cu));
pVals.(Gr) = k.(Gr)/(dens.(Gr)*hc.(Gr));
pVals.(Air) = k.(Air)/(dens.(Air)*hc.(Air));

% pVals.(Si) = params(1);
% pVals.(Cu) = params(2);
% pVals.(Gr) = params(3);

%% Construct parameters (p) matrix
p = zeros(nLayers,nPoints);
graphene_i = zeros(nLayers,1);
plotLayers = zeros(nLayers,nPoints);
startLayers = zeros(nUniqueLayers,1); 
startIndex = 1;

plotColor = struct;
plotColor.(Si) = 1;
plotColor.(Cu) = 2;
plotColor.(Gr) = 3;
plotColor.(Bond) = 4; 
plotColor.(Air) = 5;

for i = 1:nUniqueLayers
    m = materialLayers{i};
    startLayers(i) =  startIndex; 
    endIndex = startIndex + floor(thickness.(m)/minLayerThickness) - 1;
    if i == nUniqueLayers 
        endIndex = nLayers;
    end
    if convertCharsToStrings(m) == 'Graphene'
        graphene_i(startIndex:endIndex) = 1;
    end
    p(startIndex:endIndex,:) = pVals.(m); 
    plotLayers(startIndex:endIndex,:) = plotColor.(m);
    startIndex = endIndex + 1; 
end 

% plotIC(plotLayers,startLayers,materialLayers,3);

%% Construct source (u) vector. 
% SOURCES:
% 1) transistor heat source, 2) x-direction leakage to air, 3) y-direction
% leakage to air, 4) heat leakage to SiO2 wafer, 5) heat sinks connected to
% graphene layers

if transState
    Power_diss = 2e8; %Units [W/m^3], Power dissipated per transistor
else
    Power_diss = 0;
end
Source_Trans = Power_diss/(dens.(Si)*hc.(Si));
Source_air = Tstart*pVals.Air; %Units, [W/m^3], heat source for air BC. 
Source_SiO2 = Tstart*pVals.(Bond); %Units, [W/m^3], heat source for SiO2 BC. 
%Source_SiO2 = 0;
Source_sink = T0*pVals.(Gr);

u = [Source_Trans, Source_air/(deltx^2), Source_air/(delty^2), ... 
    Source_SiO2/(delty^2), Source_sink/(deltx^2)];
% divide source_trans to what power of delta y? need t work out units,
% previous reference lecture 3 slide 27

%% Define initial conditions and create struct of IC properties

otherParams = struct;
otherParams.chipW = chipW;
otherParams.chipH = chipH; 
otherParams.nLayers = nLayers;
otherParams.nPoints = nPoints;
otherParams.materialLayers = materialLayers;
otherParams.startLayers = startLayers;
otherParams.kAmb = pVals.Air;
otherParams.kBond = pVals.Bond;
otherParams.kGr = pVals.(Gr);
otherParams.gr_i = graphene_i;


% Model order reduction parameters
k = 70; % # of eigenvalues to calculate
order = 40;
% Plotting parameters
freq = 0;
% Get initial parameters
[x_start,t_start] = getInitialParams;
t_stop = t_stop+t_start;

nLayers = otherParams.nLayers;
nPoints = otherParams.nPoints; 
materialLayers = otherParams.materialLayers;
startLayers = otherParams.startLayers;

% construct A, B, and C matrices
[~,A,B,C] = F(x_start,u,p,reduce,otherParams); 

% plot steady state temperature profile
% SS = -A\(B*u');
% SS = reshape(SS,nPoints,nLayers)';
% f2 = figure(2);
% imagesc(SS);
% map = colorcet('D1');
% colormap(map);
% xlabel('node');
% ylabel('material layer');
% title('Steady State');
% set(gca,'ytick',startLayers,'yticklabel',materialLayers,'fontsize',12)
% colorbar;

%% Run trapezoidal script. 
pVisualize = struct; 
pVisualize.params = p; 
pVisualize.time = t_stop; 
pVisualize.figNum = 10;
pVisualize.materialLayers = materialLayers;
pVisualize.startLayers = startLayers;

if reduce  % reduce order of model if reduce = 1
    [A,B,C] = reduceOrder(A,B,C,order,k);
    nPoints = 4;
    nLayers = 10;
    pVisualize.nPoints = nPoints;
    pVisualize.nLayers = nLayers;
else
    pVisualize.nPoints = nPoints;
    pVisualize.nLayers = nLayers;
end
 
% X = ForwardEuler('F',x_start,eval_u,p,t_start,t_stop,timestep,1,200);

% if reduce
%     fhand = @(x,t)fj2DIC(x,t,A,B);
% else
    fhand = @(x,t)fj2DIC(x,t,A,B*u');
% end
% x_trap = trapezoidalNonlinear(C,x_start,t_start,t_stop,timestep,fhand,freq,pVisualize,handles);
[x_trap,tf] = trapezoidalNonlinear_dynamic(C,x_start,t_start,t_stop,timestep,fhand,freq,pVisualize);
x_trapFinal = x_trap(:,end);
% setInitialParams(x_trapFinal,tf);

% maxTemp = num2str(max(x_trapFinal));
% set(handles.maxTempValue,'String',maxTemp);
% drawnow;

objICtemp = var(x_trapFinal);
end