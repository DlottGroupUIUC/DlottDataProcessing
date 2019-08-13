a = linspace(0,1,50);
for i = 1:length(a)
    DisplayStatus(figure(1),1,a(i));
    drawnow;
    pause(.005)
end