function main

Tstart = 298; % room temp

% initialize global variables
setGlobalVars(1,0,0,Tstart);
setIClayers(0,[]);

% open GUI to run simulation
build_IC_gui;