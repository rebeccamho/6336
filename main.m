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
nLayers = 42;
nPoints = 42;
nPointsVia = 2;
reduce = 0;
layers = [v g];  % set layers top to bottom
% END EDIT

% assert nPointsVia and nPoints #s are compatible
assert(mod(nPoints,nPointsVia) == 0, '# points is not a multiple of number of points in a via!');
assert(mod(nPoints/nPointsVia,2) ~= 0, 'need an odd # of vias! increase # points by # points in a via');

setGlobalVars(1,nLayers,nPoints,Tstart,reduce,nPointsVia);
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