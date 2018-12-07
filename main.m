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
nLayers = 100;
nPoints = 22;
nPointsVia = 2;
reduce = 0;
layers = [c s g];  % set layers top to bottom, keep g on bottom
% END EDIT

% assert nPointsVia and nPoints #s are compatible
assert(mod(nPoints,nPointsVia) == 0, '# points is not a multiple of number of points in a via!');
assert(mod(nPoints/nPointsVia,2) ~= 0, 'need an odd # of vias! increase # points by # points in a via');
% assert IC structure is compatible with heat source location
if ~isempty(find(layers == g))
    assert(max(find(layers == g)) ~= 1,'cannot have the only graphene layer be on the top of IC, add graphene layer below or remove top graphene layer');
end

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