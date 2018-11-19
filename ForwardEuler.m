function X = ForwardEuler(eval_f,x_start,eval_u,p,t_start,t_stop,timestep,visualize,freq,pVisualize,otherParams)
% uses Forward Euler to simulate states model dx/dt=f(x,u,p)
% from state x_start at time t_start
% until time t_stop, with time intervals timestep
% eval_f is a string including the name of the function that evaluates f(x,u,p)
% eval_u os a string including the name of the funciton that evaluates u(t)
% 
% X = ForwardEuler(eval_f,x_start,eval_u,p,t_start,t_stop,timestep)

% copyright Luca Daniel, MIT 2018

nLayers= size(p,1);
nPoints=size(p,2);

X(:,1) = x_start;
t(1) = t_start;

pVisualize = struct; 
pVisualize.params = p; 
pVisualize.time = t_start; 
pVisualize.nPoints = nPoints;
pVisualize.nLayers = nLayers;
pVisualize.figNum = 10;
    
% if visualize
%    visualizeResults(t,X,1,'.b');
% end
%    figure(2)
%    imagesc(reshape(X(:,1),nPoints,nLayers)')
%    colorbar;
    visualizeNetwork(X(:,1),pVisualize);
    
    % 	Write to the GIF File
    filename = 'temperatureProfile.gif';
    frame = getframe(gcf);
    im = frame2im(frame);
    [imind,cm] = rgb2ind(im,256);
    imwrite(imind,cm,filename,'gif','DelayTime',0.25,'Loopcount',inf);

%    pause;

count = 1;
for n=1:ceil((t_stop-t_start)/timestep)
   dt = min(timestep, (t_stop-t(n)));
   t(n+1)= t(n) + dt;
   u = eval_u;
   f = feval(eval_f, X(:,n), u, p, otherParams); 
   X(:,n+1)= X(:,n) +  dt * f;
%    if visualize
%       visualizeResults(t,X,n+1,'.b');
%    end
   count = count + 1;
   if count == freq
%        figure(2)
%        imagesc(reshape(X(:,n+1),nPoints,nLayers)')
%        colorbar;
        pVisualize.time = t(n+1);
        visualizeNetwork(X(:,n+1),pVisualize);
        count = 1;
        
        frame = getframe(gcf);
        im = frame2im(frame);
        [imind,cm] = rgb2ind(im,256);
        imwrite(imind,cm,filename,'gif','DelayTime',0.25,'WriteMode','append');
   end
   %pause;
end
