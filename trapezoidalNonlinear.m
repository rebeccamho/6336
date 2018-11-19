function phi = trapezoidalNonlinear(phi_i,t_i,t_f,dt,f,freq,pVisualize,varargin)

iter = (t_f-t_i)/dt;
t = t_i; 
phi(:,1) = phi_i;

pVisualize.time = t;
if ~isempty(varargin)
    visualizeNetwork(phi(:,1),pVisualize,varargin{1});
else
    visualizeNetwork(phi(:,1),pVisualize);
end

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
        if ~isempty(varargin)
            visualizeNetwork(phi(:,i),pVisualize,varargin{1});
        else
            visualizeNetwork(phi(:,i),pVisualize);
        end
        count = 1;
    end
end

end