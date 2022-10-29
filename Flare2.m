clear all
close all
% imagename='C8490_Shading_Bright_15fps.raw'; 
imagename='./1.raw'; 
%10 bit raw 
fid = fopen(imagename,'r');
% input = freasd(fid);
row = 3264;
col = 2448;
A=fread(fid,[row col],'uint16=>double');
A=A'; 
max(max(A))
fclose(fid);
% figure,imshow(double(A),[])
img=A;
A_demosaic = demosaic(uint16(img),'bggr');
temp = double(A_demosaic);
final_results = uint8(temp/1023*255);
% imwrite(uint8(final_results),'demosaked_flare_ori1.bmp');
figure,imshow(final_results)
%% ----------- awb -----------%%
D=grayworld(final_results);
final_results_awb(:,:,1) = final_results(:,:,1)*D(1);
final_results_awb(:,:,3) = final_results(:,:,3)*D(3);
final_results_awb(:,:,2) = final_results(:,:,2);
% imwrite(final_results_awb,'2_awb.bmp');
% gauss_final_results_awb = imgaussfilt(final_results_awb,6);
gauss_final_results_awb = final_results_awb;
% gauss_final_results_awb = final_results_awb;
figure,imshow(gauss_final_results_awb);
%% -------- rgb2lab --------- %%
lab = rgb2lab(double(gauss_final_results_awb)/255);
color_a = lab(:,:,2);
color_l = lab(:,:,1);
color_b = lab(:,:,3);
[h,w]=size(color_a);
% color_a_left_bottom = 10*color_a(h/2:end,1:700);
color_a_left_bottom = 10*color_a(:,1:700);
color_b_left_bottom = 10*color_b(h/2:end,1:700);
% color_l_left_bottom = 10*color_l(h/2:end,1:700);
[h_part,w_part]=size(color_a_left_bottom);
color_l_left_bottom = color_l(h/2:end,1:700);
% figure,imshow(color_a_left_bottom,[-128 128]);
% figure,imshow(color_l_left_bottom*2,[0 100]);
% figure,imshow(color_b_left_bottom,[-128 128]);
%%
color_a_left_bottom_1D = color_a_left_bottom(:);
[IDX, C] = kmeans(color_a_left_bottom_1D,2);
bot = min(C);
top = max(C);
th = bot+0.25*(top-bot);
binary_data_a = imbinarize(color_a_left_bottom,th);
bw_binary_a = bwareaopen(binary_data_a,800);
% figure,imshow(color_a_left_bottom,[-128 128])
% figure,imshow(binary_data_a)
figure,imshow(bw_binary_a)
%%
color_b_left_bottom_1D = color_b_left_bottom(:);
[IDX_b, C_b] = kmeans(color_b_left_bottom_1D,2);
bot_b = min(C_b);
top_b = max(C_b);
th_b = bot_b+0.75*(top_b-bot_b);
% bw_b=imbinarize(color_b_left_bottom, 'global');
% figure,imshow(bw_b)
binary_data_b = imbinarize(color_b_left_bottom,th_b);
binary_data_b = not(binary_data_b);
figure,imshow(eroded_binary_b)
%%
% se = strel('line',11,90);
% se = offsetstrel('ball',3,3);
% eroded_binary_b = imerode(255*binary_data_b,se);
% eroded_binary_b = imerode(eroded_binary_b,se);
% figure,imshow(eroded_binary_b)
L = logical(binary_data_b);
s = regionprops(L, 'BoundingBox');
max_id=1;
max_area = 0;
for i=1:size(s)
    if s(i).BoundingBox(3)*s(i).BoundingBox(4)>max_area
        max_id = i;
        max_area = s(i).BoundingBox(3)*s(i).BoundingBox(4);
    end        
end
bw_binary_b = binary_data_b;
for i=1:size(s)
    if i==max_id
        continue;
    else
%         bw_binary_b(int(s(i).BoundingBox(2)):int(s(i).BoundingBox(2))+int(s(i).BoundingBox(4)),int(s(i).BoundingBox(1)):int(s(i).BoundingBox(1))+int(s(i).BoundingBox(3))) = 0;         
        y_min = max(min(h_part,s(i).BoundingBox(2)),1);
        y_max = max(min(h_part,s(i).BoundingBox(2)+s(i).BoundingBox(4)),1);
        x_min =  max(min(h_part,s(i).BoundingBox(1)),1);
        x_max = max(min(h_part,s(i).BoundingBox(1)+s(i).BoundingBox(3)),1);
%         bw_binary_b(s(i).BoundingBox(2):s(i).BoundingBox(2)+s(i).BoundingBox(4),s(i).BoundingBox(1):s(i).BoundingBox(1)+s(i).BoundingBox(3)) = 0;        
        bw_binary_b(y_min:y_max,x_min:x_max)=0;
    end        
end
bw_filled_b = imfill(bw_binary_b,'holes');
figure,imshow(bw_filled_b);

figure,imshow(binary_data_a),rectangle('Position',s(max_id).BoundingBox,'Curvature',[0,0],'LineWidth',2,'LineStyle','--','EdgeColor','r','FaceColor','r');
x_mask = 1;
y_mask = s(max_id).BoundingBox(2);
width = s(max_id).BoundingBox(3);
height = s(max_id).BoundingBox(4);
mask = zeros(size(binary_data_b));
mask(y_mask:end,1:width)=1;
bw_binary_b = mask&binary_data_b;
figure,imshow(bw_binary_b);
figure,imshow(binary_data_a),rectangle('Position',s(1).BoundingBox,'Curvature',[0,0],'LineWidth',2,'LineStyle','--','EdgeColor','r','FaceColor','r');
bw_binary_b = bwareaopen(binary_data_b,800);
bw_filled_b = imfill(bw_binary_b,'holes');
% bw_filled_b = bwmorph(bw_filled_b,'dilate');
% figure,imshow(bw_binary_b)
% figure,imshow(binary_data_b)
figure,imshow(bw_filled_b)
%%
color_l_left_bottom_1D = color_l_left_bottom(:);
[IDX_l, C_l] = kmeans(color_l_left_bottom_1D,2);
% th_l = mean(C_l);
bot_l = min(C_l);
top_l = max(C_l);
th_l = bot_l+0.25*(top_l-bot_l);
binary_data_l = imbinarize(color_l_left_bottom,th_l);
figure,imshow(binary_data_l)
%%
[D,L] = bwdist(binary_data_l);
max_D = max(max(D));
sigma = max_D/4;
gaussian_weights = exp(-D.^2/(sigma^2));
D_2 = D.^2;
gaussian_weights = imresize(gaussian_weights,1/64,'bilinear');
gaussian_weights = imresize(gaussian_weights,[h_part,w_part],'bilinear');
figure,imshow(gaussian_weights)
%%
binary_data = binary_data_a|bw_filled_b|binary_data_l;
[D,L] = bwdist(binary_data);
max_D = max(max(D));
sigma = max_D/4;
gaussian_weights = exp(-D.^2/(sigma^2));
D_2 = D.^2;
gaussian_weights = imresize(gaussian_weights,1/64,'bilinear');
gaussian_weights = imresize(gaussian_weights,[h_part,w_part],'bilinear');
figure,imshow(gaussian_weights)
figure,imshow(binary_data)
binary_data_a = binary_data;
binary_data_b = binary_data;
binary_data_l = binary_data;
%%
binary_data1 = double(binary_data);
binary_data2 = imresize(binary_data1,1/64,'bilinear');
binary_data_double = imresize(binary_data2,[h_part,w_part],'bilinear');
binary_data_opposite = not(binary_data);
edge_valid_mask = double((double(binary_data_opposite).*binary_data_double)>0);
edge_valid_data = edge_valid_mask.*color_a_left_bottom;
bot_valid = sum(edge_valid_data(:))/sum(edge_valid_mask(:));
omg = 0.75;
bot_valid = omg*bot_valid+(1-omg)*bot;
% color_a_left_bottom_temp = 0.25*(color_a_left_bottom-top)+bot_valid;
color_a_left_bottom_temp = 0.00*(color_a_left_bottom-top)+bot;
binary_data_double = gaussian_weights;
color_a_left_bottom_adjust = color_a_left_bottom_temp.*binary_data_double+color_a_left_bottom.*(1-binary_data_double);
figure,imshow(color_a_left_bottom_adjust,[-128 128]);
figure,imshow(color_a_left_bottom,[-128 128]);
%%
binary_data1 = double(binary_data_b);
binary_data2 = imresize(binary_data1,1/32,'bilinear');
binary_data_double = imresize(binary_data2,[h_part,w_part],'bilinear');
binary_data_opposite = not(binary_data_b);
edge_valid_mask = double((double(binary_data_opposite).*binary_data_double)>0);
edge_valid_data = edge_valid_mask.*color_b_left_bottom;
bot_valid = sum(edge_valid_data(:))/sum(edge_valid_mask(:));
omg = 0.5;
bot_valid = omg*bot_valid+(1-omg)*bot_b;
% color_a_left_bottom_temp = 0.25*(color_a_left_bottom-top)+bot_valid;
binary_data_double = gaussian_weights;
color_b_left_bottom_temp = 0.25*(color_b_left_bottom-bot_b)+top_b;
color_b_left_bottom_adjust = color_b_left_bottom_temp.*(binary_data_double)+color_b_left_bottom.*(1-binary_data_double);
figure,imshow(color_b_left_bottom_adjust,[-128 128]);
figure,imshow(color_b_left_bottom,[-128 128]);
%%
binary_data1 = double(binary_data_l);
binary_data2 = imresize(binary_data1,1/64,'bilinear');
binary_data_double = imresize(binary_data2,[h_part,w_part],'bilinear');
figure,imshow(binary_data_double)
binary_data_opposite = not(binary_data_l);
edge_valid_mask = double((double(binary_data_opposite).*binary_data_double)>0);
edge_valid_data = edge_valid_mask.*color_l_left_bottom;
bot_valid = sum(edge_valid_data(:))/sum(edge_valid_mask(:));
omg = 0.5;
bot_valid = omg*bot_valid+(1-omg)*bot_l;
% color_a_left_bottom_temp = 0.25*(color_a_left_bottom-top)+bot_valid;
color_l_left_bottom_temp = 0.75*(color_l_left_bottom-top_l)+bot_l;
color_l_left_bottom_temp = color_l_left_bottom-(1-1./(1+exp(-(-color_l_left_bottom-4.51))))*(top_l-bot_l);
th1=1.4;
map_l = 2*th1*color_l_left_bottom/(bot_l-top_l)+th1-2*th1*bot_l/(bot_l - top_l);
% figure,imshow(map_l)
color_l_left_bottom_suppress_coeff = 1-(1./(1+exp(-map_l)));
color_l_left_bottom_temp = color_l_left_bottom -omg*(top_l-bot_l).*color_l_left_bottom_suppress_coeff;
color_l_left_bottom_adjust = color_l_left_bottom_temp.*binary_data_double+color_l_left_bottom.*(1-binary_data_double);
delt = (top_l-bot_l).*color_l_left_bottom_suppress_coeff;
% figure,imshow(delt),title('delt')
figure,imshow(color_l_left_bottom_suppress_coeff),title('suppress coeff');
% color_l_left_bottom_adjust = color_l_left_bottom_temp.*(binary_data_double)+color_l_left_bottom.*(1-binary_data_double);
figure,imshow(color_l_left_bottom_adjust,[0 100]),title('adjust l');
figure,imshow(color_l_left_bottom,[0 100]),title('before l');
figure,imshow(color_l_left_bottom_temp,[0 100]),title('temp l');
%%
lab_adjust = lab;
color_a_adjust = color_a;
color_b_adjust = color_b;
color_l_adjust = color_l;
color_a_adjust(h/2:end,1:700) = color_a_left_bottom_adjust/10;
lab_adjust(:,:,2) = color_a_adjust;
color_b_adjust(h/2:end,1:700) = color_b_left_bottom_adjust/10;
lab_adjust(:,:,3) = color_b_adjust;
color_l_adjust(h/2:end,1:700) = color_l_left_bottom_adjust;
lab_adjust(:,:,1) = color_l_adjust;
% lab_adjust(:,:,1) = color_l;
rgb_adjust = lab2rgb(lab_adjust);
figure,imshow(rgb_adjust),title('omg 0.5')

% color_l
% [h_roi,w_roi]=size(color_a_left_bottom);
% [X,Y]=meshgrid(1:w_roi,1:h_roi);
% figure,surf(color_a_left_bottom,X,Y);
% color_a_med = medfilt2(color_a);
%%
color_b = lab(:,:,3);
[h,w]=size(color_b);
color_b_left_bottom = 10*color_b(h/2:end,1:w/2);
[h_part,w_part]=size(color_b_left_bottom);
figure,imshow(color_b_left_bottom,[-128 128]);



