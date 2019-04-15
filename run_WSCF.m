%close all
clear
clc
fprintf(datestr(now));
%warning off all

addpath('util','cf_scale','model','matconvnet1.08/matlab');

global enableGPU;
enableGPU = true;

run('./matconvnet1.08/matlab/vl_setupnn.m')


pathModel = 'C:/Users/Wyl/Desktop/weighted-correlation-filters/WSCF_4/model/imagenet-vgg-verydeep-19.mat';

DataPath = './dataset/';
show_plots=0;

videos = {'BlackCar', 'BlackSwan1', 'BlueCar', 'BusScale', 'BusScale1', ... % 1 -- 5
    'carNig', 'Crossing', 'crowdNig', 'Cycling', 'DarkNig', ... % 6 -- 10
    'Exposure2', 'Exposure4', 'fastCar2', 'FastCarNig', 'FastMotor', ... % 11 -- 15
    'FastMotorNig', 'Football', 'GarageHover', 'Gathering', 'GoTogether', ... % 16 -- 20
    'Jogging', 'LightOcc', 'Minibus', 'Minibus1', 'MinibusNig', ... % 21 -- 25
    'MinibusNigOcc', 'Motorbike', 'Motorbike1', 'MotorNig', 'occBike', ... % 26 -- 30
    'OccCar-1', 'OccCar-2','Otcbvs', 'Otcbvs1', 'Pool', ... % 31 -- 35
    'Quarreling', 'RainyCar1', 'RainyCar2', 'RainyMotor1', 'RainyMotor2',  ... % 36 -- 40
    'RainyPeople', 'Running', 'Torabi', 'Torabi1', 'Tricycle', ... % 41 -- 45
    'tunnel', 'Walking', 'WalkingNig', 'WalkingNig1', 'WalkingOcc'};  % 46 -- 50



for seq = 1:numel(videos)%逐个处理视频序列
    ResultPath = ['result\', videos{seq}, '\'];
    if ~isdir(ResultPath)%创建保存运行图片的文件夹
        mkdir(ResultPath);
    end
    
    [ImgFiles, vGroundTruth, iGroundTruth] = load_video_info(DataPath, videos{seq});
    %可见光
%    V=[];
    init_rectv = vGroundTruth(1,:);%初始帧bounding box
    target_szv = [init_rectv(4) - init_rectv(2), init_rectv(3) - init_rectv(1)];%bounding box大小（高，宽）
    pos{1} = [init_rectv(2), init_rectv(1)] + floor(target_szv/2);%中心点位置[y,v]
    %热红外
 %   I=[];
    init_recti = iGroundTruth(1,:);
    target_szi = [init_recti(4) - init_recti(2), init_recti(3) - init_recti(1)];
    pos{2} = [init_recti(2), init_recti(1)] + floor(target_szi/2);
    
    path = [DataPath, videos{seq}];
    
    [positions, corner4, time] = tracker_ensemble(ImgFiles, target_szv, pos, vGroundTruth,  iGroundTruth, ResultPath, pathModel);
    
    cd('./PlotErr/BBresults');
    txtname = ['oursM4DEEP1_',videos{seq},'.txt'];
    fid = fopen(txtname,'wt');
    [m,n] = size(corner4{1,1});
    for i=1:1:m
        for j=1:1:n
            if j == n
                fprintf(fid,'%g\n',corner4{1,1}(i,j));
            else
                fprintf(fid,'%g\t',corner4{1,1}(i,j));
            end
        end
    end
    fclose(fid);
    cd('../../');
    
    
    precisions = precision_plot(positions{1,1}, vGroundTruth, videos{seq}, show_plots);
%     suncesses = sucess_plot(rects{1,1}, vGroundTruth, videos{seq}, show_plots);
    fps(seq) = numel(ImgFiles{1,1}) / time;
    pre(seq) = precisions(5);
    
%      fprintf('%12s - Precision (5px):% 1.3f, FPS:% 4.2f\n', videos{seq}, precisions(5), fps);
     fprintf('\n%15s - Precision (5px):% 1.3f, FPS:% 4.2f', videos{seq}, pre(seq), fps(seq));
%     fclose('all');
                                            
    
end

