function [m_nAWBSum m_nCount]=cista_AWB_statistics(raw_img,para)
height=size(raw_img,1);
width=size(raw_img,2);

cwf_x0=para.cwf_x0; cwf_y0=para.cwf_y0; cwf_R=para.cwf_R;
alx_k=para.alx_k;alx_dy=para.alx_dy;alx_x_left=para.alx_x_left;alx_x_right=para.alx_x_right;
day_k=para.day_k;day_dx=para.day_dx;day_y_top=para.day_y_top;day_y_bot=para.day_y_bot;
m_nBLC=para.m_nBLC;
m_nLimit_L=para.m_nLimit_L;
m_nLimit_H=para.m_nLimit_H;
m_bAWB_OneZone=para.m_bAWB_OneZone;
m_bAWB_AVG_ALL=para.m_bAWB_AVG_ALL;

cwf_x0=double(cwf_x0);cwf_y0=double(cwf_y0);cwf_R=double(cwf_R);
alx_k=double(alx_k);alx_dy=double(alx_dy);alx_x_left=double(alx_x_left);alx_x_right=double(alx_x_right);
day_k=double(day_k);day_dx=double(day_dx);day_y_top=double(day_y_top);day_y_bot=double(day_y_bot);


%%
%XY plot
figure;
xlim([0 1.5*64]); ylim([0 1.5*64]);
%%


global m_nPrev_CT 

m_nAWBSum=zeros(4,1);
m_nCount=zeros(4,1);

for i=1:10:height
    for j=1:10:width
        nR=raw_img(i,j,1);
        nGr=raw_img(i,j,2);
        nGb=raw_img(i,j,2);
        nB=raw_img(i,j,3);
        
        nR = ((nR-m_nBLC));
        nGr = ((nGr-m_nBLC));
        nGb = ((nGb-m_nBLC));
        nB = ((nB-m_nBLC));
        nG = (nGb+nGr)/2;
    
        if((nB>m_nLimit_L) && (nB<m_nLimit_H) &&...
           (nGr>m_nLimit_L) &&(nGr<m_nLimit_H) &&...
           (nGb>m_nLimit_L) &&(nGb<m_nLimit_H) &&...
           (nR>m_nLimit_L) &&(nR<m_nLimit_H))
            

            x=(nR*(2^6))/nG;%(R/G B/G)
            y=(nB*(2^6))/nG;
	        
            if(x>255);x=255;end
            if(y>255);y=255;end

            dx0=x-cwf_x0;
            dy0=y-cwf_y0;

            dy=dy0-((alx_k*dx0)/(2^7));
            dx=dx0-((day_k*dy0)/(2^7));

           	if(dy<0);dy=-dy;end	
            if(dy>255);dy=255;end
            if(dx<0);dx=-dx;end	
            if(dx>255);dx=255; end
            
            in_yx = (dy <= alx_dy);
            in_xy = (dx <= day_dx); 
            in_cwf =((dx0<cwf_R&&dx0>-cwf_R) && (dy0<cwf_R&&dy0>-cwf_R))|| (in_yx && x < alx_x_left && x > cwf_x0) || (in_xy && y < day_y_bot && y > cwf_y0);
            
            in_a = in_yx && (x <alx_x_right ) && (x > alx_x_left);
            in_day = in_xy && (y < day_y_top) && (y > day_y_bot);
            
            
            sum_en=false;
            
            if (m_bAWB_AVG_ALL); sum_en=true;end
            
            plot(x,y,'k.');hold on
            
            if (in_cwf) 
            plot(x,y,'g.');hold on
                
            m_nCount(1)=m_nCount(1)+1;
                %if((m_nPrev_CT==1)||m_bAWB_OneZone)
                 if((m_nPrev_CT==1))
                sum_en = true;
                end
            end
            
            if (in_day) 
            plot(x,y,'b.');hold on
            m_nCount(2)=m_nCount(2)+1;
                %if((m_nPrev_CT==2)||m_bAWB_OneZone)
                if((m_nPrev_CT==2))
                sum_en = true;
                end
            end 
            
            if (in_a) 
            plot(x,y,'r.');hold on
            m_nCount(3)=m_nCount(3)+1;
                %if((m_nPrev_CT==3)||m_bAWB_OneZone)
                if((m_nPrev_CT==3))
                sum_en = true;
                end
            end 
            
           if((m_bAWB_OneZone && (in_cwf || in_day ||in_a))||m_bAWB_AVG_ALL)
           m_nCount(4)=m_nCount(4)+1;
           sum_en = true;
           end
           
           if (sum_en) 
            m_nAWBSum(1)=m_nAWBSum(1)+nR;
            m_nAWBSum(2)=m_nAWBSum(2)+nGr;
            m_nAWBSum(3)=m_nAWBSum(3)+nGb;
            m_nAWBSum(4)=m_nAWBSum(4)+nB;
           end

            
        end 
        
    end
end


%% xy diagram for debug

plot(cwf_x0,cwf_y0,'go','MarkerSize',8); hold on

% plot the slope
yy=cwf_y0:0.01*64:2*64;
day_xx=day_k/(2^7)*yy+cwf_x0-day_k/(2^7)*cwf_y0;
plot(day_xx,yy,'k--'); hold on

xx=cwf_x0:0.01*64:2*64;
alx_yy=alx_k/(2^7)*xx+cwf_y0-alx_k/(2^7)*cwf_x0;
plot(xx,alx_yy,'k--'); hold on
xlim([0 1.8*64]); ylim([0 1.8*64]);

% plot the cwf circle 
th = 0:pi/50:2*pi;
xunit = cwf_R * cos(th) +cwf_x0;
yunit = cwf_R * sin(th) + cwf_y0;
h = plot(xunit, yunit,'g'); hold on
axis square

% plot the boudary line of ALX Zone
alx_xx=alx_x_left:0.01*64:alx_x_right;
alx_dy_1_line=alx_k/(2^7)*alx_xx+(cwf_y0-alx_k/(2^7)*cwf_x0+alx_dy);
alx_dy_2_line=alx_k/(2^7)*alx_xx+(cwf_y0-alx_k/(2^7)*cwf_x0-alx_dy);
plot(alx_xx,alx_dy_1_line,'r--',alx_xx,alx_dy_2_line,'r--','LineWidth',1); hold on

% Left and Right of ALX Zone
temp_y1=alx_k/(2^7)*alx_x_left+(cwf_y0-alx_k/(2^7)*cwf_x0+alx_dy);
temp_y2=alx_k/(2^7)*alx_x_left+(cwf_y0-alx_k/(2^7)*cwf_x0-alx_dy);
plot([alx_x_left ,alx_x_left] ,[temp_y1,temp_y2],'r--','LineWidth',1); hold on

temp_y1=alx_k/(2^7)*alx_x_right+(cwf_y0-alx_k/(2^7)*cwf_x0+alx_dy);
temp_y2=alx_k/(2^7)*alx_x_right+(cwf_y0-alx_k/(2^7)*cwf_x0-alx_dy);
plot([alx_x_right ,alx_x_right] ,[temp_y1,temp_y2],'r--','LineWidth',1);hold on

% plot the boudary line of DAY zone
day_yy=day_y_bot:0.01*64:day_y_top;
day_dx_1_line=day_k/(2^7)*day_yy+(cwf_x0-day_k/(2^7)*cwf_y0+day_dx);
day_dx_2_line=day_k/(2^7)*day_yy+(cwf_x0-day_k/(2^7)*cwf_y0-day_dx);
plot(day_dx_1_line,day_yy,'b--',day_dx_2_line,day_yy,'b--','LineWidth',1); hold on

% top and bottom of DAY Zone
temp_x1=day_k/(2^7)*day_y_top+(cwf_x0-day_k/(2^7)*cwf_y0+day_dx);
temp_x2=day_k/(2^7)*day_y_top+(cwf_x0-day_k/(2^7)*cwf_y0-day_dx);
plot([temp_x1,temp_x2] ,[day_y_top,day_y_top],'b--','LineWidth',1); hold on

temp_x1=day_k/(2^7)*day_y_bot+(cwf_x0-day_k/(2^7)*cwf_y0+day_dx);
temp_x2=day_k/(2^7)*day_y_bot+(cwf_x0-day_k/(2^7)*cwf_y0-day_dx);
plot([temp_x1,temp_x2] ,[day_y_bot,day_y_bot],'b--','LineWidth',1); 