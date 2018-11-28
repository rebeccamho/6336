function main
clear all; close all force; clc;
Tstart = 298; % room temp

nLayers = 40;
nPoints = 40;
reduce = 0;

% initialize global variables
setGlobalVars(1,nLayers,nPoints,Tstart,reduce);
setIClayers(0,[]);
setTempScale(0,298,298);

nUniqueLayers = 3;
% materialLayers = [{'Copper'} {'Graphene'} {'Silicon'}]; % list materials from top to bottom
% materialLayers = [{'Copper'} {'Silicon'}]; % list materials from top to bottom
materialLayers = [ {'Copper'}  {'Graphene'}  {'Silicon'}]; % list materials from top to bottom

setIClayers(nUniqueLayers,materialLayers)


% open GUI to run simulation
build_IC_gui;