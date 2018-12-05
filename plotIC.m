function plotIC(plotLayers,startLayers,materialLayers,varargin)

if ~isempty(varargin)
    figNum = varargin{1};
    if length(varargin) >= 2
        handles = varargin{2};
        ax = handles.ICplot;
        chipW = varargin{3};
        chipH = varargin{4};
        nPoints = size(plotLayers,2);
        nLayers = size(plotLayers,1);
    end
else
    figNum = 5;
end

nUniqueLayers = length(materialLayers);

if length(varargin) < 2
    figure(figNum);
    imagesc(plotLayers)
    map = colorcet('L18');
    colormap(map);

    for i = 1:nUniqueLayers
        text(1,startLayers(i),materialLayers{i},'fontsize',15);
    end
    
    xlabel('nPoints'); ylabel('nLayers');
    set(gca,'fontsize',12);

else
    xPoints = linspace(0,chipW*1e6,nPoints);
    yPoints = linspace(0,chipH*1e9,nLayers);
    imagesc(ax,xPoints,yPoints,plotLayers);
    map = colorcet('L18');
    colormap(map);
    caxis(ax,[1 6])

    for i = 1:nUniqueLayers
        if materialLayers{i} == 'Graphene'
            text(ax,0,startLayers(i)*chipH*1e9/nLayers-1,materialLayers{i},'fontsize',12);
        else
            text(ax,0,startLayers(i)*chipH*1e9/nLayers,materialLayers{i},'fontsize',12);
        end
    end

    xlabel(ax,'chip width (um)'); ylabel(ax,'chip height (nm)');
    set(ax,'FontSize',12);


end


end