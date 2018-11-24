% getGlobalVars.m
% Sets global variables for # of layers, # of points, and indication of
% whether this is the first time running the simulation.
% Outputs: init (1 if first time running sim, 0 otherwise), l (# layers), p
% (# points).

function [init,l,p] = getGlobalVars()

global initialRun;
global nLayers;
global nPoints;

init = initialRun;
l = nLayers;
p = nPoints;
