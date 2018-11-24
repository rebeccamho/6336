function x_start = initializeNodes(nLayers,nPoints,Tstart,reduce)

if reduce
    x_start = zeros(order,1); % with model order reduction
else
    x_start = zeros(nLayers*nPoints,1); % no model order reduction
end
x_start(:) = Tstart; %Room temperature to start