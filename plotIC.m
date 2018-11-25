function plotIC(plotLayers,startLayers,materialLayers,varargin)

if ~isempty(varargin)
    figNum = varargin{1};
    if length(varargin) == 2
        handles = varargin{2};
        ax = handles.ICplot;
    end
else
    figNum = 5;
end

nUniqueLayers = length(materialLayers);

if length(varargin) ~= 2
    figure(figNum);
    imagesc(plotLayers)
    map = colorcet('I3');
    colormap(map);

    for i = 1:nUniqueLayers
        text(1,startLayers(i)+1,materialLayers{i},'fontsize',15);
    end
    
    xlabel('nPoints'); ylabel('nLayers');
    set(gca,'fontsize',12);

else
    imagesc(ax,plotLayers);
    map = colorcet('I3');
    colormap(map);
    caxis([1 3])

    for i = 1:nUniqueLayers
        text(ax,1,startLayers(i)+1,materialLayers{i},'fontsize',12);
    end

    xlabel(ax,'Points'); ylabel(ax,'Layers');
    set(ax,'FontSize',12);


end


end