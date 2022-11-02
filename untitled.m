clear
file_path = './CR_HSV_0.125/';
close all;
img_path_list = dir(strcat(file_path,'*.jpg'));
for i=1:length(img_path_list)
    disp('i=');
    disp(i);
    image_name = img_path_list(i).name;
    disp('image_name=');
    disp(image_name);
    processed_name = sprintf('_%s',image_name);
    disp(processed_name);
    image =  imread(strcat(file_path,image_name));
    left_roi = image(end-1000:end,1:1000,:);
    right_roi = image(end-1000:end,end-1000:end,:);
    left_name =  sprintf('left_HSVcr_%s',image_name);
    right_name =  sprintf('right_HSVcr_%s',image_name);
    imwrite(left_roi,left_name);
    imwrite(right_roi,right_name);
end