function DisplayStatus(Figure,TextBox,Status)
axes(Figure);
cla;
if Status > 1
    error('Status must be between 0 and 1');
end

xlim([0,1]);ylim([0,1]);
rectangle('Position',[0,0,Status,1],'FaceColor','b','EdgeColor','none',...
    'LineWidth',3); hold off;
set(gca,'XTick',[], 'YTick', []);
set(gca,'YTickLabel',[]); set(gca,'XTickLabel',[]);
StatusP = Status*100;
Text = sprintf('Progress %0.1f%%',StatusP);
set(TextBox,'String',Text);