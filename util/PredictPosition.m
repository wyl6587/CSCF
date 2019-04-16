function [post] = PredictPosition1(feat, pos, opts, model_Zf, Init_model_Zf)

% ================================================================================
% Compute correlation filter responses at each moldal
% ================================================================================
for ii = 1:size(feat,2)
    
   sf = fft2(feat{1,ii});
   
   temp = real(fftshift(ifft2(sum(model_Zf{1,ii} .* sf,3))));
   
   response{ii}     = temp/max(temp(:));
   
   temp = real(fftshift(ifft2(sum(Init_model_Zf{1,ii} .* sf,3))));
   
   response_init{ii} = temp/max(temp(:));

end
res_cur = response{1} + response{2};

res_init = response_init{1} + response_init{2};
W = 1;%0.95
resss = W * res_cur + (1-W) * res_init;
maxr = max(resss(:));
[row,col] = find(resss == maxr,1);

vert_delta = row; horiz_delta = col;
% ================================================================================
% Find target location
% ================================================================================
% Target location is at the maximum response. we must take into
% account the fact that, if the target doesn't move, the peak
% will appear at the top-left corner, not at the center (this is
% discussed in the KCF paper). The responses wrap around cyclically.
   
  vert_delta = vert_delta - floor(size(sf,1)/2);
  horiz_delta = horiz_delta - floor(size(sf,2)/2);
  
   % Map the position to the image space
  pos = pos + opts.cell_size * [vert_delta - 1, horiz_delta - 1];
  post{1,1} = pos;
  post{1,2} = pos;
end


