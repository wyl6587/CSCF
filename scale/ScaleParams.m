function [base_target_sz, ysf, scale_window, scaleFactors, scale_model_sz, min_scale_factor, max_scale_factor] = ScaleParams(target_sz, window_sz, img1)
scale_model_max_area = 512;
scale_sigma_factor = 0.25;%0.25;
scale_step = 1.02;%1.02
nScales = 33;%33;
base_target_sz = target_sz;
init_target_sz = target_sz;

% desired scale filter output (gaussian shaped), bandwidth proportional to number of scales
scale_sigma = nScales/sqrt(nScales) * scale_sigma_factor;
ss = (1:nScales) - ceil(nScales/2);
ys = exp(-0.5 * (ss.^2) / scale_sigma^2);
ysf = single(fft(ys));

% store pre-computed scale filter cosine window
if mod(nScales,2) == 0
    scale_window = single(hann(nScales+1));
    scale_window = scale_window(2:end);
else
    scale_window = single(hann(nScales));
end;

% scale factors
ss = 1:nScales;
scaleFactors = scale_step.^(ceil(nScales/2) - ss);

% compute the resize dimensions used for feature extraction in the scale estimation
scale_model_factor = 1;
if prod(init_target_sz) > scale_model_max_area
    scale_model_factor = sqrt(scale_model_max_area/prod(init_target_sz));
end
scale_model_sz = floor(init_target_sz * scale_model_factor);

min_scale_factor = scale_step ^ ceil(log(max(5 ./ window_sz)) / log(scale_step));
max_scale_factor = scale_step ^ floor(log(min([size(img1,1) size(img1,2)] ./ base_target_sz)) / log(scale_step));




end