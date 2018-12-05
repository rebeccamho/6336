function [x,t,Tchange] = trapezoidalNonlinear(C,xi,ti,tf,dt,f,freq,pVisualize,varargin)

iter = (tf-ti)/dt;
t = ti; 
x(:,1) = xi;

pVisualize.time = t;
if ~isempty(varargin)
    visualizeNetwork(x(:,1),pVisualize,varargin{1});
else
    visualizeNetwork(x(:,1),pVisualize);
end

count = 1;

for i = 2:iter+1
    t_prev = t; 
    x_prev = x(:,i-1);
    F = f(x_prev,t_prev);
    gamma = x_prev + dt/2*F;
    t = t+dt;
    ftrap = @(x)trapezoidalSolve(f,t,dt,x,gamma);
    x(:,i) = C.*newtonNd(ftrap,x_prev);
    
    %Calculate Tchange and store value. 
    if i > 1
        Tchange(i) = max(max(abs(x(:,i)-x(:,i-1)))); %Calculate Tchange. 
    end
    
    count = count + 1;
    if count >= freq
        pVisualize.time = t;
        if ~isempty(varargin)
            visualizeNetwork(x(:,i),pVisualize,varargin{1});
        else
            visualizeNetwork(x(:,i),pVisualize);
        end
        count = 1;
    end
end

end