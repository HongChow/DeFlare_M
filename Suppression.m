function [output_color] = Suppression(input_color,th)

%     max_color = max(max(input_color));
%     min_color = min(min(input_color));
% %     top = double((max_color+th))/2;
% %     bot = double((th+min_color))/2;
%     omg_top = 0.25;
%     omg_bot = 0.1;
%     top = double(omg_top*(max_color-th)+th)/2;
%     bot = double(th-omg_bot*(th-min_color))/2;
% %   output_color = zeros(size(input_color));
%     temp_medium = th+2*max_color-3*min_color; 
%     k_medium = (th-min_color)/temp_medium;
%     b_medium = (max_color-min_color)*(th+3*min_color)/(2*temp_medium);
%     keep_color = input_color.*(input_color<(bot+min_color/2));
%     suppression_high = (omg*(input_color-top)+bot).*(input_color>=top);
%     suppression_medium = (k_medium*(input_color)+b_medium).*((input_color<top)&(input_color>=double(bot+min_color)/2));
% %     output_color = input_color.*input_color<(bot+min_color/2);
%     figure,imshow(input_color*10,[-128,128]),title('input_color')
%     figure,imshow(keep_color*10,[-128,128]),title('keep_color')
%     figure,imshow(suppression_high*10,[-128,128]),title('suppression_high')
%     figure,imshow(suppression_medium*10,[-128,128]),title('suppression_medium')
%     output_color = keep_color + suppression_high + suppression_medium;   
%     figure,imshow(output_color,[-128,128]),title('output_color')
%       max_color = max(max(input_color));
     omg = 0.05;
     omg_a = omg;
     suppress_k = omg_a;
     suppress_b = (1-omg_a)*th;
     output_color = (suppress_k*input_color+suppress_b).*(input_color>th)+(input_color).*(input_color<=th);          
%      figure,imshow(output_color*10,[-128,128]),title('output_color')
%      figure,imshow(input_color*10,[-128,128]),title('input_color')
end
