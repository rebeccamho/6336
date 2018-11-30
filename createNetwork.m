% createNetwork.m
% Returns parameters related to IC network.
% Inputs: handles (used for GUI), nLayers (# layers), nPoints (# points),
% reduce (0 if reduce model order, 1 otherwise), materialLayers (irene
% explain), transState (0 if transistors off, 1 otherwise)
% Outputs: x_start (initial node values), u (vector of source values), p
% (matrix of material properties btwn nodes), otherParams (struct of
% parameters related to IC).

function [u,p,otherParams] = createNetwork(handles,nLayers,...
    nPoints,materialLayers,transState)

%% User-defined parameters for IC (ONLY MODIFY THESE VARIABLES)
Si = 'Silicon';
Cu = 'Copper';
Gr = 'Graphene';
Air = 'Air';
Ox = 'Oxide'; % SiO2
Via = 'Via';

% nLayers = 40;
% nPoints = 40;

% materialLayers = [{Cu} {Gr} {Si}]; % list materials from top to bottom

thickness = struct; 
thickness.(Si) = 0.005; % 0.025
% thickness.(Bond) = 0.05;
thickness.(Cu) = 0.02;
thickness.(Gr) = 0.005; % 0.005
thickness.(Ox) = 0.025;
thickness.(Via) = 0.02;

chipW = 0.1;
viaW = 0.005; % horizontal thickness of metal via
%pts_via = 2; % for debugging

[~,~,~,Tstart,~,pts_via] = getGlobalVars; % Room temperature 
T0 = 298;  % temp of heat sink (K)

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
hc.(Cu) = 0.385e3;
hc.(Gr) = 0.7e3; % Graphite specific heat used instead of graphene
hc.(Air) = 1e3;
hc.(Ox) = 1e3;

% Thermal conductivity , units W/(m*K)
k = struct;
k.(Si) = 155; 
k.(Cu) = 400; 
k.(Gr) = 5000; 
k.(Air) = 0.02; 
k.(Ox) = 1.2;

% Density, untis kg/m^3
dens = struct;
dens.(Si) = 2.329e3; 
dens.(Cu) = 8.92e3; 
dens.(Gr) = 2.267e3;
dens.(Air) = 1.225; 
dens.(Ox) = 2.65e3;

% Calculate p values
pVals = struct; 
pVals.(Si) = (k.(Si)/(dens.(Si)*hc.(Si)));
pVals.(Cu) = (k.(Cu)/(dens.(Cu)*hc.(Cu)));
pVals.(Gr) = (k.(Gr)/(dens.(Gr)*hc.(Gr)));
pVals.(Air) = k.(Air)/(dens.(Air)*hc.(Air));
pVals.(Ox) = k.(Ox)/(dens.(Ox)*hc.(Ox));


% pVals = struct; 
% pVals.(Si) = 1/(k.(Si));
% pVals.(Bond) = 1/(k.(Bond));
% pVals.(Cu) = 1/(k.(Cu));
% pVals.(Gr) = 1/(k.(Gr));
% pVals.(Air) = k.(Air);
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
plotColor.(Ox) = 4; 
plotColor.(Air) = 5;
plotColor.(Via) = 6;

for i = 1:nUniqueLayers
    m = materialLayers{i};
    startLayers(i) =  startIndex; 
    endIndex = startIndex + floor(thickness.(m)/minLayerThickness) - 1;
    if i == nUniqueLayers 
        endIndex = nLayers;
    end
    if convertCharsToStrings(m) == 'Graphene'  % note where Gr layers are
        graphene_i(startIndex:endIndex) = 1;
    end
    if convertCharsToStrings(m) == 'Via'
        metal = 0;  % alternate btwn metal and oxide
        num_vias = chipW/viaW;  % num of vias in layer
        %pts_via = floor(nPoints/num_vias); % number of point in via
        v_layer = zeros(1,nPoints);
        for j = 1:pts_via:nPoints  % make sure vias don't wrap around layers
            if j+pts_via-1 < nPoints
                jend = j+pts_via-1;
            else
                jend = nPoints;
            end
            if metal
                v_layer(j:jend) = pVals.(Cu);
                metal = 0;
            else
                v_layer(j:jend) = pVals.(Ox);
                metal = 1;
            end
        end
        for k = startIndex:endIndex
            p(k,:) = v_layer;
        end
    else  %% all values consistent across layer
        p(startIndex:endIndex,:) = pVals.(m); 
    end
    plotLayers(startIndex:endIndex,:) = plotColor.(m);
    startIndex = endIndex + 1; 
end 

plotIC(plotLayers,startLayers,materialLayers,3,handles);

%% Construct source (u) vector. 
% SOURCES:
% 1) transistor heat source, 2) x-direction leakage to air, 3) y-direction
% leakage to air, 4) heat leakage to SiO2 wafer, 5) heat sinks connected to
% graphene layers

if transState
    Power_diss = 2e9; %Units [W/m^3], Power dissipated per transistor
else
    Power_diss = 0;
end
Source_Trans = Power_diss/(dens.(Si)*hc.(Si));
Source_air = Tstart*pVals.Air; %Units, [W/m^3], heat source for air BC. 
Source_SiO2 = Tstart*pVals.(Ox); %Units, [W/m^3], heat source for SiO2 BC. 
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
otherParams.kOx = pVals.(Ox);
otherParams.kGr = pVals.(Gr);
otherParams.gr_i = graphene_i;
