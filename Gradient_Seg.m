function [th] = Gradient_Seg(input_color)
    input_color = imgaussfilt(input_color,8);
    h_gradient_op = [-1,0,1];
    v_gradient_op = h_gradient_op';
    gradient_h = abs(conv2(input_color,h_gradient_op,'valid'));
    gradient_h = gradient_h(2:end-1,:);
    gradient_v = abs(conv2(input_color,v_gradient_op,'valid'));
    gradient_v = gradient_v(:,2:end-1,:);
    max_gradient = max(gradient_h,gradient_v);
    input_gray_roi = input_color(2:end-1,2:end-1);
    th = sum(sum(input_gray_roi.*max_gradient))/sum(max_gradient(:));    
%     seg_map = (input_gray_roi-th);   
%     seg_map_binary = seg_map>=0;
%     figure,imshow(seg_map_binary)
end