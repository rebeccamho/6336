function X = ForwardEuler(eval_f,x_start,eval_u,p,t_start,t_stop,timestep,visualize)
% uses Forward Euler to simulate states model dx/dt=f(x,u,p)
% from state x_start at time t_start
% until time t_stop, with time intervals timestep
% eval_f is a string including the name of the function that evaluates f(x,u,p)
% eval_u os a string including the name of the funciton that evaluates u(t)
% 
% X = ForwardEuler(eval_f,x_start,eval_u,p,t_start,t_stop,timestep)

% copyright Luca Daniel, MIT 2018

<<<<<<< HEAD
nLayers= size(p,1);
nPoints=size(p,2);

=======
>>>>>>> 76312ee6cd7bce403a4d966ed0563c8f2f90f223
X(:,1) = x_start;
t(1) = t_start;
% if visualize
%    visualizeResults(t,X,1,'.b');
% end
   figure(2)
<<<<<<< HEAD
   imagesc(reshape(X(:,1),nPoints,nLayers)')
   colorbar;
%    pause;
=======
   imagesc(reshape(X(:,1),10,5)')
   colorbar;
   %pause;
>>>>>>> 76312ee6cd7bce403a4d966ed0563c8f2f90f223
for n=1:ceil((t_stop-t_start)/timestep)
   dt = min(timestep, (t_stop-t(n)));
   t(n+1)= t(n) + dt;
   u = eval_u;
   f = feval(eval_f, X(:,n), u, p); 
   X(:,n+1)= X(:,n) +  dt * f;
%    if visualize
%       visualizeResults(t,X,n+1,'.b');
%    end
   figure(2)
<<<<<<< HEAD
   imagesc(reshape(X(:,n+1),nPoints,nLayers)')
   colorbar;
%    pause;
=======
   imagesc(reshape(X(:,n+1),10,5)')
   colorbar;
   %pause;
>>>>>>> 76312ee6cd7bce403a4d966ed0563c8f2f90f223
end
