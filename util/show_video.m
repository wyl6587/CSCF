function [drawopt ,p] = show_video(drawopt, fnum, Frame, box, target_sz)

[h1,w1,c1] = size(Frame{1,1});
[h2,w2,~]  = size(Frame{1,2});
frame = [Frame{1,1}, zeros(h1, w1, c1)];
% imshow(frame);
frame(1:h2, w1+1:w1+w2,:) = Frame{1,2};

% imshow(frame);

if (isempty(drawopt))
    figure('position', [50 50 size(frame, 2) size(frame,1)]);
    clf;
    set(gcf, 'DoubleBuffer','on','MenuBar','none');
    colormap('gray');
    
    drawopt.curaxis = [];
    drawopt.curaxis.frm = axes('position', [0.00 0 1.00 1.0]);
end

curaxis = drawopt.curaxis;
axes(curaxis.frm);
imagesc(frame, [0,1]);
hold on;

%draw the bounding box

p = draw_boundingbox(box, [h1,w1], 'Color','r', 'LineWidth',0.5);



text(0, 10, '#', 'Color','g', 'FontWeight','bold', 'FontSize',20);
text(15, 10, num2str(fnum), 'Color','g', 'FontWeight','bold', 'FontSize',20);

axis equal tight off;
hold off;
drawnow;        %%  update



