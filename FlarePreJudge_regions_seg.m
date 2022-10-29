function [avg_inner_0,avg_inner_0_seg,avg_inner_1,avg_inner_1_seg,avg_outter_0,avg_outter_1] = FlarePreJudge_regions_seg(lab_a)
   % 0: left bottom
   % 1: right bottom
%    v_boundry = 900;   
   radius_outter = 400; %% 2864 400
   radius_medium = 600; %% 2712 552 792
   radius_inner = 800; %% 2548 716 900
%    lab_a_roi =  lab_a(end-v_boundry:end,:);
   lab_a_roi = lab_a;
   [height,width] = size(lab_a_roi);%3264
%    ROI_0 = lab_a_roi(height-radius_inner:end,1:width/2);
%    ROI_1 = lab_a_roi(height-radius_inner:end,width/2:end);
%    ROI_0 = lab_a_roi(:,1:width/2);
%    ROI_1 = lab_a_roi(:,width/2:end);
%    spline_x = 1:width;
%    spline_y0_inner = spline_x+height-radius_inner;
%    spline_y0_medium = spline_x+height-radius_medium;
%    spline_y0_outter = spline_x+height-radius_outter;
%    spline_y1_inner = -spline_x+height+width-radius_inner;
%    spline_y1_medium = -spline_x+height+width-radius_medium;
%    spline_y1_outter = -spline_x+height+width-radius_outter;
%    figure,imshow(lab_a,[-128,128]);
%    hold on;
%    plot(spline_x, spline_y0_inner, 'b-', 'LineWidth', 1);    
%    plot(spline_x, spline_y0_medium, 'b-', 'LineWidth', 1);    
%    plot(spline_x, spline_y0_outter, 'b-', 'LineWidth', 1);   
%    plot(spline_x, spline_y1_inner, 'b-', 'LineWidth', 1);    
%    plot(spline_x, spline_y1_medium, 'b-', 'LineWidth', 1);    
%    plot(spline_x, spline_y1_outter, 'b-', 'LineWidth', 1);     
   %0
   num_inner_0 = 0;
   num_inner_1 = 0;
   num_outter_0 = 0;
   num_outter_1 = 0;
   region_inner_0 = 0;
   region_inner_1 = 0;
   region_outter_0 = 0;
   region_outter_1 = 0;
%    mask_0 = 
   sum_weights_inner0 = 0;
   sum_weights_inner1 = 0;
   sum_value_0 = 0;
   sum_value_1 = 0;
   for j=height-radius_inner:height-1
       for i=2:width-1
           if j>i+height-radius_outter 
               num_outter_0 = num_outter_0+1;
               region_outter_0 = region_outter_0+lab_a(j,i);
           elseif j>-i+height+width-radius_outter
               num_outter_1 = num_outter_1+1;
               region_outter_1 = region_outter_1+lab_a(j,i);
           elseif j>i+height-radius_inner && j<i+height-radius_medium
               gradient = max(abs(lab_a(j,i-1)-lab_a(j,i+1)),abs(lab_a(j-1,i)-lab_a(j+1,i)));
               sum_weights_inner0 = sum_weights_inner0 + gradient;
               sum_value_0 = gradient*lab_a(j,i) + sum_value_0;
               num_inner_0 = num_inner_0+1;
               region_inner_0 = region_inner_0+lab_a(j,i);
           elseif j>-i+height+width-radius_inner && j<-i+height+width-radius_medium
               gradient = max(abs(lab_a(j,i-1)-lab_a(j,i+1)),abs(lab_a(j-1,i)-lab_a(j+1,i)));
               sum_weights_inner1 = sum_weights_inner1 + gradient;
               sum_value_1 = gradient*lab_a(j,i) + sum_value_1;  
               num_inner_1 = num_inner_1+1;
               region_inner_1 = region_inner_1+lab_a(j,i);
           end
       end
   end
   avg_inner_0 = region_inner_0/num_inner_0;
   avg_inner_1 = region_inner_1/num_inner_1;
   avg_outter_0 = region_outter_0/num_outter_0;
   avg_outter_1 = region_outter_1/num_outter_1;
   disp('avg_inner_0 = ')
   disp(avg_inner_0);
   disp('avg_inner_1 = ')
   disp(avg_inner_1);
   disp('avg_outter_0 = ')
   disp(avg_outter_0)
   disp('avg_outter_1 = ')
   disp(avg_outter_1)
   th0 = sum_value_0/sum_weights_inner0;
   th1 = sum_value_1/sum_weights_inner1;
   num_inner_0_seg = 0;
   region_inner_0_seg = 0;
   num_inner_1_seg = 1;
   region_inner_1_seg = 1;
   for j=height-radius_inner:height-1
       for i=2:width-1
           if j>i+height-radius_inner && j<i+height-radius_medium
               if lab_a(j,i)>th0
                   num_inner_0_seg = num_inner_0_seg+1;
                   region_inner_0_seg = region_inner_0_seg+lab_a(j,i);
               end
           elseif j>-i+height+width-radius_inner && j<-i+height+width-radius_medium
               if lab_a(j,i)>th1
                   num_inner_1_seg = num_inner_1_seg+1;
                   region_inner_1_seg = region_inner_1_seg+lab_a(j,i);
               end             
           end
       end
   end
   avg_inner_0_seg = region_inner_0_seg/num_inner_0_seg;
   avg_inner_1_seg = region_inner_1_seg/num_inner_1_seg;
   disp('avg_inner_0_seg = ')
   disp(avg_inner_0_seg);
   disp('avg_inner_1_seg = ')
   disp(avg_inner_1_seg);  
   
end