%GAUSSIAN_SHAPED_LABELS
%   Gaussian-shaped labels for all shifts of a sample.
%
%   LABELS = GAUSSIAN_SHAPED_LABELS(SIGMA, SZ)
%   Creates an array of labels (regression targets) for all shifts of a
%   sample of dimensions SZ. The output will have size SZ, representing
%   one label for each possible shift. The labels will be Gaussian-shaped,
%   with the peak at 0-shift (top-left element of the array), decaying
%   as the distance increases, and wrapping around at the borders.
%   The Gaussian function has spatial bandwidth SIGMA.
%
%   Joao F. Henriques, 2014
%   http://www.isr.uc.pt/~henriques/


% 	%as a simple example, the limit sigma = 0 would be a Dirac delta,
% 	%instead of a Gaussian:
% 	labels = zeros(sz(1:2));  %labels for all shifted samples
% 	labels(1,1) = magnitude;  %label for 0-shift (original sample)
	
function labels = gaussian_shaped_labels(sigma, sz)

	%evaluate a Gaussian with the peak at the center element用中心元素的峰值评估高斯
 %   a = (1:sz(1)) - floor(sz(1)/2);b=(1:sz(2)) - floor(sz(2)/2);
    
	[rs, cs] = ndgrid((1:sz(1)) - floor(sz(1)/2), (1:sz(2)) - floor(sz(2)/2));
	labels = exp(-0.5 / sigma^2 * (rs.^2 + cs.^2));

	%move the peak to the top-left, with wrap-around将顶点移动到左上角，进行环绕
	labels = circshift(labels, -floor(sz(1:2) / 2) + 1);%circshift循环移位函数

	%sanity check: make sure it's really at top-left理智检查：确保它真的在左上角
	assert(labels(1,1) == 1)%assert函数用来判断一个expression（labels(1,1) == 1）是否成立，如不成立则报错

end

