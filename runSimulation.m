% runSimulation.m
% Runs temperature simulation of 2D IC over time.
% Inputs: handles (used for GUI), u (vector of source values), p (matrix of
% material properties btwn nodes), otherParams (struct of IC parameters),
% t_stop (time at which simulation should end), timestep, reduce (1 if
% using model order reduction, 0 otherwise).

function runSimulation(handles,u,p,otherParams,t_stop,timestep,reduce)

% Model order reduction parameters
nLayersRed = 40;
nPointsRed = 40;
k = 40*40; % # of eigenvalues to calculate
order = nLayersRed*nPointsRed;
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
[~,A,B,C,P] = F(x_start,u,p,reduce,otherParams); 

% plot steady state temperature profile
SS = -P*A\(P*B*u');
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

maxTempVal = max(max(SS));
minTempVal = min(min(SS));
maxTemp = num2str(maxTempVal);
set(handles.maxTempValue,'String',maxTemp);
drawnow;

% % plot steady state temperature profile
% SS = -A\(B*u');
% ax = handles.ssPlot;
% SS = reshape(SS,nPoints,nLayers)';
% imagesc(ax,SS);
% map = colorcet('D1');
% colormap(ax,map);
% xlabel(ax,'node');
% ylabel(ax,'material layer');
% title(ax,'Steady State');
% set(ax,'ytick',startLayers,'yticklabel',materialLayers,'fontsize',12)
% colorbar(ax);

%% Run trapezoidal script. 
pVisualize = struct; 
pVisualize.params = p; 
pVisualize.time = t_stop; 
pVisualize.figNum = 10;
pVisualize.materialLayers = materialLayers;
pVisualize.startLayers = startLayers;
pVisualize.maxTemp = maxTempVal;
pVisualize.minTemp = minTempVal;

% sysOriginal = ss(full(A),B*u',C',0);


if reduce  % reduce order of model if reduce = 1
     [A,B,C] = reduceOrder(A,B*u',C,order,k);
%      sysRed = ss(A,B,C',0);

%     W = traprule_LTI(x_start, timestep, t_start, t_stop, A, B, u);
%     [A,B,C] = pod(A, B, C, q, W);
    pVisualize.nPoints = nPointsRed;
    pVisualize.nLayers = nLayersRed;
else
    pVisualize.nPoints = nPoints;
    pVisualize.nLayers = nLayers;
end

% close all force
% figure(1); hold on;
% bode(sysOriginal);
% bode(sysRed);
% legend('original (order: 1600)','reduced (order: 400)');
% figure(2); hold on;
% step(sysOriginal,3);
% step(sysRed,3);
% legend('original (order: 1600)','reduced (order: 400)');


% X = ForwardEuler('F',x_start,eval_u,p,t_start,t_stop,timestep,1,200);

if reduce
%     fhand = @(x,t)fj2DIC(x,t,A,B);
    fhand = @(x,t)fj2DIC(x,t,P*A,P*B);
else
%     fhand = @(x,t)fj2DIC(x,t,A,(B*u'));
    fhand = @(x,t)fj2DIC(x,t,P*A,P*(B*u'));
end
% [x_trap,tf,Tchange] = trapezoidalNonlinear(C,x_start,t_start,t_stop,timestep,fhand,freq,pVisualize,handles);
[x_trap,tf,Tchange,dt_vec] = trapezoidalNonlinear_dynamic(C,P,x_start,t_start,t_stop,timestep,fhand,freq,pVisualize,handles);
% x_trap = C'*x_trap;
x_trapFinal = C.*x_trap(:,end);
setInitialParams(x_trapFinal,tf);

% maxTemp = num2str(max(x_trapFinal));
% set(handles.maxTempValue,'String',maxTemp);
% drawnow;

% figure(10); plot(Tchange(2:end))
% figure(11); plot(dt_vec(2:end))
