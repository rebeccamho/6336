% getGlobalVars.m
% Returns global variables for # of layers, # of points, indication of
% whether this is the first time running the simulation, and initial
% temperature.
% Outputs: init (1 if first time running sim, 0 otherwise), l (# layers), p
% (# points), T (initial temperature).

function [init,l,p,T,r,n] = getGlobalVars()

global initialRun;
global nLayers;
global nPoints;
global Tstart;
global reduce;
global nPointsVia;

init = initialRun;
l = nLayers;
p = nPoints;
T = Tstart;
r = reduce;
n = nPointsVia;