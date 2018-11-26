% setTempScale.m
% Sets global variables for flag indicating whether temperature scale has
% been set, scale low and high temperatures
% Inputs: f (set scale flag), tLow (low temperature), tHigh (high
% temperature)
function setTempScale(f,tLow,tHigh)
global tempScaleFlag;
global tempLow;
global tempHigh;

tempScaleFlag = f;
tempLow = tLow;
tempHigh = tHigh;