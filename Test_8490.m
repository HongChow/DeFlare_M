image =  imread('C8490.jpg');
image = fliplr(image);
    ori_image_r = image(:,:,1);
    ori_image_g = image(:,:,2);
    ori_image_b = image(:,:,3);
    ori_image = cat(3,ori_image_r',ori_image_g',ori_image_b');
    imwrite(ori_image,'C8491.jpg');
      figure,imshow(ori_image)
%     figure,imshow(image)
%     ori_image = image;
%   
    %%
    lab = rgb2lab(double(ori_image)/255);
    lab_roi = lab(end-899:end,:,:);
    lab_roi_a = lab_roi(:,:,2);
%     figure,imshow(lab_a*6,[-128,128]),title(processed_name);
%     hold on;
    [height,width,~] = size(ori_image);
    rgb_roi = ori_image(end-900:end,:,:);
    x0 = width/2;
    a = 0;
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
    blend_mask = imresize(blend_mask,1/8,'bilinear');
    blend_mask = imresize(blend_mask,[900,width],'bilinear');
    figure,imshow(blend_mask)
    output_color_blend = output_color.*(blend_mask)+lab_roi_a.*(1-blend_mask);
    lab_roi_adjust = lab_roi;
    lab_roi_adjust(:,:,2) = output_color_blend;
    rgb_roi_adjust = lab2rgb(lab_roi_adjust);
    output_adjust = ori_image;
    output_adjust(end-899:end,:,:) = uint8(255*rgb_roi_adjust);
    figure,imshow(output_adjust);
%     figure,imshow(blend_mask)        
%     figure,imshow(rgb_roi),title('roi');
    hold on;    
    plot(pline_x, pline_y1+(height-900), 'b-', 'LineWidth', 1);    
    plot(pline_x, pline_y2+(height-900), 'b-', 'LineWidth', 1);    
%     plot(pline_x, pline_y, 'b-', 'LineWidth', 3);
%     plot(pline_y,pline_x, 'b-', 'LineWidth', 3);
    impixelinfo;