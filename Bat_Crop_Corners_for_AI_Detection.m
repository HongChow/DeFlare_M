function Bat_Crop_Corners_for_AI_Detection
   clear
file_path = '/home/hong/Deflare/Python/DATA_FULL/Good/';
%file_path = './TEST6/';
close all;
img_path_list = dir(strcat(file_path,'*.jpg'));
for i=1:length(img_path_list)
    disp('i=');
    disp(i);
    image_name = img_path_list(i).name;
    disp('image_name=');
    disp(image_name);
    image =  imread(strcat(file_path,image_name));   
    ori_image = image;
    [h,w,~]=size(ori_image);   
    if (h<w)
        ori_image = rot90(ori_image);
    end
    left_corner = ori_image(end-899:end,1:900,:);
    right_corner = ori_image(end-899:end,end-899:end,:);
    imwrite(left_corner,strcat('roi_left_',image_name));
    imwrite(right_corner,strcat('roi_right_',image_name));
        
end




end