jingb1 = imread('jingb1.jpg');
jingb2 = imread('jingb2.jpg');
jingb3 = imread('jingb3.jpg');
jingb4 = imread('jingb4.jpg');
y_jingb1 = rgb2gray(jingb1);
y_jingb2 = rgb2gray(jingb2);
y_jingb3 = rgb2gray(jingb3);
y_jingb4 = rgb2gray(jingb4);
avg = (y_jingb1+y_jingb2+y_jingb3+y_jingb4)/4;
figure,imshow(avg*8),title('lumilance average')
imwrite(uint8(avg*4),'lumilance_average_gain_x4_4.png');
imwrite(uint8(avg*2),'lumilance_average_gain_x2_4.png');
imwrite(uint8(avg*8),'lumilance_average_gain_x8_4.png');