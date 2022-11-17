clear
file_path = '/home/hong/Deflare/Data/flare_dataset/DL/Bad/';
file_path = 'BAD/';
close all;
img_path_list = dir(strcat(file_path,'*.jpg'));
for i=1:length(img_path_list)
    disp('i=');
    disp(i);
    image_name = img_path_list(i).name;
    disp('image_name=');
    disp(image_name);
    processed_name = sprintf("Deflare_Lab_dsus_%s",image_name);
    disp(processed_name)
    omg = 0.125;
    image =  imread(strcat(file_path,image_name));
%       figure,imshow(image);
    ori_image = image;
    [height,width,~] = size(ori_image);    
    roi_img = ori_image(end-895:end,:,:);
    [height_roi,width_roi,~] = size(roi_img);
    lab_roi = rgb2lab(double(roi_img)/255);
    lab_roi_a = lab_roi(:,:,2);
    %figure(1),imshow(roi_img),title('roi  img')
    s_ratio = 64;
    switch (s_ratio)
        case 64
            pad_rad = 24;
        case 32
            pad_rad = 8;
        case 16
            pad_rad = 0;
        case 8
            pad_rad = 0;
        case 4
            pad_rad = 0;
        case 2
            pad_rad = 0;
        case 1
            pad_rad = 0;
    end
     % ---- padding %
    roi_img_padded = padding_h_direction_by_edge(roi_img,pad_rad);
    disp('size of padded img = ');
    disp(size(roi_img_padded));
%     figure(2),imshow(uint8(roi_img_padded)),title('padded img')
    
    
    roi_img_ds = imresize(roi_img_padded,1/s_ratio,'bilinear'); %
    figure(3),imshow(uint8(roi_img_ds)),title('roi img ds')
    b1 = (896 - 48)/s_ratio;
    b2 = (896 - 108)/s_ratio;
    a1 = -(562-58)*8*s_ratio/(width^2);
    a2 = -(762-58)*8*s_ratio/(width^2);
    [h_roi_ds,w_roi_ds,~] = size(roi_img_ds);
    x0_ds = w_roi_ds/2;
    pline_x = 1:w_roi_ds;
    
    pline_y1 = 0.5*a1*(pline_x-x0_ds).^2+b1;   
    pline_y2 = 0.5*a2*(pline_x-x0_ds).^2+b2; 
    hold on;
    plot(pline_x, pline_y1, 'b-', 'LineWidth', 3);
    plot(pline_x, pline_y2, 'r-', 'LineWidth', 3);
    
    disp(size(roi_img_ds));
    lab_roi_ds = rgb2lab(double(roi_img_ds)/255);
    lab_roi_ds_a = lab_roi_ds(:,:,2);
    
    [avg_inner_0,avg_inner_1,avg_outter_0,avg_outter_1] = FlarePreJudge_regions_ROI(lab_roi_a);  
%     flag0 = avg_outter_0 - avg_inner_0>3;
%     flag1 = avg_outter_1 - avg_inner_1>3;
    delt0 = avg_outter_0 - avg_inner_0;
    delt1 = avg_outter_1 - avg_inner_1;
    flag0 = delt0>3;
    flag1 = delt1>3;  
    %figure,imshow(uint8(roi_img_ds)),title('roi img downsample 1/64')
    
    th = Gradient_Seg_ROI_Part_dsus_64(lab_roi_ds_a,a2,b2,flag0,flag1);
    th = 0.7*th;
    [output_color] = Suppression(lab_roi_ds_a,th,omg); 
    lab_roi_ds_adjust = lab_roi_ds;
    lab_roi_ds_adjust(:,:,2) = output_color;
    rgb_roi_ds_adjust = lab2rgb(lab_roi_ds_adjust);
%     figure(4),imshow((rgb_roi_ds_adjust))
    roi_rgb_adjust_us_padded = imresize(rgb_roi_ds_adjust,s_ratio,'bilinear');
%     figure(5),imshow(roi_rgb_adjust_us_padded),title('adjust roi img us ')
%     imwrite(roi_rgb_adjust_us_padded,strcat(strcat('rgb adjust roi img us ',sprintf('%2.0f',s_ratio)),'.png'));
    roi_rgb_adjust_us = crop_h_direction(roi_rgb_adjust_us_padded,pad_rad);
    % ----- alpha blending from original image ----- %
    
    b1_ori = (896 - 48);
    b2_ori = (896 - 108);
    a1_ori = -(562-58)*8/(width^2);
    a2_ori = -(762-58)*8/(width^2);
    % --- Generate Blending Mask From the original ROI Resolution ---%
    x0 = width_roi/2;
    pline_x_ori = 1:width_roi;
    
    pline_y1_ori = 0.5*a1_ori*(pline_x_ori-x0).^2+b1_ori;   
    pline_y2_ori = 0.5*a2_ori*(pline_x_ori-x0).^2+b2_ori; 
    
    for i=1:height_roi
        for j=1:width_roi
            if (i>=0.5*a1_ori*(j-x0).^2+b1_ori)
                blend_mask(i,j)=1;
            elseif(i<0.5*a2_ori*(j-x0).^2+b2_ori)
                blend_mask(i,j)=0;
            else
                smooth_dy = 0.5*a1_ori*(j-x0).^2+b1_ori - 0.5*a2_ori*(j-x0).^2-b2_ori;
                valid_dy = i-0.5*a2_ori*(j-x0).^2-b2_ori;
                blend_mask(i,j)=valid_dy/smooth_dy;
            end
        end
    end
    blend_mask_left_right = zeros(height_roi,width_roi);
    left_right_depth = 8;
    for i=1:height_roi
        for j=1:width_roi
            if j< width_roi/2 - left_right_depth
                blend_mask_left_right(i,j) = 0;
            elseif (j>= width_roi/2 - left_right_depth) && (j< width_roi/2 + left_right_depth)
                blend_mask_left_right(i,j) = (j-(width_roi/2-left_right_depth))/(2*left_right_depth);
            else
                blend_mask_left_right(i,j) = 1;
            end
        end
    end
    
    roi_rgb_ori = double(roi_img)/255;
    roi_rgb_ori_r = roi_rgb_ori(:,:,1);
    roi_rgb_ori_g = roi_rgb_ori(:,:,2);
    roi_rgb_ori_b = roi_rgb_ori(:,:,3);    
    
    roi_adjust_r = roi_rgb_adjust_us(:,:,1);
    roi_adjust_g = roi_rgb_adjust_us(:,:,2);
    roi_adjust_b = roi_rgb_adjust_us(:,:,3);
    
    if flag0 && flag1
        roi_adjust_output_r = roi_adjust_r.*(blend_mask)+roi_rgb_ori_r.*(1-blend_mask);
        roi_adjust_output_g = roi_adjust_g.*(blend_mask)+roi_rgb_ori_g.*(1-blend_mask);
        roi_adjust_output_b = roi_adjust_b.*(blend_mask)+roi_rgb_ori_b.*(1-blend_mask);
    elseif flag0
        output_color_blend_left_right_r = roi_adjust_r.*(1-blend_mask_left_right)+roi_rgb_ori_r.*(blend_mask_left_right);
        output_color_blend_left_right_g = roi_adjust_g.*(1-blend_mask_left_right)+roi_rgb_ori_g.*(blend_mask_left_right);
        output_color_blend_left_right_b = roi_adjust_b.*(1-blend_mask_left_right)+roi_rgb_ori_b.*(blend_mask_left_right);
        roi_adjust_output_r = output_color_blend_left_right_r.*(blend_mask)+roi_rgb_ori_r.*(1-blend_mask);
        roi_adjust_output_g = output_color_blend_left_right_g.*(blend_mask)+roi_rgb_ori_g.*(1-blend_mask);
        roi_adjust_output_b = output_color_blend_left_right_b.*(blend_mask)+roi_rgb_ori_b.*(1-blend_mask);
    elseif flag1
        output_color_blend_left_right_r = roi_adjust_r.*(blend_mask_left_right)+roi_rgb_ori_r.*(1-blend_mask_left_right);
        output_color_blend_left_right_g = roi_adjust_g.*(blend_mask_left_right)+roi_rgb_ori_g.*(1-blend_mask_left_right);
        output_color_blend_left_right_b = roi_adjust_b.*(blend_mask_left_right)+roi_rgb_ori_b.*(1-blend_mask_left_right);
        roi_adjust_output_r = output_color_blend_left_right_r.*(blend_mask)+roi_rgb_ori_r.*(1-blend_mask);
        roi_adjust_output_g = output_color_blend_left_right_g.*(blend_mask)+roi_rgb_ori_g.*(1-blend_mask);
        roi_adjust_output_b = output_color_blend_left_right_b.*(blend_mask)+roi_rgb_ori_b.*(1-blend_mask);
    else
        roi_adjust_output_r = roi_rgb_ori_r;
        roi_adjust_output_g = roi_rgb_ori_g;
        roi_adjust_output_b = roi_rgb_ori_b;
    end
    
    roi_adjust_output = cat(3,roi_adjust_output_r,roi_adjust_output_g,roi_adjust_output_b);
    % ----- fill back ------ %
    
    output_adjust = ori_image;
    output_adjust(end-895:end,:,:) = uint8(255*roi_adjust_output);
    
    figure,imshow(uint8(output_adjust)),title('output image')
    hold on;    
    plot(pline_x_ori, pline_y1_ori+(height-896), 'b-', 'LineWidth', 1);    
    plot(pline_x_ori, pline_y2_ori+(height-896), 'b-', 'LineWidth', 1);
    
    disp(' ');
    
    
%     image_double = double(roi_img_ds);
%     
%     %获取亮度,即原图的灰度拷贝
%     ima_r = image_double(:,:,1);
%     ima_g = image_double(:,:,2);
%     ima_b = image_double(:,:,3);
%     
%     
%     
%     lab = rgb2lab(double(ori_image)/255);
%     lab_roi = lab(end-895:end,:,:);
%     lab_a = lab(:,:,2);
%     lab_roi_a_0s = lab_roi(:,:,2);
%     lab_roi_a_ds = imresize(lab_roi_a_0s,0.125,'bicubic');
%     lab_roi_a = lab_roi_a_ds;
%     
% %     figure,imshow(lab_roi_a*6,[-128,128]),title(processed_name);
%     hold on;
%     [height,width,~] = size(image);
%     x0 = width/2/8;
% %     b1 = (896 - 48)/8;
% %     b2 = (896 - 108)/8;
% %     pline_x = 1:width/8;
% % %     a1 = -(562-58)*8*8/(width^2);
% % %     a2 = -(762-58)*8*8/(width^2);
% %     a1 = -0.00538;
% %     a2 = -0.00752;
%     
%     b1 = (896 - 48)/64;
%     b2 = (896 - 108)/64;
%     a1 = -(562-58)*8*64/(width^2);
%     a2 = -(762-58)*8*64/(width^2);
%     
%     pline_x = 1:width/8;
% %     a1 = -(562-58)*8*8/(width^2);
% %     a2 = -(762-58)*8*8/(width^2);
%     
%     
%     pline_y1 = 0.5*a1*(pline_x-x0).^2+b1;   
%     pline_y2 = 0.5*a2*(pline_x-x0).^2+b2;   
%     blend_mask = zeros(112,width/8);
%     for i=1:112
%         for j=1:width/8
%             if (i>=0.5*a1*(j-x0).^2+b1)
%                 blend_mask(i,j)=1;
%             elseif(i<0.5*a2*(j-x0).^2+b2)
%                 blend_mask(i,j)=0;
%             else
%                 smooth_dy = 0.5*a1*(j-x0).^2+b1 - 0.5*a2*(j-x0).^2-b2;
%                 valid_dy = i-0.5*a2*(j-x0).^2-b2;
%                 blend_mask(i,j)=valid_dy/smooth_dy;
%             end
%         end
%     end
%     blend_mask_left_right = zeros(112,width/8);
%     left_right_depth = 8;
%     for i=1:112
%         for j=1:width/8
%             if j< width/2/8 - left_right_depth
%                 blend_mask_left_right(i,j) = 0;
%             elseif (j>= width/2/8 - left_right_depth) && (j< width/2/8 + left_right_depth)
%                 blend_mask_left_right(i,j) = (j-(width/2/8-left_right_depth/8))/(2*left_right_depth);
%             else
%                 blend_mask_left_right(i,j) = 1;
%             end
%         end
%     end
%     
% %     [avg_inner_0,avg_inner_1,avg_outter_0,avg_outter_1] = FlarePreJudge_regions_ROI(lab_a);  
%     
%     th = Gradient_Seg_ROI_Part_dsus(lab_roi_a,a2,b2,flag0,flag1);
%     lab_roi_a_ds_seg = (lab_roi_a>=th).*1+(lab_roi_a<th).*0;
%     figure,imshow(lab_roi_a_ds_seg),title('segment lab a roi ds')
%     [output_color] = Suppression(lab_roi_a,th,omg);  
%     if flag0 && flag1
%         output_color_blend = output_color.*(blend_mask)+lab_roi_a.*(1-blend_mask);
%     elseif flag0
%         output_color_blend_left_right = output_color.*(1-blend_mask_left_right)+lab_roi_a.*(blend_mask_left_right);
%         output_color_blend = output_color_blend_left_right.*(blend_mask)+lab_roi_a.*(1-blend_mask);
%     elseif flag1
%         output_color_blend_left_right = output_color.*(blend_mask_left_right)+lab_roi_a.*(1-blend_mask_left_right);
%         output_color_blend = output_color_blend_left_right.*(blend_mask)+lab_roi_a.*(1-blend_mask);
%     else
%         output_color_blend = lab_roi_a;
%     end
%     if flag0
%          flag0 = 'True';
%      else
%          flag0 = 'False';
%      end
%      if flag1
%          flag1 = 'True';
%      else
%          flag1 = 'False';
%      end       
%     text_str0 = ['flag0=' flag0  ' flag1='  flag1];   
%     lab_roi_adjust = lab_roi;
%     lab_roi_a_adjust = imresize(output_color_blend,8,'bicubic');
%     lab_roi_adjust(:,:,2) = lab_roi_a_adjust;
%     rgb_roi_adjust = lab2rgb(lab_roi_adjust);
%     output_adjust = ori_image;
%     output_adjust(end-895:end,:,:) = uint8(255*rgb_roi_adjust);
% %     output_adjust = uint8(255*rgb_roi_adjust);
%     imwrite(output_adjust,processed_name);
% %     figure,imshow(output_adjust);
% %     imwrite(output_adjust,processed_name);
% %     figure,imshow(blend_mask)        
% %     figure,imshow(rgb_roi),title('roi');
% %     hold on;    
% %     plot(pline_x, pline_y1+(height-900), 'b-', 'LineWidth', 1);    
% %     plot(pline_x, pline_y2+(height-900), 'b-', 'LineWidth', 1); 
%     position0 = [5 10];
% %     position1 = [width/2 10];
%     image_show = insertText(output_adjust,position0,text_str0,'FontSize',48,'BoxColor','r','BoxOpacity',0.4,'TextColor','white');
%     imwrite(image_show,processed_name);
%     %     plot(pline_x, pline_y, 'b-', 'LineWidth', 3);
%     %     plot(pline_y,pline_x, 'b-', 'LineWidth', 3);
% %     impixelinfo;
end  
