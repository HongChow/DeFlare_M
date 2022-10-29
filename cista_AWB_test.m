%% AWB based on Zone statistics
%
clear all
close all


%% load the parameter/registers
load awb_para; %from the calibration
awb_para.m_nBLC=0;% BlC offset: 10bits
awb_para.m_nLimit_L=16;% 
awb_para.m_nLimit_H=960;%10bits
awb_para.m_bAWB_OneZone=true;
awb_para.m_bAWB_AVG_ALL=false;
awb_para.MIN_AWB_CNT=256;
% 
% 


 %%		parameters from CU
 global m_nAWBGain  m_nPrev_CT m_nCurr_CT m_nCT_Count  
        
        m_nAWBGain(1)=64;m_nAWBGain(2)=64;m_nAWBGain(3)=64;m_nAWBGain(4)=64;
        m_nPrev_CT=0;
		m_nCurr_CT=0;
        m_nCT_Count=0;
        

 %% AWB statistic and Estimate AWB Gain
 %first frame
raw_img=imread('\images\day_cc.bmp');
figure;imshow(raw_img);
raw_img=double(raw_img)/255*1023;%10 bits
[m_nAWBSum m_nCount]=cista_AWB_statistics(raw_img,awb_para);
cista_AWB_Gen(m_nAWBSum,m_nCount,awb_para);% output are AWB GAIN: m_nAWBGain

%% Apply the white balance gain
% 
rgb_img(:,:,1)=(raw_img(:,:,1)-awb_para.m_nBLC)*m_nAWBGain(1)/64;
rgb_img(:,:,2)=(raw_img(:,:,2)-awb_para.m_nBLC)*(m_nAWBGain(2)+m_nAWBGain(3))/2/64;
rgb_img(:,:,3)=(raw_img(:,:,3)-awb_para.m_nBLC)*m_nAWBGain(4)/64;
figure;
imshow(rgb_img/1023);
%% gray world method 
mean_r=mean(raw_img(:,:,1)-awb_para.m_nBLC);
mean_g=mean(raw_img(:,:,2)-awb_para.m_nBLC);
mean_b=mean(raw_img(:,:,3)-awb_para.m_nBLC);
gw_gain(1)=mean_g/mean_r*64;
gw_gain(2)=1*64;
gw_gain(3)=mean_g/mean_b*64;
gw_rgb_img(:,:,1)=(raw_img(:,:,1)-awb_para.m_nBLC)*gw_gain(1)/64;
gw_rgb_img(:,:,2)=(raw_img(:,:,2)-awb_para.m_nBLC)*gw_gain(2)/64;
gw_rgb_img(:,:,3)=(raw_img(:,:,3)-awb_para.m_nBLC)*gw_gain(3)/64;
figure;
imshow(gw_rgb_img/1023);