% setIClayers.m
% Sets global variables for # unique material layers and the contents of
% each layer (from top to bottom)
% Inputs: n (# unique layers), mat (cell array of materials)
function setIClayers(n,mat)

global nMaterialLayers;
global materialLayers;
nMaterialLayers = n;
materialLayers = mat;