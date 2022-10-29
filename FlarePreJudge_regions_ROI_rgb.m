function [avg_inner_0,avg_inner_1,avg_outter_0,avg_outter_1] = FlarePreJudge_regions_ROI_rgb(lab_a)
   % 0: left bottom
   % 1: right bottom
%    v_boundry = 900;   
   % --------- the value of alb_a is actually r over g ------------- %
   radius_outter = 344; %% 2864 344--2920 
   radius_medium = 482; %% 2712 482--2782
   radius_inner =  948; %% 2548 662--2602
%    lab_a_roi =  lab_a(end-v_boundry:end,:);
   lab_a_roi = lab_a;
   [height,width] = size(lab_a_roi);%3264
%    ROI_0 = lab_a_roi(height-radius_inner:end,1:width/2);
%    ROI_1 = lab_a_roi(height-radius_inner:end,width/2:end);
%    ROI_0 = lab_a_roi(:,1:width/2);
%    ROI_1 = lab_a_roi(:,width/2:end);
% % %    spline_x = 1:width;
% % %    spline_y0_inner = spline_x+height-radius_inner;
% % %    spline_y_left = -spline_x+height;
% % %    spline_y0_medium = spline_x+height-radius_medium;
% % %    spline_y0_outter = spline_x+height-radius_outter;
% % %    spline_y1_inner = -spline_x+height+width-radius_inner;
% % %    spline_y1_medium = -spline_x+height+width-radius_medium;
% % %    spline_y1_outter = -spline_x+height+width-radius_outter;
% % %    spline_y_right = spline_x+height-width;
% % % 
% % %    figure,imshow(lab_a,[-128,128]);
% % %    hold on;
% % %    plot(spline_x, spline_y0_inner, 'b-', 'LineWidth', 1);    
% % %    plot(spline_x, spline_y0_medium, 'b-', 'LineWidth', 1);    
% % %    plot(spline_x, spline_y0_outter, 'b-', 'LineWidth', 1);   
% % %    plot(spline_x, spline_y1_inner, 'b-', 'LineWidth', 1);    
% % %    plot(spline_x, spline_y1_medium, 'b-', 'LineWidth', 1);    
% % %    plot(spline_x, spline_y1_outter, 'b-', 'LineWidth', 1);    
% % %    plot(spline_x, spline_y_left, 'b-', 'LineWidth', 1);    
% % %    plot(spline_x, spline_y_right, 'b-', 'LineWidth', 1);    
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
   for j=1:height
       for i=1:width
           if j>i+height-radius_outter &&  j>-i+height
               num_outter_0 = num_outter_0+1;
               region_outter_0 = region_outter_0+lab_a(j,i);
           elseif j>-i+height+width-radius_outter && j>i+height-width
               num_outter_1 = num_outter_1+1;
               region_outter_1 = region_outter_1+lab_a(j,i);
           elseif j>i+height-radius_inner && j<i+height-radius_medium && j>-i+height
               num_inner_0 = num_inner_0+1;
               region_inner_0 = region_inner_0+lab_a(j,i);
           elseif j>-i+height+width-radius_inner && j<-i+height+width-radius_medium && j>i+height-width
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
end