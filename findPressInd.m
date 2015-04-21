function [indStart, indEnd] = findPressInd(vecPressOn,vecPressOff, i, ES, FR)

%keyboard

tmp1 = ES(vecPressOn(i),2); % retrieve time of press on
tmp2 = ES(vecPressOff(i),2); % retrieve time of press off
indStart = round(tmp1/(1/FR)); % transform time in sec to frame # (index #)
indEnd = round(tmp2/(1/FR));

