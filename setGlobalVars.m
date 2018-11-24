% getGlobalVars.m
% Sets global variables for # of layers, # of points, and indication of
% whether this is the first time running the simulation.
% Inputs: x (1 if first time running sim, 0 otherwise), y (# layers), z
% (# points).

function setGlobalVars(x,y,z)

global initialRun;
global nLayers;
global nPoints;
initialRun = x;
nLayers = y;
nPoints = z;