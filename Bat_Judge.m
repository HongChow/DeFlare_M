
% file_path = './Bad_Data/';
% all_dis_lab_neg = [];

% 
file_path = './Good_Data/';
all_dis_lab_pos = [];

% 
img_path_list = dir(strcat(file_path,'*.jpg'));
% P0_all_BAD =  zeros(1,length(img_path_list));
% P1_all_BAD =  zeros(1,length(img_path_list));

for i=1:length(img_path_list)
    disp('i=');
    disp(i);
    image_name = img_path_list(i).name;
    disp('image_name=');
    disp(image_name);
    processed_name = sprintf("roi_pre_%s",image_name);
    disp(processed_name)
    image =  imread(strcat(file_path,image_name));
%       figure,imshow(image);
    ori_image = image;
    [height,width,~] = size(ori_image);%3264
    lab = rgb2lab(double(ori_image)/255);
%     figure,imshow(lab)
    lab_a = lab(:,:,2);   
%     lab_roi = lab(end-999:end,:,:);
%     lab_roi_a = lab_roi(:,:,2);
%     [avg_inner_0,avg_inner_0_seg,avg_inner_1,avg_inner_1_seg,avg_outter_0,avg_outter_1] = FlarePreJudge_regions_seg(lab_a);    
%     [avg_inner_0,avg_inner_1,avg_outter_0,avg_outter_1] = FlarePreJudge_regions_ROI_seg(lab_a);    
    [avg_inner_0,avg_inner_1,avg_outter_0,avg_outter_1] = FlarePreJudge_regions_ROI(lab_a);    
%     p0 = (avg_outter_0-avg_inner_0)/avg_inner_0;
%     p1 = (avg_outter_1-avg_inner_1)/avg_inner_1;
%     P0_all_BAD(i) = p0;
%     P1_all_BAD(i) = p1;
     delt0 = avg_outter_0 - avg_inner_0;
     delt1 = avg_outter_1 - avg_inner_1;
     all_dis_lab_pos = [all_dis_lab_pos delt0];
     all_dis_lab_pos = [all_dis_lab_pos delt1];
%      if delt0>3 
%          flag0 = 'True';
%      else
%          flag0 = 'False';
%      end
%      if delt1>3 
%          flag1 = 'True';
%      else
%          flag1 = 'False';
%      end
% %     text_str0 = ['inner0:   ' num2str(avg_inner_0,'%0.2f') '  inner0_seg:   ' num2str(avg_inner_0_seg,'%0.2f')   ' outter0:    ' num2str(avg_outter_0,'%0.2f') '  inner1:    ' num2str(avg_inner_1,'%0.2f')    '  inner1_seg:  '     num2str(avg_inner_1_seg,'%0.2f')   '    outter1:  '    num2str(avg_outter_1,'%0.2f')];
%     text_str0 = ['p0='  num2str(delt0,'%0.2f')  'p1='  num2str(delt1,'%0.2f')   'inner0:   ' num2str(avg_inner_0,'%0.2f')  ' outter0:    ' num2str(avg_outter_0,'%0.2f') '  inner1:    ' num2str(avg_inner_1,'%0.2f')   '  outter1:  '    num2str(avg_outter_1,'%0.2f')];
% %    text_str0 = ['flag0=' flag0  ' flag1='  flag1];
%     
% %     text_str1 = ['inner1:' num2str(avg_inner_1,'%0.2f') 'outter1:' num2str(avg_outter_1,'%0.2f')];
%     position0 = [5 10];
% %     position1 = [width/2 10];
%     image_show = insertText(image,position0,text_str0,'FontSize',48,'BoxColor','r','BoxOpacity',0.4,'TextColor','white');
% % %     image_show = insertText(image,position1,text_str1,'FontSize',48,'BoxColor','r','BoxOpacity',0.4,'TextColor','white');
%     imwrite(image_show,processed_name);
% %     figure,imshow(image_show);

end  
