% F.m
% Creates A (nodal), B (input), and C (output) matrices and calculates the 
% rate of change over time.
% Inputs: x (unknown node values), u (source vector), p (parameter matrix),
% otherParams (contains parameters related to IC structure). 
% Outputs: dx_dt (rate of change over time), A_mat (A matrix), B (B vector,
% represents inputs to system).
function [dx_dt,A_mat,B,C] = F(x,u,p,reduce,otherParams)
chipW = otherParams.chipW;
chipH = otherParams.chipH;
nLayers= size(p,1);
nPoints=size(p,2);

deltx = chipW/(nPoints-1);
delty = chipH/(nLayers-1);

kAmb = otherParams.kAmb; % Units [W/m*k]
kOx = otherParams.kOx;
kGr = otherParams.kGr;

gr_i = otherParams.gr_i; % 1 if that layer # is graphene

k = p;

%% Construct A_2D Matrix. 
kr = reshape(k',nLayers*nPoints,1);

topLeft = 1;
topRight = nPoints;
botLeft = nLayers*nPoints-nPoints+1;
botRight = nLayers*nPoints;

N = nPoints; % every N x N is another layer
d2d = [-N -1 0 1 N];
A2d = sparse(N*nLayers,N*nLayers);
B2d = zeros(min(size(A2d)),length(d2d));
% bands
B2d(:,1) = -kr; B2d(:,5) = -kr; % vertical cxns
B2d(:,2) = -kr; B2d(:,4) = -kr; % horizontal cxns
for i = N:N:min(size(A2d)) % horizontal cxns, 0 every N bc of edge
    B2d(i,2) = 0;
    B2d(i+1,4) = 0; % i+1 bc of how it is put into A2d with spdiags
end
% main diagonal
% corners 
B2d(topLeft,3) = B2d(topLeft,3) + (kr(topLeft+1) + kAmb)/(deltx^2) + (kr(topLeft+N) + kAmb)/(delty^2);
B2d(topRight,3) = B2d(topRight,3) + (kr(topRight-1) + kAmb)/(deltx^2) + (kr(topRight+N) + kAmb)/(delty^2);
B2d(botLeft,3) = B2d(botLeft,3) + (kr(botLeft+1) + kAmb)/(deltx^2) + (kr(botLeft-N) + kOx)/(delty^2);
B2d(botRight,3) = B2d(botRight,3) + (kr(botRight-1) + kAmb)/(deltx^2) + (kr(botRight-N) + kOx)/(delty^2);
% edges
for i = topLeft+1:topRight-1 % top edge
    B2d(i,3) = B2d(i,3) + (kr(i+1) + kr(i-1))/(deltx^2) + (kr(i+N) + kAmb)/(delty^2); 
end
for i = botLeft+1:botRight-1 % bottom edge
    B2d(i,3) = B2d(i,3) + (kr(i+1) + kr(i-1))/(deltx^2) + (kr(i-N) + kOx)/(delty^2);
end
for i = topLeft+N:N:botLeft-N % left and right edges
    j = i+N-1; % index for right edge
    B2d(i,3) = B2d(i,3) + (kAmb + kr(i+1))/(deltx^2) + (kr(i-N) + kr(i+N))/(delty^2); % left
    B2d(j,3) = B2d(j,3) + (kAmb + kr(j-1))/(deltx^2) + (kr(j-N) + kr(j+N))/(delty^2); % right
end
% interior
for i = N+1:botRight-N
    if B2d(i,3) == 0 % interior node
        B2d(i,3) = B2d(i,3) + (kr(i+1) + kr(i-1))/(deltx^2) + (kr(i-N) + kr(i+N))/(delty^2);
    end
end
% horizontal 
B2d(:,2) = B2d(:,2)/(deltx^2);
B2d(:,4) = B2d(:,4)/(deltx^2);
% vertical
B2d(:,1) = B2d(:,1)/(delty^2);
B2d(:,5) = B2d(:,5)/(delty^2);

% add connections for graphene heat sinks
for i = 1:nLayers
    if gr_i(i)
        B2d((i-1)*nPoints+1,3) = B2d(i*nPoints,3) + (kGr - kAmb)/(deltx^2);
        B2d((i)*nPoints,3) = B2d((i)*nPoints,3) + (kGr - kAmb)/(deltx^2);
    end
end        

% construct 2d sparse matrix
A2d = spdiags(B2d,d2d,A2d);

A2d = -1*A2d;
%% Construct B Matrix.
% B(:,1) = Transistors heating up
% B(:,2) = X-dir air leakage
% B(:,3) = Y-dir air leakage
% B(:,4) = SiO2 leakage
% B(:,5) = heat sinks

B = zeros(nPoints*nLayers,size(u,2)) ;

% TRANSISTOR HEAT SOURCE
%right above bottom graphene layer, experiencing transistors heating up.
not_gr = find(gr_i == 0);
heatLayer = max(not_gr);  % layer right above bottom layer of graphene
B((1+(heatLayer-2)*(nPoints)):nPoints*heatLayer,1) = B((1+(heatLayer-2)*(nPoints)):nPoints*heatLayer,1)+1; 

% X-DIR AIR LEAKAGE
%Left Edge, leakage to air. 
B(1:nPoints:(nPoints*nLayers),2) = B(1:nPoints:(nPoints*nLayers),2) + 1; 
%Right Edge, leakage to air.
B((nPoints:nPoints:nPoints*nLayers),2) = B((nPoints:nPoints:nPoints*nLayers),2) + 1;

% Y-DIR AIR LEAKAGE
%Top Edge, leakage to air. 
B(1:nPoints,3) = B(1:nPoints,3) +1;

% SIO2 LEAKAGE
%Bottom Edge , also first layer, leakage to SiO2. 
B((1+(nLayers-1)*(nPoints)):nPoints*nLayers,4) = B((1+(nLayers-1)*(nPoints)):nPoints*nLayers,4)+1; 

% HEAT SINKS
% only connected to graphene layers
for i = 1:nLayers
    if gr_i(i)
        B((i-1)*nPoints+1,5) = B(i*nPoints,5) + 1;
        B((i)*nPoints,5) = B((i)*nPoints,5) + 1;
        % remove x-dir air leakage at these edges
        B((i-1)*nPoints+1,2) = B(i*nPoints,2) - 1;
        B((i)*nPoints,2) = B((i)*nPoints,2) - 1;
    end
end

%% Construct C matrix
% C = eye(nLayers*nPoints);
C = ones(nLayers*nPoints,1);

%% State Space Model
A_mat = A2d;
U_vec = B*u';

if ~reduce
    dx_dt = A2d*x+B*u'; 
else 
    dx_dt = 0;
end


