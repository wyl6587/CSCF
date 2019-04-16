function [ImgFiles, vground_truth, iground_truth] = load_video_info(base_path, video)
%LOAD_VIDEO_INFO
%   Loads all the relevant information for the video in the given path:
%   the list of image files (cell array of strings), initial position
%   (1x2), target size (1x2), the ground truth information for precision
%   calculations (Nx2, for N frames), and the path where the images are
%   located. The ordering of coordinates and sizes is always [y, x].
%


	%see if there's a suffix, specifying one of multiple targets, for
	%example the dot and number in 'Jogging.1' or 'Jogging.2'.
	if numel(video) >= 2 && video(end-1) == '.' && ~isnan(str2double(video(end))),
		suffix = video(end-1:end);  %remember the suffix
		video = video(1:end-2);  %remove it from the video name
	else
		suffix = '';
	end

	%full path to the video's files
	if base_path(end) ~= '/' && base_path(end) ~= '\',
		base_path(end+1) = '/';
	end
	Frames_path = [base_path video '/'];

        %list all images
    vImg = dir([Frames_path 'v/*.png']);
    iImg = dir([Frames_path 'i/*.png']);
    if isempty(vImg),
        vImg = dir([Frames_path 'v/*.bmp']);
        assert(~isempty(vImg), 'No visible image files to load.')
        iImg = dir([Frames_path 'i/*.bmp']);
        assert(~isempty(iImg), 'No infrared image files to load.')
    end
    len = size(vImg,1);
    ImgFiles = cell(len,2);
    for i = 1:len
        ImgFiles{i, 1} = [Frames_path 'v/' vImg(i).name];
        ImgFiles{i, 2} = [Frames_path 'i/' iImg(i).name];
    end
    
    
	%try to load ground truth from text file (Benchmark's format)
	vfilename = [Frames_path 'groundTruth_v' suffix '.txt'];
    ifilename = [Frames_path 'groundTruth_i' suffix '.txt'];
	fv = fopen(vfilename);
    fi = fopen(ifilename);
	assert(fv ~= -1 || fi ~= -1, 'No initial position or ground truth to load.')
	
	%the format is [x, y, width, height]
	try
		vground_truth(1,:) = textscan(fv, '%f,%f,%f,%f', 'ReturnOnError',false);  
        iground_truth(1,:) = textscan(fi, '%f,%f,%f,%f', 'ReturnOnError',false); 
	catch  %#ok, try different format (no commas)
		frewind(fv);
        frewind(fi);
		vground_truth(1,:) = textscan(fv, '%f %f %f %f');  
        iground_truth(1,:) = textscan(fi, '%f %f %f %f'); 
	end
	vground_truth = cat(2, vground_truth{:});
    iground_truth = cat(2, iground_truth{:});
	fclose(fv);
    
	
% 	if size(vground_truth,1) == 1
% 		%we have ground truth for the first frame only (initial position)
% 		vground_truth = [];
%         iground_truth = [];
% 	else
% 		%store positions instead of boxes
%         %每一帧中点的位置
% 		vground_truth = vground_truth(:,[2,1]) + vground_truth(:,[4,3]) / 2;
%     end
	

end