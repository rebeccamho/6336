% getTempScale.m
% Returns global variables for flag indicating whether temperature scale has
% been set, scale low and high temperatures
% Outputs: f (set scale flag), tLow (low temperature), tHigh (high
% temperature)
function [f,tLow,tHigh] = getTempScale()
global tempScaleFlag;
global tempLow;
global tempHigh;

f = tempScaleFlag;
tLow = tempLow;
tHigh = tempHigh; 
