% plot dis%
% all_dis_lab_neg = all_dis;

% 
% x = 1:length(all_dis_lab_neg);
% figure(2);scatter(x,all_dis_lab_neg);


% x2 = 1:length(all_dis_lab_ps);
% hold on;
% scatter(x2,all_dis_lab_ps);

% x = 1:length(all_dis_rgb_neg);
% figure(2);scatter(x,all_dis_rgb_neg);

%---------- YCbCr ---------- %
figure(1);title('Ycbcr-Domain');
x1 = 1:length(all_dis_ycbcr_neg);
scatter(x1,all_dis_ycbcr_neg,'r');

hold on;
x2 = 1:length(all_dis_ycbcr_pos);
scatter(x2,all_dis_ycbcr_pos,'g');

% -------- rgb ------------ %
figure(2);title('rgb-Domain')
x1 = 1:length(all_dis_rgb_pos);
scatter(x1,all_dis_rgb_pos,'g');
hold on;
x2 = 1:length(all_dis_rgb_neg);
scatter(x2,all_dis_rgb_neg,'r');



% ---------- lab ------------ %
figure(3);title('Lab-Domain')
x1 = 1:length(all_dis_lab_neg);
scatter(x1,all_dis_lab_neg,'r');
hold on;
x2 = 1:length(all_dis_lab_pos);
scatter(x2,all_dis_lab_pos,'g');

%% ---------- hsv ------------ %
figure(4);title('HSV-Domain')
x1 = 1:length(all_dis_hsv_neg);
scatter(x1,all_dis_hsv_neg,'r');
hold on;
x2 = 1:length(all_dis_hsv_pos);
scatter(x2,all_dis_hsv_pos,'g');

