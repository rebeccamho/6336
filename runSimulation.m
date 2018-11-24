function runSimulation(handles,x_start,u,p,otherParams,t_stop,timestep,reduce)

% Model order reduction parameters
k = 70; % # of eigenvalues to calculate
order = 40;
% Plotting parameters
freq = 2;


nLayers = otherParams.nLayers;
nPoints = otherParams.nPoints; 
materialLayers = otherParams.materialLayers;
startLayers = otherParams.startLayers;

% construct A, B, and C matrices
[dx_dt,A,B,C] = F(x_start,u,p,otherParams); 

%% Run trapezoidal script. 
pVisualize = struct; 
pVisualize.params = p; 
pVisualize.time = t_stop; 
pVisualize.figNum = 10;
pVisualize.materialLayers = materialLayers;
pVisualize.startLayers = startLayers;

if reduce  % reduce order of model if reduce = 1
    [A,B,C] = reduceOrder(A,B,C,order,k);
    x_start = zeros(order,1); % with model order reduction
    pVisualize.nPoints = 4;
    pVisualize.nLayers = 10;
else
    x_start = zeros(nLayers*nPoints,1); % no model order reduction
    pVisualize.nPoints = nPoints;
    pVisualize.nLayers = nLayers;
end
x_start(:) = 298; %Room temperature Start
t_start = 0;
 
% X = ForwardEuler('F',x_start,eval_u,p,t_start,t_stop,timestep,1,200);

fhand = @(x,t)fj2DIC(x,t,A,B*u');
% x_trap = trapezoidalNonlinear(C,x_start,t_start,t_stop,timestep,fhand,freq,pVisualize,handles);
x_trap = trapezoidalNonlinear_dynamic(C,x_start,t_start,t_stop,timestep,fhand,freq,pVisualize,handles);
x_trapFinal = x_trap(:,end);
