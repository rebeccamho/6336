function visualizeNetwork(x,p,varargin)

% if ~isempty(varargin)
%     h = varargin{1};
%     ax = h.tempPlot;
%     X = reshape(x(:,end),p.nPoints,p.nLayers)';
%     imagesc(ax,X);
%     map = colorcet('D1');
%     colormap(ax,map);
%     xlabel(ax,'node');
%     ylabel(ax,'material layer');
%     title(ax,['t = ' num2str(p.time) ' s']);
%     set(ax,'ytick',p.startLayers,'yticklabel',p.materialLayers,'fontsize',12)
%     colorbar(ax);
%     caxis(ax,[p.minTemp p.maxTemp]);
%     
%     if h.transistorBox.Value == 1
%         caxis(ax,[p.minTemp p.maxTemp]);
%     end
%     
%     [f,tLow,tHigh] = getTempScale();
%     if f == 1
%         caxis(ax,[tLow tHigh]);
%     end 
%     
%     drawnow;
%     
% %     maxTemp = num2str(max(max(X)));
% %     set(h.maxTempValue,'String',maxTemp);
% %     drawnow;
%     
% else   
%     figure(p.figNum);
%         
%     % 3D surf plot
%     % X = vec2mat(x(:,end),p.nPoints);
%     % s = surf(X);
%     % s.EdgeColor = 'none';
%     
%     % 2D plot
%     X = reshape(x(:,end),p.nPoints,p.nLayers)';
%     imagesc(X);
%     
%     map = colorcet('D1');
%     colormap(map);
%     xlabel('node');
%     ylabel('material layer');
%     title(['t = ' num2str(p.time) ' s']);
%     set(gca,'ytick',p.startLayers,'yticklabel',p.materialLayers,'fontsize',12)
%     colorbar;
%     drawnow;
%     movegui(gcf,'northeast');
% 
% end

end