function [positions, corner4, time] = tracker_ensemble(ImgFiles, target_sz, pos, ResultPath)
                                            
% ================================================================================
% Environment setting
% ================================================================================
opts = SetParams();

% Get image size and search window size
im_szv = size(imread(ImgFiles{1,1}));%im_szi = size(Framei);
window_sz = get_search_window(target_sz, im_szv, opts.padding);%获取搜索窗口

% Compute the sigma for the Gaussian function label
output_sigma = sqrt(prod(target_sz)) * opts.output_sigma_factor / opts.cell_size;%高斯标签的空间带宽

% Create regression labels, gaussian shaped, with a bandwidth 创建回归标签，高斯形，带宽与目标尺寸成比例
% proportional to target size     
l1_patch_num = floor(window_sz / opts.cell_size); 
% Pre-compute the Fourier Transform of the Gaussian function label  yf高斯标签
yf = fft2(gaussian_shaped_labels(output_sigma, l1_patch_num));

% Store pre-computed cosine window(for avoiding boundary discontinuity)存储预计算余弦窗口
cos_window = hann(size(yf,1)) * hann(size(yf,2))';

% Create video interface for visualization
if opts.show_visualization
    drawopt=[];
end

[framenum,moldalnum]=size(ImgFiles);%row帧数，col模态数

% Initialize variables for calculating FPS and distance precision
time =0;
rects = cell(1,moldalnum);
positions = cell(1,moldalnum);
corner4 = cell(1,moldalnum);
for ii = 1:moldalnum
    rects{ii}     = zeros(framenum,4);%保存左上角右下角坐标
    positions{ii} = zeros(framenum,2);%保存中心位置
    corner4{ii}   = zeros(framenum,8);%保存四角坐标
end

img1 = imread(ImgFiles{1, 1});
[base_target_sz, ysf, scale_window, scaleFactors, scale_model_sz, min_scale_factor, max_scale_factor] = ScaleParams(target_sz, window_sz, img1);

current_scale_factor = 1;
% Note: variables ending with 'f' are in the Fourier domain.
model_Zf      = cell(1,moldalnum);
model_xf      = cell(1,moldalnum);
Init_model_Zf = cell(1,moldalnum);
Init_model_xf = cell(1,moldalnum);
res           = cell(1,moldalnum);
% ================================================================================
% Start tracking
% ================================================================================
for frame = 1:framenum
    % Load the image at the current frame first col is v, second col is i
    Frame = cell(1,moldalnum);
    FrameShow = cell(1,moldalnum);
    for i = 1:moldalnum
        Frame{1,i} = imread(ImgFiles{frame, i});
        FrameShow{1,i} = Frame{1,i};
        if ismatrix(Frame{1,i})
            FrameShow{1,i} = cat(3, Frame{1,i}, Frame{1,i}, Frame{1,i});
        end
        if size(Frame{1,i},3)>1
            Frame{1,i} = rgb2gray(Frame{1,i});
        end
    end
    
    tic()
    % ================================================================================
    % Predicting the object position from the learned object model
    % ================================================================================
    if frame > 1
        %Extracting features
        feat = ExtractFeature(Frame, pos, window_sz, current_scale_factor, cos_window, opts);
        %Predict position
        [pos] = PredictPosition1(feat, (pos{1,1} + pos{1,2})/2, opts, model_Zf, Init_model_Zf);
        
        %Scale estimation -DSST
        % extract the test sample feature map for the scale filter
        xs = get_scale_sample(Frame{1,1}, pos{1,1}, base_target_sz, current_scale_factor * scaleFactors, scale_window, scale_model_sz);
        
        % calculate the correlation response of the scale filter
        xsf = fft(xs,[],2);
        scale_response = real(ifft(sum(sf_num .* xsf,1) ./ (sf_den + opts.lambda)));
        
        % find the maximum scale response
        recovered_scale = find(scale_response == max(scale_response(:)), 1);
        
        % update the scale
        current_scale_factor = current_scale_factor * scaleFactors(recovered_scale);
        if current_scale_factor < min_scale_factor
            current_scale_factor = min_scale_factor;
        elseif current_scale_factor > max_scale_factor
            current_scale_factor = max_scale_factor;
        end
        
    end
    
    % ================================================================================
    % Learning correlation filters over features
    % ================================================================================
    % Extracting features
    feat = ExtractFeature(Frame, pos, window_sz, current_scale_factor, cos_window, opts);
    %Model update
    [model_xf, model_Zf] = updateModel(feat, yf, opts, frame, model_xf, model_Zf);
    if frame == 1 %保存初始滤波器
        for ii = 1:moldalnum
            Init_model_Zf{ii} = model_Zf{ii};
            Init_model_xf{ii} = model_xf{ii};
        end
    end
    
    % extract the training sample feature map for the scale filter
    xs = get_scale_sample(Frame{1,1}, pos{1,1}, base_target_sz, current_scale_factor * scaleFactors, scale_window, scale_model_sz);
    
    % calculate the scale filter update
    xsf = fft(xs,[],2);
    new_sf_num = bsxfun(@times, ysf, conj(xsf));
    new_sf_den = sum(xsf .* conj(xsf),1);
    
    if frame == 1
        sf_den = new_sf_den;
        sf_num = new_sf_num;
    else
        sf_den = (1 - opts.scale_interp_factor) * sf_den + opts.scale_interp_factor * new_sf_den;
        sf_num = (1 - opts.scale_interp_factor) * sf_num + opts.scale_interp_factor * new_sf_num;
    end
    % calculate the new target size
    target_sz = floor(base_target_sz * current_scale_factor);
    
    time = time + toc();
    
    % ================================================================================
    % Save predicted position and timing
    % ================================================================================
    
    for ii =1:moldalnum
        positions{ii}(frame,:) = pos{ii};
        box{ii} = [pos{ii}([2,1]) - (target_sz([2,1])/2), pos{ii}([2,1]) + (target_sz([2,1])/2)];  %[x1,y1,x2,y2]
        rects{ii}(frame,:) = box{ii};
        corner4{ii}(frame,:) = [box{ii}(1) box{ii}(2) box{ii}(3) box{ii}(2) box{ii}(3) box{ii}(4) box{ii}(1) box{ii}(4)];
    end
    
    if opts.show_visualization
        drawopt = show_video(drawopt, frame, FrameShow, box, target_sz);
        if opts.bSaveImage
            imwrite(frame2im(getframe(gcf)),[ResultPath num2str(frame) '.png']);
        end   
    end
end
close all;
end