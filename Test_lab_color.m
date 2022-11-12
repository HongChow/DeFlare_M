fabric = imread('/home/hong/Deflare/Data/flare_dataset/DL/Bad/IMG_20220107_085739_768.jpg'); 
figure,subplot(121),imshow(fabric), xlabel('fabric');  
load regioncoordinates; %下载颜色区域坐标到工作空间
nColors = 6; 
sample_regions = false([size(fabric,1) size(fabric,2) nColors]); 
for count = 1:nColors 
sample_regions(:,:,count) = roipoly(fabric,... 
region_coordinates(:,1,count), ... 
region_coordinates(:,2,count));  %选择每一小块颜色的样本区域
end 
subplot(122),imshow(sample_regions(:,:,2));%显示红色区域的样本
xlabel('sample region for red'); 

cform = makecform('srgb2lab'); %rgb空间转换成L*a*b*空间结构
lab_fabric = applycform(fabric,cform); %rgb空间转换成L*a*b*空间
a = lab_fabric(:,:,2); b = lab_fabric(:,:,3); 
color_markers = zeros([nColors, 2]); %初始化颜色均值
for count = 1:nColors 
color_markers(count,1)= mean2(a(sample_regions(:,:,count))); %a均值

color_markers(count,2)= mean2(b(sample_regions(:,:,count)));%b均值
end 
fprintf(sprintf('[%0.3f,%0.3f]',color_markers(2,1),... 
color_markers(2,2))); 

%[198.183,149.714] 
color_labels = 0: nColors-1; 
a = double(a); b = double(b); 
distance = zeros([size(a), nColors]); %初始化距离矩阵
for count = 1:nColors 
distance(:,:,count) = ( (a - color_markers(count,1)).^2 + ... 
(b - color_markers(count,2)).^2 ).^0.5; %计算到各种颜色的距离
end 
[~, label] = min(distance,[],3); %求出最小距离的颜色
label = color_labels(label);  
 
clear value distance; 
rgb_label = repmat(label,[1 1 3]); 
segmented_images = repmat(uint8(0),[size(fabric), nColors]); 
for count = 1:nColors 
color = fabric; 
color(rgb_label ~= color_labels(count)) = 0; %不是标号颜色的像素置0 
segmented_images(:,:,:,count) = color; 
end 
figure,imshow(segmented_images(:,:,:,1)), xlabel('background'); 
figure,imshow(segmented_images(:,:,:,2)),xlabel('red objects'); 
figure,imshow(segmented_images(:,:,:,3)),xlabel('green objects'); 
figure,imshow(segmented_images(:,:,:,4)),xlabel('purple objects'); 
figure,imshow(segmented_images(:,:,:,5)),xlabel('magenta objects'); 
figure,imshow(segmented_images(:,:,:,6)),xlabel('yellow objects'); %显示红色分量样本的均值


