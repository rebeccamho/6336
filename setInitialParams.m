% setInitialParams.m
% Sets global variables for initial x values and time values.
% Inputs: xi (initial node values), ti (start time).

function setInitialParams(xi,ti)
global xstart;
global tstart;

xstart = xi;
tstart = ti;