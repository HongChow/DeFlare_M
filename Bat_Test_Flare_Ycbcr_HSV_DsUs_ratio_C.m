
function Bat_Test_Flare_Ycbcr_HSV_DsUs_ratio_C(omg,th_delt,max_color_delt,gamma)

clear
%file_path = './Flare_Data2/';
file_path = '/home/hong/Deflare/Data/flare_dataset/DL/Bad/';
file_path = 'BAD/';
close all;
img_path_list = dir(strcat(file_path,'*.jpg'));
if (nargin<1)
    omg = 0.125;
    th_delt = 0;
    max_color_delt = 0;
    gamma = 1;
    s_ratio = 16;
else
    if (nargin~=4)
        error(message('Not sufficient paramters'));
    end
end
    
for i=1:length(img_path_list)
    disp('i=');
    disp(i);
    image_name = img_path_list(i).name;
    disp('image_name=');
    disp(image_name);
    outname_part1 = strcat('Deflare_crHSV_omg_',sprintf('%1.3f',omg));
    outname_part2 = strcat(outname_part1, sprintf('_s_ratio_%2.0f_',s_ratio));   
    outname_part3 = strcat(outname_part1,outname_part2);
    processed_name = strcat(outname_part3,image_name);
%    processed_name = sprintf("Deflare_crHSV_omg.125_dsus_ratio__omg0.25_%s",image_name);
    disp(processed_name)
    image =  imread(strcat(file_path,image_name));
%       figure,imshow(image);
    ori_image = image;
    [h,w,~]=size(ori_image);   
    if (h<w)
        ori_image = rot90(ori_image);
    end
    
    [height,width,~] = size(ori_image);    
    roi_img = ori_image(end-895:end,:,:);
    [height_roi,width_roi,~] = size(roi_img);
    lab_roi = rgb2lab(double(roi_img)/255);
    lab_roi_a = lab_roi(:,:,2);
    %figure(1),imshow(roi_img),title('roi  img')
   
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
   
    %figure(3),imshow(uint8(roi_img_ds)),title('roi img ds')
    b1 = (896 - 48)/s_ratio;
    b2 = (896 - 108)/s_ratio;
    a1 = -(562-58)*8*s_ratio/(width^2);
    a2 = -(762-58)*8*s_ratio/(width^2);
    [h_roi_ds,w_roi_ds,~] = size(roi_img_ds);
    x0_ds = w_roi_ds/2;
    pline_x = 1:w_roi_ds;
    
    pline_y1 = 0.5*a1*(pline_x-x0_ds).^2+b1;   
    pline_y2 = 0.5*a2*(pline_x-x0_ds).^2+b2; 
%     hold on;
%     plot(pline_x, pline_y1, 'b-', 'LineWidth', 3);
%     plot(pline_x, pline_y2, 'r-', 'LineWidth', 3);
%     
    roi_ds_double = double(roi_img_ds);
    
    %获取亮度,即原图的灰度拷贝
    ima_r = roi_ds_double(:,:,1);
    ima_g = roi_ds_double(:,:,2);
    ima_b = roi_ds_double(:,:,3);
  
img_y = 0.256789 * ima_r + 0.504129 * ima_g + 0.097906 * ima_b + 16;

%获取蓝色分量

img_cb = -0.148223 * ima_r - 0.290992 * ima_g + 0.439215 * ima_b + 128;

%获取红色分量

img_cr = 0.439215 * ima_r - 0.367789 * ima_g - 0.071426 * ima_b + 128;

%     cr_roi = ima_cr(end-895:end,:);
%     y_roi = ima_y(end-895:end,:);
%     cb_roi = ima_cb(end-895:end,:);
    
    cr_roi_ds = img_cr;
    roi_ds_double = roi_ds_double/255.0;
  
    hsv_roi_ds_padded = rgb2hsv(roi_img_ds); 
    s_roi_ds_padded = hsv_roi_ds_padded(:,:,2);
    [avg_inner_0,avg_inner_1,avg_outter_0,avg_outter_1] = FlarePreJudge_regions_ROI(lab_roi_a);  
%     flag0 = avg_outter_0 - avg_inner_0>3;
%     flag1 = avg_outter_1 - avg_inner_1>3;
    delt0 = avg_outter_0 - avg_inner_0;
    delt1 = avg_outter_1 - avg_inner_1;
    flag0 = delt0>3;
    flag1 = delt1>3;  
    %figure,imshow(uint8(roi_img_ds)),title('roi img downsample 1/64')
       
    th = Gradient_Seg_ROI_Part_dsus_64(cr_roi_ds,a2,b2,flag0,flag1);
    
    if(flag0 || flag1)
        [output_s_ds] = Suppression_HSV_DsUs_16_V2(cr_roi_ds,th,s_roi_ds_padded,omg,gamma,flag0,flag1);
    else
        output_s_ds = s_roi_ds_padded;
    end
    output_s_ds(output_s_ds>1)=1;
    output_s_ds(output_s_ds<0)=0;
    
    hsv_roi_ds_adjust = hsv_roi_ds_padded;
    hsv_roi_ds_adjust(:,:,2) = output_s_ds;    
    rgb_roi_ds_adjust = hsv2rgb(hsv_roi_ds_adjust);
    rgb_roi_ds_adjust = rgb_roi_ds_adjust/255.0;
    
    roi_rgb_adjust_us_padded = imresize(rgb_roi_ds_adjust,s_ratio,'bilinear');
%     figure(5),imshow(roi_rgb_adjust_us_padded),title('adjust roi img us ')
%     imwrite(roi_rgb_adjust_us_padded,strcat(strcat('rgb adjust roi img us ',sprintf('%2.0f',s_ratio)),'.png'));
    roi_rgb_adjust_us = crop_h_direction(roi_rgb_adjust_us_padded,pad_rad);
    % ----- alpha blending from original image ----- %
    
    b1_ori = (896 - 48); % 848
    b2_ori = (896 - 108);% 788
    a1_ori = -(562-58)*8/(width^2); % -0.0006728
    a2_ori = -(762-58)*8/(width^2); % -0.0009398
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
    
    % -------------- DO ALPHA BLENDING  ----------------- %
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
    imwrite(uint8(output_adjust),processed_name);
   figure,imshow(uint8(output_adjust)),title('output image')
    hold on;    
    plot(pline_x_ori, pline_y1_ori+(height-896), 'b-', 'LineWidth', 1);    
    plot(pline_x_ori, pline_y2_ori+(height-896), 'b-', 'LineWidth', 1);
    
%    disp(' ');
    
    
    
    
    
% %     figure(4),imshow((rgb_roi_ds_adjust))
%     roi_rgb_adjust_us_padded = imresize(rgb_roi_ds_adjust,s_ratio,'bilinear');
% %     figure(5),imshow(roi_rgb_adjust_us_padded),title('adjust roi img us ')
% %     imwrite(roi_rgb_adjust_us_padded,strcat(strcat('rgb adjust roi img us ',sprintf('%2.0f',s_ratio)),'.png'));
%     roi_rgb_adjust_us = crop_h_direction(roi_rgb_adjust_us_padded,pad_rad);
%     % ----- alpha blending from original image ----- %
%     
%     
% %     
% %     figure,imshow(roi_img_ds);
% % %     figure,imshow(lab_roi_a*6,[-128,128]),title(processed_name);
% %     hold on;
%      [height,width,~] = size(ori_image);
%     x0 = width/2/8/2;
%     b1 = (896 - 48)/8/2;
%     b2 = (896 - 108)/8/2;
%     pline_x = 1:width/8/2;
% %     a1 = -(562-58)*8/(width^2);
% %     a2 = -(762-58)*8/(width^2);
%     a1 = -0.00538*2;% -0.01076
%     a2 = -0.00752*2;% -0.01504
%     pline_y1 = 0.5*a1*(pline_x-x0).^2+b1;   
%     pline_y2 = 0.5*a2*(pline_x-x0).^2+b2;
% %     plot(pline_x, pline_y1, 'b-', 'LineWidth', 1);    
% %     plot(pline_x, pline_y2, 'b-', 'LineWidth', 1);
% %   
%     
%     
%     blend_mask = zeros(112/2,width/8/2);
%     for i=1:112/2
%         for j=1:width/8/2
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
%     blend_mask_left_right = zeros(112/2,width/8/2);
%     left_right_depth = 8/2;
%     for i=1:112/2
%         for j=1:width/8/2
%             if j< width/2/8/2 - left_right_depth
%                 blend_mask_left_right(i,j) = 0;
%             elseif (j>= width/2/8/2 - left_right_depth) && (j< width/2/8/2 + left_right_depth)
%                 blend_mask_left_right(i,j) = (j-(width/2/8/2-left_right_depth/8/2))/(2*left_right_depth);
%             else
%                 blend_mask_left_right(i,j) = 1;
%             end
%         end
%     end
%     
% %     [avg_inner_0,avg_inner_1,avg_outter_0,avg_outter_1] = FlarePreJudge_regions_ROI(lab_a);  
%     [avg_inner_0,avg_inner_1,avg_outter_0,avg_outter_1] = FlarePreJudge_regions_ROI_DsUs(lab_a);  
% %     flag0 = avg_outter_0 - avg_inner_0>3;
% %     flag1 = avg_outter_1 - avg_inner_1>3;
%     delt0 = avg_outter_0 - avg_inner_0;
%     delt1 = avg_outter_1 - avg_inner_1;
%     flag0 = delt0>3;
%     flag1 = delt1>3;
% 
%     %[output_color] = Suppression(cr_roi,th);  
%     hsv_roi = rgb2hsv(roi_img);
%     %hsv_roi_handv2 = rgb2hsv_handV2(roi_img);
%     s_roi = hsv_roi(:,:,2);
%     s_roi_ds = imresize(s_roi,0.125/2,'bilinear');
%     
%     th = Gradient_Seg_ROI_Part_dsus_16(cr_roi_ds,a2,b2,flag0,flag1);
% %     cr_roi_ds_seg = (cr_roi_ds>=th).*1+(cr_roi_ds<th).*0;
% %     figure,imshow(cr_roi_ds_seg),title('segment cr roi ds')
%     if(flag0 || flag1)
%         [output_s] = Suppression_HSV_DsUs_16_V2(cr_roi_ds,th,s_roi_ds,omg,gamma,flag0,flag1);
%     else
%         output_s = s_roi_ds;
%     end
%     output_color = output_s;
%     lab_roi_a = s_roi_ds;
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
% %     output_color_blend(output_color_blend>1)=1;
% %     output_color_blend(output_color_blend<0)=0;
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
%     
%     % --- output_color_blend --- % cr prcocessed
%           
%     s_adjust = imresize(output_color_blend,16,'bilinear');
%     s_adjust(s_adjust>1)=1;
%     s_adjust(s_adjust<0)=0;
%     hsv_roi_adjust = hsv_roi;
%     hsv_roi_adjust(:,:,2) = s_adjust;
%     output_adjust = ori_image; 
%     %rgb_roi_adjust = hsv2rgb(hsv_roi_adjust);
%     rgb_roi_adjust = hsv2rgb_temp(hsv_roi_adjust);
%     output_adjust(end-895:end,:,:) = uint8(255*rgb_roi_adjust);
%     
% %    imwrite(output_adjust,processed_name);
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
%     figure,imshow(image_show)
% %     plot(pline_x, pline_y, 'b-', 'LineWidth', 3);
% %     plot(pline_y,pline_x, 'b-', 'LineWidth', 3);
% %     impixelinfo;
end  

end
