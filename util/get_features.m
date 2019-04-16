function feat = get_features(patch, cos_window, opts)

feat = cell(size(patch));

%HOG features, from Piotr's Toolbox
if opts.features.hog
    feat{1,1} = double(fhog(single(patch{1,1}) / 255, opts.cell_size, opts.hog_orientations));
    feat{1,1}(:,:,end) = [];  %remove all-zeros channel ("truncation feature")
    feat{1,2} = double(fhog(single(patch{1,2}) / 255, opts.cell_size, opts.hog_orientations));
    feat{1,2}(:,:,end) = [];
end

%Gray features
if opts.features.gray
    feat{1,1} = double(patch{1,1}) / 255;
    feat{1,1} = feat{1,1} - mean(feat{1,1}(:));
    feat{1,2} = double(patch{1,2}) / 255;
    feat{1,2} = feat{1,2} - mean(feat{1,2}(:));
end


%process with cosine window if needed
if ~isempty(cos_window)
    feat{1,1} = bsxfun(@times, feat{1,1}, cos_window);
    feat{1,2} = bsxfun(@times, feat{1,2}, cos_window);
end

end