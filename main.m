function main
clear all; close all force; clc;
Tstart = 298; % room temp

% initialize global variables
setGlobalVars(1,0,0,Tstart);
setIClayers(0,[]);
setTempScale(0,298,298);

% open GUI to run simulation
build_IC_gui;