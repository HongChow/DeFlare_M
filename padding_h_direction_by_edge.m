function [padded_img] = padding_h_direction_by_edge(input_img,pad_rad)
  [h_ori,w_ori,depth] = size(input_img);
  padded_img = zeros(h_ori,w_ori+pad_rad*2,depth);
  padded_img(:,pad_rad+1:end-pad_rad,:) = input_img;
  left_part = input_img(:,1:pad_rad,:);
  right_part = input_img(:,end-pad_rad+1:end,:);
  left_mirror = fliplr(left_part);
  right_mirror = fliplr(right_part);
  padded_img(:,1:pad_rad,:) = left_mirror;
  padded_img(:,end-pad_rad+1:end,:) = right_mirror;
end