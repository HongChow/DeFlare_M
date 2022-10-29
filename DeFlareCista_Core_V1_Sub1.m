function [lab_adjust_roi] = DeFlareCista_Core_V1(lab_roi,omg_l,light_mode)
lab_adjust_roi = lab_roi;
[h_part,w_part,~]=size(lab_roi);
binary_data_l=zeros(h_part,w_part);
binary_data_a=zeros(h_part,w_part);
binary_data_b=zeros(h_part,w_part);
for color_num=1:3
    this_color = lab_roi(:,:,color_num);
    color_this_1D = this_color(:);
    [IDX, C] = kmeans(color_this_1D,2);
    bot = min(C);
    top = max(C);
    if color_num==3
        th = bot+0.75*(top-bot);
    else
        th = bot+0.25*(top-bot);
    end
    binary_data_temp = imbinarize(this_color,th);
    if color_num==3
        binary_data_temp = not(binary_data_temp);
    end
    L = logical(binary_data_temp);
    s = regionprops(L, 'BoundingBox');
    max_id=1;
    max_area = 0;
    for i=1:size(s)
        if s(i).BoundingBox(3)*s(i).BoundingBox(4)>max_area
            max_id = i;
            max_area = s(i).BoundingBox(3)*s(i).BoundingBox(4);
        end        
    end
    bw_binary = binary_data_temp;
    for i=1:size(s)
        if i==max_id
            continue;
        else
            y_min = max(min(h_part,fix(s(i).BoundingBox(2))),1);
            y_max = max(min(h_part,fix(s(i).BoundingBox(2))+fix(s(i).BoundingBox(4))),1);
            x_min = max(min(h_part,fix(s(i).BoundingBox(1))),1);
            x_max = max(min(h_part,fix(s(i).BoundingBox(1))+fix(s(i).BoundingBox(3))),1);
            bw_binary(y_min:y_max,x_min:x_max)=0;
        end
    end
    bw_filled = imfill(bw_binary,'holes');
    [D,L] = bwdist(bw_filled);
    max_D = max(max(D));
    sigma = max_D/4;
    gaussian_weights = exp(-D.^2/(sigma^2));
    gaussian_weights = imresize(gaussian_weights,1/8,'bilinear');
    gaussian_weights = imresize(gaussian_weights,[h_part,w_part],'bilinear');
    switch color_num
        case 1
            binary_data_l = bw_filled;
            gaussian_weights_l = gaussian_weights;
            color_l = this_color;
            top_l = top;
            bot_l = bot;
        case 2
            binary_data_a = bw_filled;
            gaussian_weights_a = gaussian_weights;
            color_a = this_color;
            top_a = top;
            bot_a = bot;
        case 3
            binary_data_b = bw_filled;
            gaussian_weights_b = gaussian_weights;
            color_b = this_color;
            top_b = top;
            bot_b = bot;
    end
   
end
 figure,imshow(binary_data_a),title('binary_ data_ a');
%  figure,imshow(binary_data_l),title('binary_data_l');
% figure,imshow(binary_data_b),title('binary_data_b');
th1=1.4;
omg_a = 0.25;
color_a_temp = omg_a*(color_a-top_a)+bot_a;
color_a_adjust = color_a_temp.*gaussian_weights_a+color_a.*(1-gaussian_weights_a);
figure,imshow(gaussian_weights_a),title('gaussian_ weights_ a');
figure,imshow(color_a_temp*10,[-128 128]),title('color_ a_ temp');
figure,imshow(color_a*10,[-128 128]),title('color_ a');
figure,imshow(color_a_adjust*10,[-128 128]),title('color_ a_ adjust');
omg_b = 0.75;
% sort_b = sort(color_b(:));
% sort_b
% map_l = 2*th1*color_b/(bot_b-top_l)+th1-2*th1*bot_l/(bot_l - top_l);
% figure,imshow(map_l)
% omg_l = 1.25;
% color_l_suppress_coeff = 1-(1./(1+exp(-map_l)));
% color_l_temp = 
% color_l -omg_l*(top_l-bot_l).*color_l_suppress_coeff;

color_b_temp = omg_b*(color_b-bot_b)+top_b;
color_b_adjust = color_b_temp.*gaussian_weights_a+color_b.*(1-gaussian_weights_a); 
figure,imshow(color_b_temp*10,[-128 128]),title('color_b_ temp');
figure,imshow(color_b*10,[-128 128]),title('color_ b');
figure,imshow(color_b_adjust*10,[-128 128]),title('color_ b _adjust');
map_l = 2*th1*color_l/(bot_l-top_l)+th1-2*th1*bot_l/(bot_l - top_l);
% figure,imshow(map_l)
% omg_l = 1.25;
color_l_suppress_coeff = 1-(1./(1+exp(-map_l)));
color_l_temp = color_l -omg_l*(top_l-bot_l).*color_l_suppress_coeff;
if light_mode==1% only use a's mask 
    binary_light = binary_data_a;
else
    binary_light = binary_data_a & binary_data_l;
end
binary_data1 = double(binary_light);
binary_data2 = imresize(binary_data1,1/64,'bilinear');
binary_weights = imresize(binary_data2,[h_part,w_part],'bilinear');
color_l_adjust = color_l_temp.*binary_weights+color_l.*(1-binary_weights);
figure,imshow(color_l_temp*2,[0 100]),title('color_ l_ temp');
figure,imshow(color_l_adjust*2,[0 100]),title('color_ l_ adjust');
figure,imshow(color_l*2,[0 100]),title('color_ l');
lab_adjust_roi(:,:,2) = color_a_adjust;
lab_adjust_roi(:,:,3) = color_b_adjust;
if (light_mode~=0)%2---adjust brightness
     lab_adjust_roi(:,:,1) = color_l_adjust;     
end
end