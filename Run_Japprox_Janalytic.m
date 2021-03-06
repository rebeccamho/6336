clc
clear all
nLayers = 5;
nPoints = 10;
p= zeros(nPoints,nLayers); % A, k/(p*Cp)
x_start = zeros(nLayers*nPoints,1);
x_start(:) = 298; %Room temperature to start
%% Ambient Parameters
kamb = 0.02; %Air thermal cond. [W/m*K]
dens_air = 1.225; %Air density [kg/m^3]
hc_air = 1e3; %Air specific heat capacity [J/kg*k]


To = 298; %Room temperature 

%% adding layers of k/(p*Cp)

%Matrix for thermal conductivity , units W/(m*K)
k = ones(nLayers,nPoints);
kSi = 155; % silicon
kBond = 1.38; % bonding and oxide layer
kCu = 400; % copper interconnects 
kGr = 5000; % monolayer graphene
k(1,:) = kSi;
k(2,:) = kGr;
k(3,:) = kBond;
k(4,:) = kCu;
k(5,:) = kCu;

%Matrix for density, untis kg/m^3
dens = ones(nLayers,nPoints);
dens_Si = 2.329e3; %Silicon
dens_Bond = 2.65e3; %SiliconDioxide
dens_Cu = 8.92e3; %Copper
dens_Gr = 2.267e3; %Graphene
dens(1,:) = dens_Si;
dens(2,:) = dens_Gr;
dens(3,:) = dens_Bond;
dens(4,:) = dens_Cu;
dens(5,:) = dens_Cu;

%Matrix for specific heat capacity, units J/(kg*k)
hcap = ones(nLayers,nPoints);
hc_Si = 0.7e3; %Silicon
hc_Bond = 0.68e3; %SiliconDioxide
hc_Cu = 0.385e3; %Copper
hc_Gr = 0.7e3; %Graphite specific heat used instead of graphene. 
hcap(1,:) = hc_Si;
hcap(2,:) = hc_Gr;
hcap(3,:) = hc_Bond;
hcap(4,:) = hc_Cu;
hcap(5,:) = hc_Cu;
%% Calculate p matrix. 
p = k./(dens.*hcap); % A, k/(p*Cp)
%% Construct u vector. 
Power_diss = 2.25e12; %Units [W/m^3], Power dissipated per transistor
Source_Trans = Power_diss/(dens_Si*hc_Si);
Source_air = To*(kamb/(dens_air*hc_air)); %Units, [W/m^3], heat source for air BC. 
Source_SiO2 = To*(kBond/(dens_Bond*hc_Bond)); %Units, [W/m^3], heat source for SiO2 BC. 


u = [Source_Trans, Source_air, Source_SiO2]; 
%First entry is for the heat source in first layer. 
%Second entry is the heat source for the boundary conditions. 
%% Run J_approx
eps = 0.01;
% J_approx = J_approx('F',x_start,u,p,eps);

nLayers = 5;
nPoints = 10;

J_approx = zeros(nLayers*nPoints,nLayers*nPoints);
for n = 1:(nLayers*nPoints)
    x_loop = x_start;
    x_loop(n) = x_start(n)+eps;
    J_approx(:,n)=((F(x_loop,u,p)-F(x_start,u,p))./eps);
    
end

figure(1); 
subplot(221)
spy(J_approx)
title('J approx')
subplot(222)
imagesc(J_approx)
axis square
title('J approx')

%% Run J_analytic
[J_analytic] = J_analytic('F',x_start,u,p);
figure(1); 
subplot(223)
spy(J_analytic)
title('J approx')
subplot(224)
imagesc(J_analytic)
axis square
title('J analytic')

%% Diff Calc
maxDiff = max(max(diff(J_analytic-J_approx)))