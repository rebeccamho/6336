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
kReshaped = reshape(k',nLayers*nPoints,1);
A_2D = zeros(nLayers*nPoints,nLayers*nPoints);

topLeftCorner = 1;
topRightCorner = nPoints;
bottomLeftCorner = nLayers*nPoints-nPoints+1;
bottomRightCorner = nLayers*nPoints;


for i=1:nLayers*nPoints
    % corner nodes (i = 1, m, m^2-m+1, m^2)
    % 2 connections
    if i == topLeftCorner || i == topRightCorner || i == bottomLeftCorner || i == bottomRightCorner
%         A_2D(i,i) = 2;
            A_2D(i,i) = kAmb;
        if i == topLeftCorner 
            A_2D(i,i) = A_2D(i,i) + kReshaped(i+1) + kReshaped(i+nPoints);
            A_2D(i,i+1) = -kReshaped(i+1);
            A_2D(i,i+nPoints) = -kReshaped(i+nPoints);
        elseif i == topRightCorner
            A_2D(i,i) = A_2D(i,i) + kReshaped(i-1) + kReshaped(i+nPoints);
            A_2D(i,i-1) = -kReshaped(i-1);
            A_2D(i,i+nPoints) = -kReshaped(i+nPoints);           
        elseif i == bottomLeftCorner
            A_2D(i,i) = A_2D(i,i) + kReshaped(i+1) + kReshaped(i-nPoints);
            A_2D(i,i+1) = -kReshaped(i+1);
            A_2D(i,i-nPoints) = -kReshaped(i-nPoints);
        else 
            A_2D(i,i) = A_2D(i,i) + kReshaped(i-1) + kReshaped(i-nPoints);
            A_2D(i,i-1) = -kReshaped(i-1);
            A_2D(i,i-nPoints) = -kReshaped(i-nPoints);
        end
    
    % edge nodes (i = 2->(m-1), c*m+1, c*m, (m^2-m+1)->(m^2-1))
    % 3 connections 
    elseif i > topLeftCorner && i <= topRightCorner     % top edge
        A_2D(i,i) = kAmb + kReshaped(i+1) + kReshaped(i-1) + kReshaped(i+nPoints); 
        A_2D(i,i-1) = -kReshaped(i-1);
        A_2D(i,i+1) = -kReshaped(i+1);
        A_2D(i,i+nPoints) = -kReshaped(i+nPoints);
    elseif mod(i-1,nPoints) == 0 && i ~= topLeftCorner && i ~= bottomLeftCorner    % left edge
        A_2D(i,i) = kAmb + kReshaped(i+1) + kReshaped(i+nPoints) + kReshaped(i-nPoints); 
        A_2D(i,i+1) = -kReshaped(i+1);
        A_2D(i,i-nPoints) = -kReshaped(i-nPoints);
        A_2D(i,i+nPoints) = -kReshaped(i+nPoints);
    elseif mod(i,nPoints) == 0  && i ~= topRightCorner && i ~= bottomRightCorner   % right edge
        A_2D(i,i) = kAmb + kReshaped(i-1) + kReshaped(i+nPoints) + kReshaped(i-nPoints); 
        A_2D(i,i-1) = -kReshaped(i-1);
        A_2D(i,i-nPoints) = -kReshaped(i-nPoints);
        A_2D(i,i+nPoints) = -kReshaped(i+nPoints);
    elseif i > bottomLeftCorner && i < bottomRightCorner    % bottom edge
        A_2D(i,i) = kAmb + kReshaped(i+1) + kReshaped(i-1) + kReshaped(i-nPoints); 
        A_2D(i,i-1) = -kReshaped(i-1);
        A_2D(i,i+1) = -kReshaped(i+1);
        A_2D(i,i-nPoints) = -kReshaped(i-nPoints);
        
    % interior nodes (everything else)
    % 4 connections
    else
        A_2D(i,i) = kReshaped(i+1) + kReshaped(i-1) + kReshaped(i+nPoints) + kReshaped(i-nPoints);
        A_2D(i,i-1) = -kReshaped(i-1);
        A_2D(i,i+1) = -kReshaped(i+1);
        A_2D(i,i-nPoints) = -kReshaped(i-nPoints);
        A_2D(i,i+nPoints) = -kReshaped(i+nPoints);
    end 
end 

A_2D = A_2D/(delt^2);

%% Construct B Matrix.

B = zeros(nPoints*nLayers,size(u,2)) ;
B(1:nPoints,1) = 1; %FIrst layer, experiencing transistors heating up.

%Boundary conditions
B(1:nPoints, 2) = 1; 

for i = 1:(nLayers-2)
    B(i*nPoints+1,2) =1;
    B((i+1)*nPoints,2) = 1;
end
B((end-nPoints+1):end,2) = 1; 


% heat sink
% B(nPoints,2) = 1;
% B(nPoints*2-1,2) = 1;

% Mult delt to u.
u(2) = u(2)*delt; 



%% Plot Matrix A_2D
% figure; 
% subplot(121)
% spy(A_2D)
% subplot(122)
% imagesc(A_2D)
% axis square



dx_dt = A_2D*x*delt^2+B*u'; 
