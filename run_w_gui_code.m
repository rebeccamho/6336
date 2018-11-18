function run_w_gui_code(handles,x_start,u,p,otherParams,t_stop,timestep)
nLayers = otherParams.nLayers;
nPoints = otherParams.nPoints; 
materialLayers = otherParams.materialLayers;
startLayers = otherParams.startLayers;

[dx_dt,A_mat,U_vec] = F(x_start,u,p,otherParams);

x_steady=-U_vec\A_mat;
X_steady = vec2mat(x_steady,nPoints);
% figure(100)
% imagesc(X_steady);
% colorbar;
%% Run Euler script. 
x_start = zeros(nLayers*nPoints,1);
x_start(:) = 298; %Room temperature Start
t_start = 0;
% t_stop = 0.5;
% timestep = 0.1; 



eval_u = u;
% X = ForwardEuler('F',x_start,eval_u,p,t_start,t_stop,timestep,1,200);

pVisualize = struct; 
pVisualize.params = p; 
pVisualize.time = t_stop; 
pVisualize.nPoints = nPoints;
pVisualize.nLayers = nLayers;
pVisualize.figNum = 10;
pVisualize.materialLayers = materialLayers;
pVisualize.startLayers = startLayers;


t = t_start:timestep:t_stop;
fhand = @(x,t)fj2DIC(x,t,A_mat,U_vec);
freq = 2;
x_trap = trapezoidalNonlinear(x_start,t_start,t_stop,timestep,fhand,freq,pVisualize,handles);
x_trapFinal = x_trap(:,end);
