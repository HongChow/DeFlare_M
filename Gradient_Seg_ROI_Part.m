function [th_roi] = Gradient_Seg_ROI_Part(input_color,a,b,flag0,flag1)
    [height,width] = size(input_color);
    x0 = width/2;
    blend_mask = zeros(size(input_color));
    for i=1:900
        for j=1:width
            %             if (i>=0.5*a*(j-x0).^2+b)
            if flag0&& flag1 % left and left
                if (i>=0.5*a*(j-x0).^2+b) && (i>j+height-width) && (i>-j+height)
                    blend_mask(i,j)=1;
                end                 
            elseif flag0 % left
                if (i>=0.5*a*(j-x0).^2+b) && (i>-j+height) && (j<=width/2)
                    blend_mask(i,j)=1;
                end                
            elseif flag1 % right
                if (i>=0.5*a*(j-x0).^2+b) && (i>j+height-width) && (j>width/2)
                    blend_mask(i,j)=1;
                end               
            end
        end
    end
    blend_mask = blend_mask(2:end-1,2:end-1);
    input_color = imgaussfilt(input_color,8);
    h_gradient_op = [-1,0,1];
    v_gradient_op = h_gradient_op';
    gradient_h = abs(conv2(input_color,h_gradient_op,'valid'));
    gradient_h = gradient_h(2:end-1,:);
    gradient_v = abs(conv2(input_color,v_gradient_op,'valid'));
    gradient_v = gradient_v(:,2:end-1,:);
    max_gradient = max(gradient_h,gradient_v);
    max_gradient_roi = max_gradient.*(blend_mask);
    input_gray_roi = input_color(2:end-1,2:end-1);
    th_roi = sum(sum(input_gray_roi.*max_gradient_roi))/sum(max_gradient_roi(:));    
    th = sum(sum(input_gray_roi.*max_gradient))/sum(max_gradient(:));    
%     seg_map = (input_gray_roi-th);   
%     seg_map_binary = seg_map>=0;
%     figure,imshow(seg_map_binary),title('seg_th');
%     seg_map_roi = (input_gray_roi-th_roi);   
%     seg_map_binary_roi = seg_map_roi>=0;
%     figure,imshow(seg_map_binary_roi),title('seg_th_roi');
end