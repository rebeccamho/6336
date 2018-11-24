function [x_start,u,p,otherParams] = createNetwork(handles,nLayers,nPoints,reduce)

%% User-defined parameters for IC (ONLY MODIFY THESE VARIABLES)
Si = 'Si';
Bond = 'Bond';
Cu = 'Cu';
Gr = 'Gr';
Air = 'Air';

% nLayers = 40;
% nPoints = 40;

materialLayers = [{Cu} {Gr} {Si}]; % list materials from top to bottom

thickness = struct; 
thickness.(Si) = 0.025; 
% thickness.(Bond) = 0.05;
thickness.(Cu) = 0.02;
thickness.(Gr) = 0.005;

chipW = 0.1;

Tstart = 298; %Room temperature 

%% Calculate chip height and make sure the discretization can accomodate for thinnest layer
nUniqueLayers = length(materialLayers);
materialThickness = sym(cell2mat(struct2cell(thickness)));

chipH = 0;
for i = 1:nUniqueLayers
    chipH = chipH + thickness.(materialLayers{i});
end

minLayerThickness = chipH / nLayers;
gcdThickness = double(gcd(materialThickness));

assert(mod(gcdThickness,minLayerThickness) == 0 , 'ERROR: nLayers is not sufficient to discretize IC');

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

%% Construct parameters (p) matrix
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

plotIC(plotLayers,startLayers,materialLayers,3,handles);

%% Construct source (u) vector. 
% SOURCES:
% 1) transistor heat source, 2) x-direction leakage to air, 3) y-direction
% leakage to air, 4) heat leakage to SiO2 wafer

Power_diss = 2e5; %Units [W/m^3], Power dissipated per transistor
Source_Trans = Power_diss/(dens.(Si)*hc.(Si));
Source_air = Tstart*(k.(Air)/(dens.(Air)*hc.(Air))); %Units, [W/m^3], heat source for air BC. 
Source_SiO2 = Tstart*pVals.Bond; %Units, [W/m^3], heat source for SiO2 BC. 
%Source_SiO2 = 0;

u = [Source_Trans, Source_air/(deltx^2), Source_air/(delty^2), ... 
    Source_SiO2/(delty^2)];
% divide source_trans to what power of delta y? need t work out units,
% previous reference lecture 3 slide 27

%% Define initial conditions and create struct of IC properties

if reduce
    x_start = zeros(order,1); % with model order reduction
else
    x_start = zeros(nLayers*nPoints,1); % no model order reduction
end
x_start(:) = Tstart; %Room temperature to start

otherParams = struct;
otherParams.chipW = chipW;
otherParams.chipH = chipH; 
otherParams.nLayers = nLayers;
otherParams.nPoints = nPoints;
otherParams.materialLayers = materialLayers;
otherParams.startLayers = startLayers;
