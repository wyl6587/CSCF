function [model_xf, model_Zf] = updateModel(feat, yf, opts, frame, model_xf, model_Zf)
w = [1 1];

[xf, Zf] = ADMM_M4(feat, yf,opts);%Ä£ÐÍ4


%model initialization or update
if frame == 1 %First Frame train with single image
    for ii =1:size(feat,2)
        model_Zf{ii} = Zf{ii};
        model_xf{ii} = xf{ii};
    end
else
    %Online model update using learing rate inter_factor
    for ii = 1:size(feat,2)
        model_Zf{ii} = (1 - opts.interp_factor) * model_Zf{ii} + opts.interp_factor * Zf{ii};
        model_xf{ii} = (1 - opts.interp_factor) * model_xf{ii} + opts.interp_factor * xf{ii};
    end
end
end