clear all;
close all;
ori_image = imread('BAD/NEG_011.jpg');
lab = rgb2lab(double(ori_image)/255);
lab_roi = lab(end-900:end,:,:);
lab_roi_a = lab_roi(:,:,2);
th = Gradient_Seg(lab_roi_a);
[output_color] = Suppression(lab_roi_a,th);
lab_roi_adjust = lab_roi;
lab_roi_adjust(:,:,2) = output_color;
rgb_roi_adjust = lab2rgb(lab_roi_adjust);
output_adjust = ori_image;
output_adjust(end-900:end,:,:) = uint8(255*rgb_roi_adjust);
figure,imshow(output_adjust),title('output_adjust_SUB');
% imwrite(output_adjust,'POS_001_adjust.jpg');
% %%
% % input_awb = ori_image;
% % % figure,imshow(ori_image)
% % lab_roi = rgb2lab(double(gauss_roi_awb)/255);
% lab_adjust = lab_roi;
%
omg_l =0.25;
light_mode = 0;
lab_roi_adjust = DeFlareCista_Core_V1(lab_roi,omg_l,light_mode);
% rgb_roi_adjust = lab2rgb(lab_roi_adjust);
% % output_adjust = input_awb;
% output_adjust(end-900:end,:,:) = uint8(255*rgb_roi_adjust);
% figure,imshow(output_adjust),title('output_adjust');
% % % name = 'C8490';
% % % save_name=sprintf('%s_deflare_cista_v1.0_mode_%d_omg_%.2f.bmp',name,light_mode,omg_l);
% % 
figure,imshow(ori_image),title('ori_image');
imwrite(ori_image,'test.bmp');
%%
% imshow(rgb_adjust,'border','tight','initialmagnification','fit');
% set (gcf,'Position',[0,0,500,500]);
% axis normal;
% saveas(gca,'meanshape.bmp','bmp');
% imwrite(uint8(rgb_adjust*255),'1_deflare_cista_omg1.2.bmp');