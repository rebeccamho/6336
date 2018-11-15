function phi = trapezoidalNonlinear(phi_i,t_i,t_f,dt,f,freq,pVisualize)

iter = (t_f-t_i)/dt;
t = t_i; 
phi(:,1) = phi_i;

pVisualize.time = t;
visualizeNetwork(phi(:,1),pVisualize);
% 	Create GIF filej
filename = 'temperatureProfile.gif';
frame = getframe(gcf);
im = frame2im(frame);
[imind,cm] = rgb2ind(im,256);
imwrite(imind,cm,filename,'gif','DelayTime',0.25,'Loopcount',inf);

count = 1;

for i = 2:iter+1
    t_prev = t; 
    phi_prev = phi(:,i-1);
    F = f(phi_prev,t_prev);
    gamma = phi_prev + dt/2*F;
    t = t+dt;
    ftrap = @(phi)trapezoidalSolve(f,t,dt,phi,gamma);
    phi(:,i) = newtonNd(ftrap,phi_prev);
    
    count = count + 1;
    if count == freq
        pVisualize.time = t;
        visualizeNetwork(phi(:,i),pVisualize);
        
        % Write to the GIF file
        frame = getframe(gcf);
        im = frame2im(frame);
        [imind,cm] = rgb2ind(im,256);
        imwrite(imind,cm,filename,'gif','DelayTime',0.25,'WriteMode','append');
        
        count = 1;
    end
end

end