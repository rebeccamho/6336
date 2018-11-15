clear all; close all; clc;
nLayers = 10;
nPoints = 40;
p= zeros(nPoints,nLayers); % A, k/(p*Cp)
x_start = zeros(nLayers*nPoints,1);
x_start(:) = 298; %Room temperature to start
%% Parameters

To = 298; %Room temperature 

% Ambient
kamb = 0.02; %Air thermal cond. [W/m*K]
dens_air = 1.225; %Air density [kg/m^3]
hc_air = 1e3; %Air specific heat capacity [J/kg*k]

% Specific heat capacity, units J/(kg*k)
hcap = ones(nLayers,nPoints);
hc_Si = 0.7e3; %Silicon
hc_Bond = 0.68e3; %SiliconDioxide
hc_Cu = 0.385e3; %Copper
hc_Gr = 0.7e3; %Graphite specific heat used instead of graphene. 
hcap(6:10,:) = hc_Si;
hcap(5,:) = hc_Gr;
hcap(1:4,:) = hc_Cu;
% hctest = 0.5e3;
% hcap(:,:) = hctest;

% Thermal conductivity , units W/(m*K)
k = ones(nLayers,nPoints);
kSi = 155; % silicon
kBond = 1.38; % bonding and oxide layer
kCu = 400; % copper interconnects 
kGr = 5000; % monolayer graphene
k(6:10,:) = kSi; % bottom
k(5,:) = kGr;
k(1:4,:) = kCu; % 1: top
% ktest = 80;
% k(:,:) = ktest;
% k(nLayers-1,:) = 200;

% Density, untis kg/m^3
dens = ones(nLayers,nPoints);
dens_Si = 2.329e3; %Silicon
dens_Bond = 2.65e3; %SiliconDioxide
dens_Cu = 8.92e3; %Copper
dens_Gr = 2.267e3; %Graphene
dens(6:10,:) = dens_Si;
dens(5,:) = dens_Gr;
dens(1:4,:) = dens_Cu;
% dens_test = 2.5e3;
% dens(:,:) = dens_test;

% Calculate p matrix.
p = k./(dens.*hcap); % A, k/(p*Cp)
%% Construct u vector. 
Power_diss = 2e5; %Units [W/m^3], Power dissipated per transistor
Source_Trans = Power_diss/(dens_Si*hc_Si);
Source_air = To*(kamb/(dens_air*hc_air)); %Units, [W/m^3], heat source for air BC. 
%Source_SiO2 = To*(kBond/(dens_Bond*hc_Bond)); %Units, [W/m^3], heat source for SiO2 BC. 
Source_SiO2 = 0;

u = [Source_Trans, Source_air, Source_air, Source_SiO2];
%First entry is for the heat source in first layer. 
%Second entry is the heat source for the boundary conditions. 

%% Use function F
%p = p/100;
%u = u/100;

[dx_dt,A_mat,U_vec] = F(x_start,u,p);

x_steady=-U_vec\A_mat;
X_steady = vec2mat(x_steady,nPoints);
figure(100)
imagesc(X_steady);
colorbar;
%% Run Euler script. 
x_start = zeros(nLayers*nPoints,1);
x_start(:) = 298; %Room temperature Start
t_start = 0;
t_stop = 10;
timestep = 1; 



eval_u = u;
% X = ForwardEuler('F',x_start,eval_u,p,t_start,t_stop,timestep,1,200);

pVisualize = struct; 
pVisualize.params = p; 
pVisualize.time = t_stop; 
pVisualize.nPoints = nPoints;
pVisualize.nLayers = nLayers;
pVisualize.figNum = 10;


t = t_start:timestep:t_stop;
fhand = @(x,t)fj2DIC(x,t,A_mat,U_vec);
freq = 2;
x_trap = trapezoidalNonlinear(x_start,t_start,t_stop,timestep,fhand,freq,pVisualize);
x_trapFinal = x_trap(:,end);


% visualizeNetwork(X(:,end),pVisualize);
% visualizeNetwork(x_trapFinal,pVisualize);