function FlarePreJudge_cusums(lab_a)
   [height,width] = size(lab_a);
   v_boundry = 900;
   lab_a_1 = lab_a(end-v_boundry:end,width/2:end);
   lab_a_0 = lab_a(end-v_boundry:end,1:width/2); 
   sum_v0 = sum(lab_a_0,1);
   sum_v1 = sum(lab_a_1,1);
   sum_h0 = sum(lab_a_0,2);
   sum_h1 = sum(lab_a_1,2);
   figure,plot(sum_v0),title('sum_v0');
   figure,plot(sum_v1),title('sum_v1');
   figure,plot(sum_h0),title('sum_h0');
   figure,plot(sum_h1),title('sum_h1');
end