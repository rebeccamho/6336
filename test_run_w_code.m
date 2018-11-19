clear all; close all; clc;
<<<<<<< HEAD
%% User input: IC parameters (ONLY NEED TO CHANGE VALUES IN THIS SECTION)
=======
%% User-defined parameters for IC (ONLY MODIFY THESE VARIABLES)
>>>>>>> irene
Si = 'Si';
Bond = 'Bond';
Cu = 'Cu';
Gr = 'Gr';
Air = 'Air';

<<<<<<< HEAD
nPoints = 40;
nLayers = 40;

materialLayers = [{Cu} {Gr} {Si}]; % list layers in order from top to bottom

thickness = struct;
thickness.(Si) = 0.025;
=======
nLayers = 40;
nPoints = 40;

materialLayers = [{Cu} {Si} {Gr} {Si}]; % list materials from top to bottom

thickness = struct; 
thickness.(Si) = 0.0125; 
>>>>>>> irene
% thickness.(Bond) = 0.05;
thickness.(Cu) = 0.02;
thickness.(Gr) = 0.005;

<<<<<<< HEAD
chipW = 0.1; 

Troom = 298; %Room temperature to start

%% Compute total chip height and check that thinnest layers is multiple of chip height / nLayers 
chipH = 0;
thinnestLayer = Gr;
for i = 1:length(materialLayers)
    chipH = chipH + thickness.(materialLayers{i});
end 

thicknessArray = sym(cell2mat(struct2cell(thickness))); 
gcdThickness = double(gcd(thicknessArray));

minLayerThickness = chipH / nLayers; 
assert(mod(gcdThickness,minLayerThickness) == 0 , 'ERROR: thinnest layer is not a multiple of minimum layer thickness');

%% Parameters/Material Properties

To = 298; %Room temperature 
=======
chipW = 0.1;

Tstart = 298; %Room temperature 

%% Calculate chip height and make sure the discretization can accomodate for thinnest layer
nUniqueLayers = length(materialLayers);
materialThickness = sym(cell2mat(struct2cell(thickness)));

chipH = 0;
for i = 1:nUniqueLayers
    chipH = chipH + thickness.(materialLayers{i});
end
>>>>>>> irene

minLayerThickness = chipH / nLayers;
gcdThickness = double(gcd(materialThickness));

assert(mod(gcdThickness,minLayerThickness) == 0 , 'ERROR: nLayers is not sufficient to discretize IC');

%% Material Parameters
% Specific heat capacity, units J/(kg*k)
<<<<<<< HEAD
hcap = ones(nLayers,nPoints);
hc = struct; % struct of specific heat values
hc.(Si) = 0.7e3; % Silicon
hc.(Bond) = 0.68e3; % Silicon dioxide, bonding and oxide layer
hc.(Cu) = 0.385e3; % Copper
hc.(Gr) = 0.7e3; % Graphite specific heat used instead of graphene
hc.(Air) = 1e3; % Ambient Air 

% Thermal conductivity , units W/(m*K)
k2 = ones(nLayers,nPoints);
k = struct; % struct of thermal conductivity values
k.(Si) = 155; % Silicon
k.(Bond) = 1.38; % Silicon dioxide, bonding and oxide layer
k.(Cu) = 400; % Copper
k.(Gr) = 5000; % Monolayer graphene
k.(Air) = 0.02; % Ambient air

% Density, untis kg/m^3
dens2 = ones(nLayers,nPoints);
dens = struct; % struct of thermal conductivity values
dens.(Si) = 2.329e3; % Silicon
dens.(Bond) = 2.65e3; % Silicon dioxide, bonding and oxide layer
dens.(Cu) = 8.92e3; % Copper
dens.(Gr) = 2.267e3; % Monolayer graphene
dens.(Air) = 1.225; % Ambient air

% Calculate p values
pVals = struct; 
pVals.(Si) = k.Si/(dens.Si*hc.Si);
pVals.(Bond) = k.Bond/(dens.Bond*hc.Bond);
pVals.(Cu) = k.Cu/(dens.Cu*hc.Cu);
pVals.(Gr) = k.Gr/(dens.Gr*hc.Gr);
pVals.(Air) = k.Air/(dens.Air*hc.Air);


%% Construct p matrix
p = zeros(nLayers,nPoints); % A, k/(p*Cp)
nUniqueLayers = length(materialLayers); 

startIndex = 1;
startLayers = zeros(nUniqueLayers,1);
for i = 1:nUniqueLayers
    startLayers(i) = startIndex;
    endIndex = startIndex + thickness.(materialLayers{i})/minLayerThickness - 1;
    p(startIndex:endIndex,:) = pVals.(materialLayers{i});
    startIndex = endIndex + 1;
end 

%% Construct u vector. 
Power_diss = 2e5; %Units [W/m^3], Power dissipated per transistor
Source_Trans = Power_diss/(dens.(Si)*hc.(Si));
Source_air = To*(k.(Air)/(dens.(Air)*hc.(Air))); %Units, [W/m^3], heat source for air BC. 
=======
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

%% Construct p matrix 
p = zeros(nLayers,nPoints);
plotLayers = zeros(nLayers,nPoints);
startLayers = zeros(nUniqueLayers,1); 
startIndex = 1;

plotColor = struct;
plotColor.(Si) = 1;
plotColor.(Bond) = 2; 
plotColor.(Cu) = 3;
plotColor.(Gr) = 4;
plotColor.(Air) = 5;

for i = 1:nUniqueLayers
    m = materialLayers{i};
    startLayers(i) =  startIndex; 
    endIndex = startIndex + thickness.(m)/minLayerThickness - 1;
    p(startIndex:endIndex,:) = pVals.(m); 
    plotLayers(startIndex:endIndex,:) = plotColor.(m);
    startIndex = endIndex + 1; 
end 

plotIC(plotLayers,startLayers,materialLayers,3);

%% Construct u vector. 
Power_diss = 2e5; %Units [W/m^3], Power dissipated per transistor
Source_Trans = Power_diss/(dens.(Si)*hc.(Si));
Source_air = Tstart*(k.(Air)/(dens.(Air)*hc.(Air))); %Units, [W/m^3], heat source for air BC. 
>>>>>>> irene
%Source_SiO2 = To*(kBond/(dens_Bond*hc_Bond)); %Units, [W/m^3], heat source for SiO2 BC. 
Source_SiO2 = 0;

u = [Source_Trans, Source_air, Source_air, Source_SiO2];
%First entry is for the heat source in first layer. 
%Second entry is the heat source for the boundary conditions. 

%% Use function F
%p = p/100;
%u = u/100;
x_start = zeros(nLayers*nPoints,1);
<<<<<<< HEAD
x_start(:) = Troom;

otherParams = struct;
otherParams.chipW = chipW;
otherParams.chipH = chipH;
=======
x_start(:) = Tstart; %Room temperature to start

otherParams = struct;
otherParams.chipW = chipW;
otherParams.chipH = chipH; 
>>>>>>> irene

[dx_dt,A_mat,U_vec] = F(x_start,u,p,otherParams);

x_steady=-U_vec\A_mat;
X_steady = vec2mat(x_steady,nPoints);
% figure(100)
% imagesc(X_steady);
% colorbar;
%% Run Euler script. 
t_start = 0;
<<<<<<< HEAD
t_stop = 10;
=======
t_stop = 1;
>>>>>>> irene
timestep = 0.1; 



eval_u = u;
% X = ForwardEuler('F',x_start,eval_u,p,t_start,t_stop,timestep,1,200);

pVisualize = struct; 
pVisualize.params = p; 
pVisualize.time = t_stop; 
pVisualize.nPoints = nPoints;
pVisualize.nLayers = nLayers;
pVisualize.figNum = 10;
<<<<<<< HEAD
pVisualize.startLayers = startLayers; 
pVisualize.materialLayers = materialLayers;
=======
pVisualize.materialLayers = materialLayers;
pVisualize.startLayers = startLayers;
>>>>>>> irene


t = t_start:timestep:t_stop;
fhand = @(x,t)fj2DIC(x,t,A_mat,U_vec);
freq = 5;
x_trap = trapezoidalNonlinear(x_start,t_start,t_stop,timestep,fhand,freq,pVisualize);
x_trapFinal = x_trap(:,end);


% visualizeNetwork(X(:,end),pVisualize);
% visualizeNetwork(x_trapFinal,pVisualize);