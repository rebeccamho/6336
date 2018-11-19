function visualizeNetwork(x,p,varargin)

<<<<<<< HEAD
figure(p.figNum);

% 3D surf plot
% X = vec2mat(x(:,end),p.nPoints);
% s = surf(X);
% s.EdgeColor = 'none';

% 2D plot
X = reshape(x(:,end),p.nPoints,p.nLayers)';
s = imagesc(X);

map = colorcet('D1');
colormap(map);
xlabel('node','fontsize',15);
ylabel('material layer','fontsize',15);
title(['t = ' num2str(p.time) ' s'],'fontsize',20);
set(gca,'ytick',p.startLayers,'yticklabels',p.materialLayers);
colorbar;
drawnow;
=======
if ~isempty(varargin)
    ax = varargin{1}.tempPlot;
    X = reshape(x(:,end),p.nPoints,p.nLayers)';
    imagesc(ax,X);
    
    map = colorcet('D1');
    colormap(ax,map);
    xlabel(ax,'node');
    ylabel(ax,'material layer');
    title(ax,['t = ' num2str(p.time) ' s']);
    set(ax,'ytick',p.startLayers,'yticklabel',p.materialLayers,'fontsize',18)
    colorbar;
    drawnow;
    
else   
    figure(p.figNum);
        
    % 3D surf plot
    % X = vec2mat(x(:,end),p.nPoints);
    % s = surf(X);
    % s.EdgeColor = 'none';
    
    % 2D plot
    X = reshape(x(:,end),p.nPoints,p.nLayers)';
    imagesc(X);
    
    map = colorcet('D1');
    colormap(map);
    xlabel('node');
    ylabel('material layer');
    title(['t = ' num2str(p.time) ' s']);
    set(gca,'ytick',p.startLayers,'yticklabel',p.materialLayers,'fontsize',18)
    colorbar;
    drawnow;
end
>>>>>>> irene

end