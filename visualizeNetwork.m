function visualizeNetwork(x,p)

figure(p.figNum);
X = vec2mat(x(:,end),p.nPoints);
s = surf(X);
s.EdgeColor = 'none';
map = colorcet('D1');
colormap(map);
xlabel('node','fontsize',15);
ylabel('material layer','fontsize',15);
title(['t = ' num2str(p.time) ' s'],'fontsize',20);
colorbar;
end