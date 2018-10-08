function [J_approx] = J_approx(F,x_start,u,p,eps)
%This function approximates the Jacobian with a step of eps.  
%Iterate over npoints*nlayers. 
nLayers = 5;
nPoints = 10;

J_approx = zeros(nLayers*nPoints,nLayers*nPoints);
for n = 1:(nLayers*nPoints)
    x_loop = x_start;
    x_loop(n) = x_start(n)+eps;
    J_approx(:,n)=((F(x_loop,u,p)-F(x_start,u,p))./eps);
    
end



