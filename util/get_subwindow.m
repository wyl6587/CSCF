function out = get_subwindow(Frame, pos, window_sz, current_scale_factor)

if isscalar(window_sz)
    window_sz = [window_sz, window_sz];
end
% current_scale_factor = 1;
patch_sz = floor(window_sz * current_scale_factor);

%make sure the size is not to small
if patch_sz(1) < 1
    patch_sz(1) = 2;
end
if patch_sz(2) < 1
    patch_sz(2) = 2;
end

ysv = floor(pos{1,1}(1)) + (1:patch_sz(1)) - floor(patch_sz(1)/2);
xsv = floor(pos{1,1}(2)) + (1:patch_sz(2)) - floor(patch_sz(2)/2);
ysi = floor(pos{1,2}(1)) + (1:patch_sz(1)) - floor(patch_sz(1)/2);
xsi = floor(pos{1,2}(2)) + (1:patch_sz(2)) - floor(patch_sz(2)/2);

% Check for out-of-bounds coordinates, and set them to the values at the borders
xsv = clamp(xsv, 1, size(Frame{1,1},2));
ysv = clamp(ysv, 1, size(Frame{1,1},1));
xsi = clamp(xsi, 1, size(Frame{1,2},2));
ysi = clamp(ysi, 1, size(Frame{1,2},1));

%extract image & resize image to window size
out = cell(1, size(Frame, 2));
out{1,1} = mexResize(Frame{1,1}(ysv, xsv, :), window_sz, 'auto');
out{1,2} = mexResize(Frame{1,2}(ysi, xsi, :), window_sz, 'auto');

% imshow(out{1,1});
% imshow(out{1,2});
end
 
function y = clamp(x, lb, ub)
% Clamp the value using lowerBound and upperBound
y = max(x, lb);
y = min(y, ub);

end