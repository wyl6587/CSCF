function p = draw_boundingbox(varargin)

param =[];

if (length(varargin{1}) == 2)
    xv1 = varargin{1}{1}(1);
    yv1 = varargin{1}{1}(2);
    xv2 = varargin{1}{1}(3);
    yv2 = varargin{1}{1}(4);
    xi1 = varargin{1}{2}(1);
    yi1 = varargin{1}{2}(2);
    xi2 = varargin{1}{2}(3);
    yi2 = varargin{1}{2}(4);    
    varargin(1) = [];
end

if (length(varargin{1}) == 2)
    h = varargin{1}(1);
    w = varargin{1}(2);
    varargin(1) = [];
end
% corners = [x1, x2, x2, x1, x1; h-y2, h-y2, h-y1, h-y1, h-y2];
cornersv = [xv1, xv2, xv2, xv1, xv1; yv2, yv2, yv1, yv1, yv2];

line(cornersv(1,:), cornersv(2,:), varargin{:});


% cornersi = [xv1+w, xv2+w, xv2+w, xv1+w, xv1+w; yv2, yv2, yv1, yv1, yv2];
cornersi = [xi1+w, xi2+w, xi2+w, xi1+w, xi1+w; yi2, yi2, yi1, yi1, yi2];

line(cornersi(1,:), cornersi(2,:), varargin{:});

hold_was_on = ishold;
hold on;

if (~hold_was_on)
    hold off;
end
    

p=1;

