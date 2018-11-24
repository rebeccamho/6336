% getGlobalVars.m
% Sets global variables for # of layers, # of points, indication of
% whether this is the first time running the simulation, and initial
% temperature.
% Inputs: x (1 if first time running sim, 0 otherwise), y (# layers), z
% (# points), t (initial temperature).

function setGlobalVars(x,y,z,t)

global initialRun;
global nLayers;
global nPoints;
global Tstart;

initialRun = x;
nLayers = y;
nPoints = z;
Tstart = t;