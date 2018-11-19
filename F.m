function [dx_dt,A_mat,U_vec] = F(x,u,p,otherParams)
%% x is a vector of our unknowns (temperature)
% u is a vector containing all known sources/excitations (heat flow)
% p contains all parameters of system (thermal conductivity)
% nLayers = p.layers;
% nPoints = p.points;
kAmb = u(2)/298; % Units [W/m*k]
nLayers= size(p,1);
nPoints=size(p,2);

% ChipW = 0.1; % chip width is 1 cm.
% ChipH = 0.05; % chip height is 1 mm.

chipW = otherParams.chipW;
chipH = otherParams.chipH;

deltx = chipW/(nPoints-1);
delty = chipH/(nLayers-1);
% x = p\u;

k = p;

%k = 1./k; 
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
%B2d(1:40,1) = -kr(11:end); %vertical
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
B2d(botLeft,3) = B2d(botLeft,3) + (kr(botLeft+1) + kAmb)/(deltx^2) + kr(botLeft-N)/(delty^2);
B2d(botRight,3) = B2d(botRight,3) + (kr(botRight-1) + kAmb)/(deltx^2) + kr(botRight-N)/(delty^2);
% edges
for i = topLeft+1:topRight-1 % top edge
    B2d(i,3) = B2d(i,3) + (kr(i+1) + kr(i-1))/(deltx^2) + (kr(i+N) + kAmb)/(delty^2); 
end
for i = botLeft+1:botRight-1 % bottom edge
    B2d(i,3) = B2d(i,3) + (kr(i+1) + kr(i-1))/(deltx^2) + kr(i-N)/(delty^2);
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

% construct 2d sparse matrix
A2d = spdiags(B2d,d2d,A2d);

%A2d = -1*A2d/(delt^2); 
A2d = -1*A2d;
%% Construct B Matrix.
% B(:,1) = Transistors heating up
% B(:,2) = X-dir air leakage
% B(:,3) = Y-dir air leakage
% B(:,4) = SiO2 SiO2 leakage
B = zeros(nPoints*nLayers,size(u,2)) ;

% TRANSISTOR HEAT SOURCE
%First layer, experiencing transistors heating up.
B((1+(nLayers-1)*(nPoints)):nPoints*nLayers,1) = B((1+(nLayers-1)*(nPoints)):nPoints*nLayers,1)+1; 

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

%% Adjust sources vector. 

u(1) = u(1)/delty^0; %reference lecture 3, slide 27. **still need to work out units here
u(2) = u(2)/(deltx^2); % was *, changed to /
u(3) = u(3)/(delty^2);
u(4) = u(4)/(delty^2);
% u(2) = u(2)/delt^2; %Based on hand calc. Errors may be made here. 
% u(3) = u(3)/delt^2; 

% u(1) = 0; 
% u(2) = 0;
% u(3) = 0; 

 


%% Plot Matrix A_2D
% figure; 
% subplot(121)
% spy(A2d)
% figTitle = ['sparsity pattern for ' int2str(nLayers) ' layer IC with ' int2str(nPoints) ' points per layer'];
% title(figTitle,'fontsize',20)
% subplot(122)
% imagesc(A2d)
% axis square

A_mat = A2d;
U_vec = B*u';

dx_dt = A2d*x+B*u'; % unsure of *delt^2 
