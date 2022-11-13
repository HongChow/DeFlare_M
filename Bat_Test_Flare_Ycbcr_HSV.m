clear
%file_path = './Flare_Data2/';
file_path = './BAD/';
%file_path = './TEST2/';
close all;
omg = 0.125;
img_path_list = dir(strcat(file_path,'*.jpg'));
for i=1:length(img_path_list)
    disp('i=');
    disp(i);
    image_name = img_path_list(i).name;
    disp('image_name=');
    disp(image_name);
    processed_name = sprintf("Deflare_crHSV_omg.125_%s",image_name);
    disp(processed_name)
    image =  imread(strcat(file_path,image_name));
%       figure,imshow(image);
    ori_image = image;
    [h,w,~]=size(ori_image);
    if (h<w)
        ori_image = rot90(ori_image);
    end
    lab = rgb2lab(double(ori_image)/255);    
    
    image_double = double(ori_image);
    
    %获取亮度,即原图的灰度拷贝
    ima_r = image_double(:,:,1);
    ima_g = image_double(:,:,2);
    ima_b = image_double(:,:,3);   
    

ima_y = 0.256789 * ima_r + 0.504129 * ima_g + 0.097906 * ima_b + 16;

%获取蓝色分量

ima_cb = -0.148223 * ima_r - 0.290992 * ima_g + 0.439215 * ima_b + 128;

%获取红色分量

ima_cr = 0.439215 * ima_r - 0.367789 * ima_g - 0.071426 * ima_b + 128;

    
    lab_roi = lab(end-899:end,:,:);
    lab_a = lab(:,:,2);
    lab_roi_a = lab_roi(:,:,2);
    
    cr_roi = ima_cr(end-899:end,:);
    y_roi = ima_y(end-899:end,:);
    cb_roi = ima_cb(end-899:end,:);
    
    roi_img = ori_image(end-899:end,:,:);
%     figure,imshow(lab_roi_a*6,[-128,128]),title(processed_name);
    [height,width,~] = size(ori_image);
    x0 = width/2;
    b1 = 900 - 48;
    b2 = 900 - 108;
    pline_x = 1:width;
    a1 = -(562-58)*8/(width^2);
    a2 = -(762-58)*8/(width^2);
    pline_y1 = 0.5*a1*(pline_x-x0).^2+b1;   
    pline_y2 = 0.5*a2*(pline_x-x0).^2+b2;   
    blend_mask = zeros(900,width);
    for i=1:900
        for j=1:width
            if (i>=0.5*a1*(j-x0).^2+b1)
                blend_mask(i,j)=1;
            elseif(i<0.5*a2*(j-x0).^2+b2)
                blend_mask(i,j)=0;
            else
                smooth_dy = 0.5*a1*(j-x0).^2+b1 - 0.5*a2*(j-x0).^2-b2;
                valid_dy = i-0.5*a2*(j-x0).^2-b2;
                blend_mask(i,j)=valid_dy/smooth_dy;
            end
        end
    end
    blend_mask_left_right = zeros(900,width);
    left_right_depth = 50;
    for i=1:900
        for j=1:width
            if j< width/2 - left_right_depth
                blend_mask_left_right(i,j) = 0;
            elseif (j>= width/2 - left_right_depth) && (j< width/2 + left_right_depth)
                blend_mask_left_right(i,j) = (j-(width/2-left_right_depth))/(2*left_right_depth);
            else
                blend_mask_left_right(i,j) = 1;
            end
        end
    end
    
%     [avg_inner_0,avg_inner_1,avg_outter_0,avg_outter_1] = FlarePreJudge_regions_ROI(lab_a);  
    [avg_inner_0,avg_inner_1,avg_outter_0,avg_outter_1] = FlarePreJudge_regions_ROI(lab_a);  
%     flag0 = avg_outter_0 - avg_inner_0>3;
%     flag1 = avg_outter_1 - avg_inner_1>3;
    delt0 = avg_outter_0 - avg_inner_0;
    delt1 = avg_outter_1 - avg_inner_1;
    flag0 = delt0>3;
    flag1 = delt1>3;
    th = Gradient_Seg_ROI_Part(lab_a,a2,b2,flag0,flag1);
    th = 0.85*th;
    %[output_color] = Suppression(cr_roi,th);  
    hsv_roi = rgb2hsv(roi_img);
    rgb_roi_back = hsv2rgb(hsv_roi);
    s_roi = hsv_roi(:,:,2);
    [output_s] = Suppression_HSV(cr_roi,th,s_roi,omg); 
    

    
    if flag0 && flag1
        output_color_blend = output_s.*(blend_mask)+s_roi.*(1-blend_mask);
    elseif flag0
        output_color_blend_left_right = output_s.*(1-blend_mask_left_right)+s_roi.*(blend_mask_left_right);
        output_color_blend = output_color_blend_left_right.*(blend_mask)+s_roi.*(1-blend_mask);
    elseif flag1
        output_color_blend_left_right = output_s.*(blend_mask_left_right)+s_roi.*(1-blend_mask_left_right);
        output_color_blend = output_color_blend_left_right.*(blend_mask)+s_roi.*(1-blend_mask);
    else
        output_color_blend = s_roi;
    end
    output_color_blend(output_color_blend>1)=1;
    output_color_blend(output_color_blend<0)=0;
   
    if flag0
         flag0 = 'True';
     else
         flag0 = 'False';
     end
     if flag1
         flag1 = 'True';
     else
         flag1 = 'False';
     end       
    text_str0 = ['flag0=' flag0  ' flag1='  flag1];
    hsv_roi_adjust = hsv_roi;
    hsv_roi_adjust(:,:,2) = output_color_blend;
    % --- output_color_blend --- % cr prcocessed
%     cr_adjust = output_color_blend;
%     R_adjust_roi = 1.164*(y_roi-16) + 1.596*(cr_adjust -128);
%     G_adjust_roi = 1.164*(y_roi-16) - 0.813*(cr_adjust-128) - 0.392*(cb_roi-128);
%     B_adjust_roi = 1.164*(y_roi-16) + 2.017*(cb_roi-128);
%     
%     rgb_roi_adjust = cat(3,R_adjust_roi,G_adjust_roi,B_adjust_roi);


    output_adjust = ori_image; 
    rgb_roi_adjust = hsv2rgb(hsv_roi_adjust);
    output_adjust(end-899:end,:,:) = uint8(255*rgb_roi_adjust);

%     imwrite(output_adjust,processed_name);
%     figure,imshow(blend_mask)        
%     figure,imshow(rgb_roi),title('roi');
%     hold on;    
%     plot(pline_x, pline_y1+(height-900), 'b-', 'LineWidth', 1);    
%     plot(pline_x, pline_y2+(height-900), 'b-', 'LineWidth', 1); 
    position0 = [5 10];
%     position1 = [width/2 10];
    image_show = insertText(output_adjust,position0,text_str0,'FontSize',48,'BoxColor','r','BoxOpacity',0.4,'TextColor','white');
    imwrite(image_show,processed_name);
%     plot(pline_x, pline_y, 'b-', 'LineWidth', 3);
%     plot(pline_y,pline_x, 'b-', 'LineWidth', 3);
%     impixelinfo;
end  
