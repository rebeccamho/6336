function [phi,t,Tchange,dt_vec] = trapezoidalNonlinear_dynamic(C,P,phi_i,t_i,t_f,dt,f,freq,pVisualize,varargin)
% This function implements the trapezoidal method, but with varying dt
% depending how fast the temperatures of the system are changing. 

%% Define max_dt, max_Tchange, min_dt, and min_Tchange. 
%We will scale the dt linearly based on the change we see in T at every
%timestep. 
max_dt = 10e-17; % Max_dt before see instablity (Task B Part 1)
% max_dt = 1; 
max_Tchange = 1.2268e-2; %maximum change in T in time step when dt = 1e-3. 

min_dt = 1e-12; %Used to obtain reference. 
min_Tchange = 1.2268e-4; %maximum change in T in time step when dt = 1e-5

%We will make a y = mx+b where x is the Tchange per time step, and y is hte
%dt that will correspond to that Tchange. In essence, for large Tchanges,
%we want a small small dt, and for small Tchanges, we want a large dt. 

m = (min_Tchange - max_Tchange)/(max_dt-min_dt); 
b = max_Tchange -m*(min_Tchange); 


%For implementation 2
dt_change = max_dt;
%Now the dynamic dt can be caluclated by m*x+b. 
iter = (t_f-t_i)/dt;
t = t_i; 
phi(:,1) = phi_i;

pVisualize.time = t;
if ~isempty(varargin) && freq ~= 0
    visualizeNetwork(phi(:,1),pVisualize,varargin{1});
elseif freq ~= 0
    visualizeNetwork(phi(:,1),pVisualize);
end

count = 1;
i  =1;
while t<t_f
% for i = 2:iter+1
    i = i+1;
%     i
%     iter+1
%     t
    t_prev = t; 
    phi_prev = phi(:,i-1);
    F = f(phi_prev,t_prev);
    gamma = phi_prev + dt/2*F;
    t = t+dt;
    ftrap = @(phi)trapezoidalSolve(f,t,dt,phi,gamma);
    phi(:,i) = newtonNd(ftrap,phi_prev,P);
    
    %Calculate Tchange to determine new dt. 
    if i > 1
        Tchange(i) =max(max(abs(phi(:,i)-phi(:,i-1)))); %Calculate Tchange. 
        if Tchange(i)>Tchange(i-1) 
            dt = dt-dt_change; %if we see bigger increases in T than previous iteration, decrease dt. 
            
        else 
            dt = dt+dt_change; %if we see small increases, then incresae dt. 
        end
%         
%         dt = m*(Tchange(i))+b; %Calculate new dt and store. 
%         if dt<0 %special case when dt is less than zero, if Tchange really big. 
%             dt = min_dt;
%         end
        dt_vec(i) = dt;  %Update dt. 
    end
    
    
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
    if t >t_f
        break
    end
    
end

end