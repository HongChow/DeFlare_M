function cista_AWB_Gen(m_nAWBSum,m_nCount,para)



m_bAWB_OneZone=para.m_bAWB_OneZone;
m_bAWB_AVG_ALL=para.m_bAWB_AVG_ALL;
MIN_AWB_CNT=para.MIN_AWB_CNT;


global m_nAWBGain;

[max_cnt,cur_ct]=max(m_nCount(1:3));
if(max_cnt<MIN_AWB_CNT)
cur_ct=0;
end

% if(m_nPrev_CT==1)
% pre_cnt=m_nCount(1);
% elseif(m_nPrev_CT==2)
% pre_cnt=m_nCount(2);
% elseif(m_nPrev_CT==3)
% pre_cnt=m_nCount(3);
% else
% pre_cnt=MIN_AWB_CNT;
% end

if(m_bAWB_AVG_ALL||m_bAWB_OneZone)
new_cnt=m_nCount(4);
elseif(cur_ct==1)
new_cnt=m_nCount(1);
elseif(cur_ct==2)
new_cnt=m_nCount(2);
elseif(cur_ct==3)
new_cnt=m_nCount(3);
else
new_cnt=0;
end

if(new_cnt>MIN_AWB_CNT)		
m_nAWBSum=m_nAWBSum/new_cnt;
max_sum=max(m_nAWBSum);
nGain=max_sum*64./m_nAWBSum;
%m_nAWBGain=(m_nAWBGain+nGain)/2;
m_nAWBGain=nGain;
min_Gain=min(m_nAWBGain);
if(min_Gain>64)
m_nAWBGain=m_nAWBGain*64/min_Gain;
end
end   