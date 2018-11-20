function run_w_gui_code(handles,x_start,u,p,otherParams,t_stop,timestep)
nLayers = otherParams.nLayers;
nPoints = otherParams.nPoints; 
materialLayers = otherParams.materialLayers;
startLayers = otherParams.startLayers;

% construct A matrix (A_mat) and B*u (U_vec)
[dx_dt,A,B] = F(x_start,u,p,otherParams); 

%% Run trapezoidal script. 
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
fhand = @(x,t)fj2DIC(x,t,A,B*u');
freq = 2;
x_trap = trapezoidalNonlinear(x_start,t_start,t_stop,timestep,fhand,freq,pVisualize,handles);
x_trapFinal = x_trap(:,end);
