function Opts = SetParams()
Opts = [];

Opts.features.hog  = 0;
Opts.features.gray = 1;

Opts.cell_size = 1; %hog 4  gray 1

Opts.layers = 5;%卷积层


Opts.lambda = 0.11;%0.11;%regularization

Opts.gama = 0.14;%0.14;

Opts.miu = 0.1;%1e-1;

Opts.stepsize = 1.2;%1.2;

%learning rate
Opts.interp_factor = 0.025;%0.025;
Opts.scale_interp_factor = 0.011;%0.015;

Opts.beta1 = 0.2;%0.2;
Opts.beta2 = 0.6;%0.6;

% number of iterations between updating the sparse codes and weights
Opts.iteration = 10;

% threshold on stoping optimization
Opts.ABSTOL = 1e-3;

Opts.show_visualization = 0;%可视化

%spatial bandwidth (proportional to target) the spatial bandwidth of the regression target, relative to the target size.
Opts.output_sigma_factor = 0.1;  %hog 0.1  gray 0.2

Opts.padding = struct('generic', 1.9, 'large', 1.0, 'height', 0.4);% extra area surrounding the target

Opts.hog_orientations = 9; %

%保存结果
Opts.bSaveImage = 1;
