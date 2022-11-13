clear
file_path = '/home/hong/Deflare/Data/flare_dataset/DL/Bad/';
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
    lab = rgb2lab(double(ori_image)/255);
    lab_roi = lab(end-895:end,:,:);
    lab_a = lab(:,:,2);
    lab_roi_a_0s = lab_roi(:,:,2);
    lab_roi_a_ds = imresize(lab_roi_a_0s,0.125,'bicubic');
    lab_roi_a = lab_roi_a_ds;
    
%     figure,imshow(lab_roi_a*6,[-128,128]),title(processed_name);
    hold on;
    [height,width,~] = size(image);
    x0 = width/2/8;
    b1 = (896 - 48)/8;
    b2 = (896 - 108)/8;
    pline_x = 1:width/8;
%     a1 = -(562-58)*8/(width^2);
%     a2 = -(762-58)*8/(width^2);
    a1 = -0.00538;
    a2 = -0.00752;
    pline_y1 = 0.5*a1*(pline_x-x0).^2+b1;   
    pline_y2 = 0.5*a2*(pline_x-x0).^2+b2;   
    blend_mask = zeros(112,width/8);
    for i=1:112
        for j=1:width/8
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
    blend_mask_left_right = zeros(112,width/8);
    left_right_depth = 8;
    for i=1:112
        for j=1:width/8
            if j< width/2/8 - left_right_depth
                blend_mask_left_right(i,j) = 0;
            elseif (j>= width/2/8 - left_right_depth) && (j< width/2/8 + left_right_depth)
                blend_mask_left_right(i,j) = (j-(width/2/8-left_right_depth/8))/(2*left_right_depth);
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
    th = Gradient_Seg_ROI_Part_dsus(lab_roi_a,a2,b2,flag0,flag1);
    lab_roi_a_ds_seg = (lab_roi_a>=th).*1+(lab_roi_a<th).*0;
    figure,imshow(lab_roi_a_ds_seg),title('segment lab a roi ds')
    [output_color] = Suppression(lab_roi_a,th,omg);  
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
    lab_roi_adjust = lab_roi;
    lab_roi_a_adjust = imresize(output_color_blend,8,'bicubic');
    lab_roi_adjust(:,:,2) = lab_roi_a_adjust;
    rgb_roi_adjust = lab2rgb(lab_roi_adjust);
    output_adjust = ori_image;
    output_adjust(end-895:end,:,:) = uint8(255*rgb_roi_adjust);
%     output_adjust = uint8(255*rgb_roi_adjust);
    imwrite(output_adjust,processed_name);
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
