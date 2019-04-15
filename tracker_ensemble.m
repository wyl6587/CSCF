function [positions, corner4, time] = tracker_ensemble(ImgFiles, target_sz, pos, vGroundTruth, iGroundTruth, ResultPath, pathModel)
                                            
% ================================================================================
% Environment setting
% ================================================================================
opts = SetParams();
initial_net(pathModel);

phiSet = [];
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
y = gaussian_shaped_labels(output_sigma, l1_patch_num);

% Store pre-computed cosine window(for avoiding boundary discontinuity)存储预计算余弦窗口
%a1=size(yf,1);a=hann(size(yf,1));b=hann(size(yf,2))';c=hann(size(yf,2));
cos_window = hann(size(y,1)) * hann(size(y,2))';

% Create video interface for visualization
if opts.show_visualization
    drawopt=[];
%     update_visualization = show_video1(ImgFiles(:,1),'');
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


% Note: variables ending with 'f' are in the Fourier domain.
model_xf = cell(1,moldalnum);
model_Zf = cell(1,moldalnum);
res      = cell(1,moldalnum);

% ================================================================================
% Start tracking
% ================================================================================
for frame = 1:framenum
    % Load the image at the current frame first col is v, second col is i
    Frame = cell(1,moldalnum);
    for i = 1:moldalnum
        Frame{1,i} = imread(ImgFiles{frame, i});
        if ismatrix(Frame{1,i})
            Frame{1,i} = cat(3, Frame{1,i}, Frame{1,i}, Frame{1,i});
        end
    end
    
    tic()
    % ================================================================================
    % Predicting the object position from the learned object model
    % ================================================================================
    if frame > 1
        % Extracting features
        feat = ExtractFeature(Frame, pos, window_sz, cos_window, opts);
        %Predict position
        [pos, res] = PredictPosition1(feat, pos{1,1}, model_alphaf, opts, l1_patch_num, model_xf, model_Zf);
    end
    
    % ================================================================================
    % Learning correlation filters over features
    % ================================================================================
    % Extracting features
    feat = ExtractFeature(Frame, pos, window_sz, cos_window, opts);
    [model_xf, model_Zf, model_alphaf] = updateModel(feat, y, res, opts, frame, model_xf, model_Zf);
    phiSet = [phiSet;model_alphaf];
    
    % ================================================================================
    % Save predicted position and timing
    % ================================================================================
    
    time = time + toc();
    
    for ii =1:moldalnum
        positions{ii}(frame,:) = pos{ii};
        box{ii} = [pos{ii}([2,1]) - (target_sz([2,1])/2), pos{ii}([2,1]) + (target_sz([2,1])/2)];  %[x1,y1,x2,y2]
        rects{ii}(frame,:) = box{ii};
        corner4{ii}(frame,:) = [box{ii}(1) box{ii}(2) box{ii}(3) box{ii}(2) box{ii}(3) box{ii}(4) box{ii}(1) box{ii}(4)];
        
    end
    
    if opts.show_visualization
        drawopt = show_video(drawopt, frame, Frame, box, target_sz);
        if opts.bSaveImage
            imwrite(frame2im(getframe(gcf)),[ResultPath num2str(frame) '.png']);
        end
       
        
    end
end

close all;

end







