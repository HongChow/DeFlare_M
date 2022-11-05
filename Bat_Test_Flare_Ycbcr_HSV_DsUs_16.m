
function Bat_Test_Flare_Ycbcr_HSV_DsUs_16(omg,th_delt,max_color_delt,gamma)

clear
file_path = './BAD/';
close all;
img_path_list = dir(strcat(file_path,'*.jpg'));
if (nargin<1)
    omg = 0;
    th_delt = 0;
    max_color_delt = 0;
    gamma = 0.5;
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
    processed_name = sprintf("Deflare_crHSV_omg.125_dsus16_%s",image_name);
    disp(processed_name)
    image =  imread(strcat(file_path,image_name));
%       figure,imshow(image);
    ori_image = image;
    lab = rgb2lab(double(ori_image)/255);
    lab_a = lab(:,:,2);
    
    
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

    cr_roi = ima_cr(end-895:end,:);
    y_roi = ima_y(end-895:end,:);
    cb_roi = ima_cb(end-895:end,:);
    
    cr_roi_ds = imresize(cr_roi,0.125/2,'bicubic');
    
    roi_img = ori_image(end-895:end,:,:);
    
    roi_img_ds = imresize(roi_img,0.125/2,'bicubic');
    
%     figure,imshow(roi_img_ds);
% %     figure,imshow(lab_roi_a*6,[-128,128]),title(processed_name);
%     hold on;
    [height,width,~] = size(image);
    x0 = width/2/8/2;
    b1 = (896 - 48)/8/2;
    b2 = (896 - 108)/8/2;
    pline_x = 1:width/8/2;
%     a1 = -(562-58)*8/(width^2);
%     a2 = -(762-58)*8/(width^2);
    a1 = -0.00538*2;
    a2 = -0.00752*2;
    pline_y1 = 0.5*a1*(pline_x-x0).^2+b1;   
    pline_y2 = 0.5*a2*(pline_x-x0).^2+b2;
%     plot(pline_x, pline_y1, 'b-', 'LineWidth', 1);    
%     plot(pline_x, pline_y2, 'b-', 'LineWidth', 1);
    
    
    
    blend_mask = zeros(112/2,width/8/2);
    for i=1:112/2
        for j=1:width/8/2
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
    blend_mask_left_right = zeros(112/2,width/8/2);
    left_right_depth = 8/2;
    for i=1:112/2
        for j=1:width/8/2
            if j< width/2/8/2 - left_right_depth
                blend_mask_left_right(i,j) = 0;
            elseif (j>= width/2/8/2 - left_right_depth) && (j< width/2/8/2 + left_right_depth)
                blend_mask_left_right(i,j) = (j-(width/2/8/2-left_right_depth/8/2))/(2*left_right_depth);
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
    
    
    %[output_color] = Suppression(cr_roi,th);  
    hsv_roi = rgb2hsv(roi_img);
    s_roi = hsv_roi(:,:,2);
    s_roi_ds = imresize(s_roi,0.125/2,'bicubic');
    th = Gradient_Seg_ROI_Part_dsus_16(cr_roi_ds,a2,b2,flag0,flag1);
    [output_s] = Suppression_HSV_DsUs_16(cr_roi_ds,th,s_roi_ds,omg);
    output_color = output_s;
    lab_roi_a = s_roi_ds;
    if flag0 && flag1
        output_color_blend = output_color.*(blend_mask)+lab_roi_a.*(1-blend_mask);
    elseif flag0
        output_color_blend_left_right = output_color.*(1-blend_mask_left_right)+lab_roi_a.*(blend_mask_left_right);
        output_color_blend = output_color_blend_left_right.*(blend_mask)+lab_roi_a.*(1-blend_mask);
    elseif flag1
        output_color_blend_left_right = output_color.*(blend_mask_left_right)+lab_roi_a.*(1-blend_mask_left_right);
        output_color_blend = output_color_blend_left_right.*(blend_mask)+lab_roi_a.*(1-blend_mask);
    else
        output_color_blend = lab_roi_a;
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
    
    % --- output_color_blend --- % cr prcocessed
          
    s_adjust = imresize(output_color_blend,16,'bicubic');
    hsv_roi_adjust = hsv_roi;
    hsv_roi_adjust(:,:,2) = s_adjust;
    output_adjust = ori_image; 
    rgb_roi_adjust = hsv2rgb(hsv_roi_adjust);
    output_adjust(end-895:end,:,:) = uint8(255*rgb_roi_adjust);
    
%    imwrite(output_adjust,processed_name);
%     figure,imshow(output_adjust);
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

end
