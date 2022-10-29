%clear all
file_path = '.\Bad_Data\';
%close all;
ori_image = imread('./Bad_Data/IMG_20220107_094033_802.jpg');
    [height,width] = size(ori_image);%3264
    lab = rgb2lab(double(ori_image)/255);
%     figure,imshow(lab)
    lab_a = lab(:,:,2);   
%     lab_roi = lab(end-999:end,:,:);
%     lab_roi_a = lab_roi(:,:,2);
%     [avg_inner_0,avg_inner_0_seg,avg_inner_1,avg_inner_1_seg,avg_outter_0,avg_outter_1] = FlarePreJudge_regions_seg(lab_a);    
%     text_str0 = ['inner0:   ' num2str(avg_inner_0,'%0.2f') '  inner0_seg:   ' num2str(avg_inner_0_seg,'%0.2f')   ' outter0:    ' num2str(avg_outter_0,'%0.2f') '  inner1:    ' num2str(avg_inner_1,'%0.2f')    '  inner1_seg:  '     num2str(avg_inner_1_seg,'%0.2f')   '    outter1:  '    num2str(avg_outter_1,'%0.2f')];
%     text_str1 = ['inner1:' num2str(avg_inner_1,'%0.2f') 'outter1:' num2str(avg_outter_1,'%0.2f')];
figure,imshow(lab_a*10,[-128 128]),title('color_ a');
    [avg_inner_0,avg_inner_1,avg_outter_0,avg_outter_1] = FlarePreJudge_regions_ROI(lab_a);  
% [avg_inner_0,avg_inner_1,avg_outter_0,avg_outter_1] = FlarePreJudge_regions_ROI_seg(lab_a);  
    text_str0 = ['inner0:   ' num2str(avg_inner_0,'%0.2f')  ' outter0:    ' num2str(avg_outter_0,'%0.2f') '  inner1:    ' num2str(avg_inner_1,'%0.2f')   '  outter1:  '    num2str(avg_outter_1,'%0.2f')];
    position0 = [5 10];
%     position1 = [width/2 10];
    image_show = insertText(ori_image,position0,text_str0,'FontSize',48,'BoxColor','r','BoxOpacity',0.4,'TextColor','white');
% %     image_show = insertText(image,position1,text_str1,'FontSize',48,'BoxColor','r','BoxOpacity',0.4,'TextColor','white');
%     imwrite(image_show,processed_name);
    figure,imshow(image_show);

