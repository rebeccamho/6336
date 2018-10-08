function dx_dt = F(x,u,p)
% x is a vector of our unknowns (temperature)
% u is a vector containing all known sources/excitations (heat flow)
% p contains all parameters of system (thermal conductivity)
% nLayers = p.layers;
% nPoints = p.points;
kAmb = 0.1; 

nLayers= 5;
nPoints=10;
ChipW = 1e-2; % chipwidth is 1 cm.
delt = ChipW/(nPoints-1);
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
B2d(:,1) = -kr; B2d(:,5) = -kr; % vertical cxns
B2d(:,2) = -kr; B2d(:,4) = -kr; % horizontal cxns
for i = N:N:min(size(A2d)) % horizontal cxns, 0 every N bc of edge
    B2d(i,2) = 0;
    B2d(i+1,4) = 0; % i+1 bc of how it is put into A2d with spdiags
end
% main diagonal
% corners
B2d(topLeft,3) = B2d(topLeft,3) + kAmb + kr(topLeft+1) + kr(topLeft+N);
B2d(topRight,3) = B2d(topRight,3) + kAmb + kr(topRight-1) + kr(topRight+N);
B2d(botLeft,3) = B2d(botLeft,3) + kAmb + kr(botLeft+1) + kr(botLeft-N);
B2d(botRight,3) = B2d(botRight,3) + kAmb + kr(botRight-1) + kr(botRight-N);
% edges
for i = topLeft+1:topRight-1 % top edge
    B2d(i,3) = B2d(i,3) + kAmb + kr(i+1) + kr(i-1) + kr(i+N);
end
for i = botLeft+1:botRight-1 % bottom edge
    B2d(i,3) = B2d(i,3) + kAmb + kr(i+1) + kr(i-1) + kr(i-N);
end
for i = topLeft+N:N:botLeft-N % left and right edges
    j = i+N-1; % index for right edge
    B2d(i,3) = B2d(i,3) + kAmb + kr(i+1) + kr(i-N) + kr(i+N); % left
    B2d(j,3) = B2d(j,3) + kAmb + kr(j-1) + kr(j-N) + kr(j+N); % right
end
% interior
for i = N+1:botRight-N
    if B2d(i,3) == 0 % interior node
        B2d(i,3) = B2d(i,3) + kr(i+1) + kr(i-1) + kr(i-N) + kr(i+N);
    end
end
% construct 2d sparse matrix
A2d = spdiags(B2d,d2d,A2d);

A2d = A2d/(delt^2);

%% Construct B Matrix.

B = zeros(nPoints*nLayers,size(u,2)) ;
B(1:nPoints,1) = 1; %FIrst layer, experiencing transistors heating up.

%Boundary conditions
% B(1:nPoints, 2) = 1; 
% 
% for i = 1:(nLayers-2)
%     B(i*nPoints+1,2) =1;
%     B((i+1)*nPoints,2) = 1;
% end
% B((end-nPoints+1):end,2) = 1; 


% heat sink
B(nPoints,2) = 1;
B(nPoints*2-1,2) = 1;

% Mult delt to u.
u(2) = u(2)*delt; 



%% Plot Matrix A_2D
% figure; 
% subplot(121)
% spy(A_2D)
% subplot(122)
% imagesc(A_2D)
% axis square



dx_dt = A2d*x+B*u'; 
