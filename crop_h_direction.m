function [cropped_img] = crop_h_direction(input_img,pad_rad)
     cropped_img = input_img(:,pad_rad+1:end-pad_rad,:);
end