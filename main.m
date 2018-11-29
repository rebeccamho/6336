function main
clear all; close all force; clc;

% initialize variables
s = convertCharsToStrings('Silicon');
c = convertCharsToStrings('Copper');
o = convertCharsToStrings('Oxide');
g = convertCharsToStrings('Graphene');
v = convertCharsToStrings('Via');

% EDIT HERE
Tstart = 298;  % room temp
nLayers = 20;
nPoints = 20;
reduce = 0;
layers = [v];  % set layers top to bottom
% END EDIT

setGlobalVars(1,nLayers,nPoints,Tstart,reduce);
setIClayers(0,[]);
setTempScale(0,298,298);

nUniqueLayers = length(layers);
materialLayers = [];
for i = 1:nUniqueLayers
    materialLayers = [materialLayers {layers(i)}];
end

setIClayers(nUniqueLayers,materialLayers)


% open GUI to run simulation
build_IC_gui;