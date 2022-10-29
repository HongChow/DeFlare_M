% clear all;
% close all;
% imagename='C8490_Shading_Bright_15fps.raw'; 
imagename='./2.raw'; 
%10 bit raw 
fid = fopen(imagename,'r');
% input = freasd(fid);
row = 3264;
col = 2448;
A=fread(fid,[row col],'uint16=>double');
A=A'; 
fclose(fid);
figure,imshow(double(A),[])
img=A;
A_demosaic = demosaic(uint16(img),'bggr');
temp = double(A_demosaic);
temp_results = uint8(temp/1023*255);
% imwrite(uint8(final_results),'demosaked_flare_ori1.bmp');
figure,imshow(temp_results)
%% ----------- awb -----------%%

D=grayworld(temp_results);
input_awb(:,:,1) = temp_results(:,:,1)*D(1);
input_awb(:,:,3) = temp_results(:,:,3)*D(3);
input_awb(:,:,2) = temp_results(:,:,2);
% imwrite(final_results_awb,'2_awb.bmp');
gauss_final_results_awb = imgaussfilt(input_awb,6);
% gauss_final_results_awb = gauss_final_results_awb;
input_awb_roi = gauss_final_results_awb(:,1:700,:);
gauss_roi_awb = input_awb_roi; 
% gauss_roi_awb = imgaussfilt(input_awb_roi,6);
figure,imshow(input_awb);
%% --------- rgb2lab --------- %%
% lab = rgb2lab(double(gauss_final_results_awb)/255);
% [h,w,~]=size(lab);
% lab_roi = lab(h/2:end,1:700,:);
% lab_adjust = lab;
% lab_roi_adjust = DeFlareCista_Core_V1(lab_roi);
% lab_adjust(h/2:end,1:700,:) = lab_roi_adjust;
% % rgb_adjust = lab2rgb(lab_adjust);
% lab_roi = lab(1:h/2,1:700,:);
% lab_roi_adjust = DeFlareCista_Core_V1(lab_roi);
% lab_adjust(1:h/2,1:700,:) = lab_roi_adjust;
% rgb_adjust = lab2rgb(lab_adjust);
% figure,imshow(rgb_adjust),title('omg 0.5')
%%
% figure,imshow(ori_image)
close all;
lab_roi = rgb2lab(double(gauss_roi_awb)/255);
%%
omg_l =0.75;
light_mode = 1;
lab_roi_adjust = DeFlareCista_Core_V1(lab_roi,omg_l,light_mode);
rgb_roi_adjust = lab2rgb(lab_roi_adjust);
output_adjust = input_awb;
output_adjust(:,1:700,:) = uint8(255*rgb_roi_adjust);
name = '2';
save_name=sprintf('%s_deflare_cista_v1.0_mode_%d_omg_%.2f.bmp',name,light_mode,omg_l);
figure,imshow(output_adjust),title(save_name);
% imwrite(output_adjust,save_name);
%%
clear all;
close all;
ori_image = imread('C8490.jpg');
lab = rgb2lab(double(ori_image)/255);
lab_roi = lab(:,1:900,:);
%%
input_awb = ori_image;
% figure,imshow(ori_image)
% lab_roi = rgb2lab(double(gauss_roi_awb)/255);
lab_adjust = lab_roi;
omg_l =0.25;
light_mode = 0;
lab_roi_adjust = DeFlareCista_Core_V1(lab_roi,omg_l,light_mode);
rgb_roi_adjust = lab2rgb(lab_roi_adjust);
output_adjust = input_awb;
output_adjust(:,1:900,:) = uint8(255*rgb_roi_adjust);
name = 'C8490';
save_name=sprintf('%s_deflare_cista_v1.0_mode_%d_omg_%.2f.bmp',name,light_mode,omg_l);
figure,imshow(output_adjust),title('output_adjust');
imwrite(output_adjust,save_name);
%%
% imshow(rgb_adjust,'border','tight','initialmagnification','fit');
% set (gcf,'Position',[0,0,500,500]);
% axis normal;
% saveas(gca,'meanshape.bmp','bmp');
% imwrite(uint8(rgb_adjust*255),'1_deflare_cista_omg1.2.bmp');