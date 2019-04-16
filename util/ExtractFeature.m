function feat = ExtractFeature(Frame, pos, window_sz, current_scale_factor, cos_window, opts)
% Get the search window from previous detection
patch = get_subwindow(Frame, pos, window_sz, current_scale_factor);
% Extracting features

feat = get_features(patch, cos_window, opts);%HOG & GRAY

end                                                                          