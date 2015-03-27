function [indStart, indEnd] = findPressInd(vecPressOn,vecPressOff, i, TC, FR)

%keyboard

tmp1 = TC(vecPressOn(i),2); % retrieve time of press on
tmp2 = TC(vecPressOff(i),2); % retrieve time of press off
indStart = round(tmp1/(1/FR)); % transform time in sec to frame # (index #)
indEnd = round(tmp2/(1/FR));

