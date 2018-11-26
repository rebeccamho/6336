% setIClayers.m
% Returns global variables for # unique material layers and the contents of
% each layer (from top to bottom)
% Outputs: n (# unique layers), mat (cell array of materials)

function [n mat] = getIClayers()

global nMaterialLayers;
global materialLayers;
n = nMaterialLayers;
mat = materialLayers;