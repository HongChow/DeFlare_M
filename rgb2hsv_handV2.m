function [HSV] = rgb2hsv_handV2(rgb_in)
   R = rgb_in(:,:,1);
   G = rgb_in(:,:,2);
   B = rgb_in(:,:,3);
   R_ = double(R)./255;
   G_ = double(G)./255;
   B_ = double(B)./255;
   
   r = R_(:); g = G_(:); b = B_(:);
   siz = size(r);
   v = max(max(r,g),b);
   h = zeros(size(v));
   s = (v - min(min(r,g),b));
   
   z = ~s;
   s = s + z;
   k = find(r == v);
   h(k) = (g(k) - b(k))./s(k);
   k = find(g == v);
   h(k) = 2 + (b(k) - r(k))./s(k);
   k = find(b == v);
   h(k) = 4 + (r(k) - g(k))./s(k);
   h = h/6;
   k = find(h < 0);
   h(k) = h(k) + 1;
   h=(~z).*h;
   k = find(v); % v>0 
   s(k) = (~z(k)).*s(k)./v(k);
   s(~v) = 0;
   
   h = reshape(h,siz);
   s = reshape(s,siz);
   v = reshape(v,siz);
   HSV=cat(3,h,s,v);
%
end