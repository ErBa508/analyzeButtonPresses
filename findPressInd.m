function [indStart, indEnd] = findPressInd(vecStart,vecEnd, i, TC1)

tmp1 = TC1(vecStart(i),2); % retrieve time of press on
tmp2 = TC1(vecEnd(i),2); % retrieve time of press off
indStart = round(tmp1/(1/120)); % transform time in sec to frame # (index #)
indEnd = round(tmp2/(1/120));