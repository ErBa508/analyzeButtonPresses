function void = plotTC(hfig,Times,TCmax,Yvals,colorTC)
% Plot time-course of perceptual alternations of ONE percept (A or B)
% Usage: plotTC(hfig,Times,TCmax,Yvals,colorTC)
%        (the function is void, no return value) 
% hfig: handle to the figure (or subplot) where TC should be drawn 
% Times: an Nx2 matrix; each row is pair {time_on, time_off} of a mouse/key event (percept start & end)
% TCmax: xmax value  (for axis([xmin xmax ymin ymax]) call)
% Yvals: a 1x4 vector with Yon,Yoff and ymin,ymax values 
% colorTC: a 1x3 vector w/rgb values of the plot line color

ymin=Yvals(3);
ymax=Yvals(4);
tiny=TCmax/1000; % tiny dx to draw "vertical" lines in TC

axis([0 TCmax ymin ymax])
hold on
for i=1:size(Times,1)
    plot(hfig,Times(i,:),[Yvals(1) Yvals(2)],'Color',colorTC);
    plot(hfig,[(Times(i,1)-tiny) Times(i,1)],[ymin Yvals(1)],'Color',colorTC,'LineStyle',':');
    plot(hfig,[(Times(i,2)-tiny) Times(i,2)],[ymin Yvals(2)],'Color',colorTC,'LineStyle',':');
end
    
    





