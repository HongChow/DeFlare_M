function DeFlarePreJudgement(input_awb1,input_awb2,ori_image)
   %%
   input_image_data1 = input_awb1(:,1:1000,:);
   figure,imshow(input_image_data1);
   input_image_data2 = input_awb2(:,1:1000,:);
   figure,imshow(input_image_data2);
%    input_image_data0 = ori_image(:,1:3264/4,:);
   input_image_data0 = ori_image(:,1:1000,:);
   figure,imshow(input_image_data0);
   lab1 = rgb2lab(double(input_image_data1)/255);
   lab2 = rgb2lab(double(input_image_data2)/255);
   lab0 = rgb2lab(double(input_image_data0)/255);
   color_a2 = lab2(:,:,2);
   color_a1 = lab1(:,:,2);
   color_a0 = lab0(:,:,2);
   figure,imshow(color_a0*10,[-128,128])
   figure,imshow(color_a1*10,[-128,128])
   figure,imshow(color_a2*10,[-128,128])
   sum_a0_v = sum(color_a0,1);
   sum_a1_v = sum(color_a1,1);
   sum_a2_v = sum(color_a2,1);
   x_coordinates=1:length(sum_a0_v);
   figure,plot(x_coordinates,sum_a0_v,'r')
   hold on;
   plot(x_coordinates,sum_a1_v,'g')
   hold on;
   plot(x_coordinates,sum_a2_v,'b')
   
   sum_a0_h = sum(color_a0,2);
   sum_a1_h = sum(color_a1,2);
   sum_a2_h = sum(color_a2,2);
   
   y_coordinates=1:length(sum_a0_h);
   figure,plot(y_coordinates,sum_a0_h,'r')
   hold on;
   plot(y_coordinates,sum_a1_h,'g')
   hold on;
   plot(y_coordinates,sum_a2_h,'b')
   
%    sum_a0_v_sample = 
   
   
   
%    windowSize = 5; 
%    b = (1/windowSize)*ones(1,windowSize);
%    a = 1;
%    sum_a0_v_filtered = filter(b,a,sum_a0_v);
%    figure,plot(sum_a0_v_filtered,'r')
%    hold on;
%    figure,plot(x_coordinates,sum_a0_v,'b')
%    
%    
%    guassian_filter = fspecial('gaussian',[1,100],10);
%    sum_a0_v_filtered = conv(sum_a0_v,guassian_filter);
%    figure,plot(sum_a0_v_filtered,'r')
%    hold on;
%    figure,plot(x_coordinates,sum_a0_v,'b')
end
