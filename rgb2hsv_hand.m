function [Hue, S, V] = rgb2hsv_hand(rgb_in)
   R = rgb_in(:,:,1);
   G = rgb_in(:,:,2);
   B = rgb_in(:,:,3);
   R_ = R/255;
   G_ = G/255;
   B_ = B/255;
   Cmax = max(cat(3,R,G,B),[],3);
   Cmin = min(cat(3,R,G,B),[],3);
   DeltC = Cmax-Cmin;
   % Hue
   Hue = zeros(size(DeltC));
   Hue(DeltC==0)=0;
   Temp_R = 60*(G_-B_)./DeltC;
   Temp_G = 60*((B_-R_)./DeltC+2);
   Temp_B = 60*((R_-G_)./DeltC+4);
   Hue(Cmax==R_)=Temp_R(Cmax==R_);
   Hue(Cmax==G_)=Temp_G(Cmax==G_);
   Hue(Cmax==B_)=Temp_B(Cmax==B_);
   % S
   S = zeros(size(DeltC));
   S(Cmax~=0) = DeltC./Cmax; 
   % V
   V = Cmax;
end