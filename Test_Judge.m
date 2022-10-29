    lab = rgb2lab(double(image)/255);
    lab_roi = lab(end-999:end,:,:);
    lab_roi_a = lab_roi(:,:,2);