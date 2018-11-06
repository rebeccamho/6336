function visualizeNetwork(x,p)

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
colorbar;

end