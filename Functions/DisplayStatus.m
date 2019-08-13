function DisplayStatus(Figure,TextBox,Status)
axes(Figure);
cla; xlim([0,1]);ylim([0,1]);
set(gca,'XTick',[], 'YTick', []);
set(gca,'YTickLabel',[]); set(gca,'XTickLabel',[]);
Text = '';
if Status > 1
    error('Status must be between 0 and 1');
elseif Status == 1
    rectangle('Position',[0,0,Status,1],'FaceColor','b','EdgeColor','none',...
    'LineWidth',3); hold off; 
    Text = 'Done!'; set(TextBox,'String',Text);
    pause(0.5);
    rectangle('Position',[0,0,0,1],'FaceColor','b','EdgeColor','none',...
    'LineWidth',3); hold off; 
    Text = '';
    
else

    rectangle('Position',[0,0,Status,1],'FaceColor','b','EdgeColor','none',...
    'LineWidth',3); hold off;

    StatusP = Status*100;
    Text = sprintf('Progress %0.1f%%',StatusP);
end
    set(TextBox,'String',Text); drawnow;