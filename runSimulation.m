% runSimulation.m
% Runs temperature simulation of 2D IC over time.
% Inputs: handles (used for GUI), u (vector of source values), p (matrix of
% material properties btwn nodes), otherParams (struct of IC parameters),
% t_stop (time at which simulation should end), timestep, reduce (1 if
% using model order reduction, 0 otherwise).

function runSimulation(handles,u,p,otherParams,t_stop,timestep,reduce)

% Model order reduction parameters
k = 70; % # of eigenvalues to calculate
order = 40;
% Plotting parameters
freq = 2;
% Get initial parameters
[x_start,t_start] = getInitialParams;
t_stop = t_stop+t_start;

nLayers = otherParams.nLayers;
nPoints = otherParams.nPoints; 
materialLayers = otherParams.materialLayers;
startLayers = otherParams.startLayers;

% construct A, B, and C matrices
[dx_dt,A,B,C] = F(x_start,u,p,otherParams); 

% plot steady state temperature profile
SS = -A\(B*u');
ax = handles.ssPlot;
SS = reshape(SS,nPoints,nLayers)';
imagesc(ax,SS);
map = colorcet('D1');
colormap(ax,map);
xlabel(ax,'node');
ylabel(ax,'material layer');
title(ax,'Steady State');
set(ax,'ytick',startLayers,'yticklabel',materialLayers,'fontsize',12)
colorbar(ax);

%% Run trapezoidal script. 
pVisualize = struct; 
pVisualize.params = p; 
pVisualize.time = t_stop; 
pVisualize.figNum = 10;
pVisualize.materialLayers = materialLayers;
pVisualize.startLayers = startLayers;

if reduce  % reduce order of model if reduce = 1
    [A,B,C] = reduceOrder(A,B,C,order,k);
    pVisualize.nPoints = 4;
    pVisualize.nLayers = 10;
else
    pVisualize.nPoints = nPoints;
    pVisualize.nLayers = nLayers;
end
 
% X = ForwardEuler('F',x_start,eval_u,p,t_start,t_stop,timestep,1,200);

fhand = @(x,t)fj2DIC(x,t,A,B*u');
% x_trap = trapezoidalNonlinear(C,x_start,t_start,t_stop,timestep,fhand,freq,pVisualize,handles);
[x_trap,tf] = trapezoidalNonlinear_dynamic(C,x_start,t_start,t_stop,timestep,fhand,freq,pVisualize,handles);
x_trapFinal = x_trap(:,end);
setInitialParams(x_trapFinal,tf);

% maxTemp = num2str(max(x_trapFinal));
% set(handles.maxTempValue,'String',maxTemp);
% drawnow;