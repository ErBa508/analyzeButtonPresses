function [vecAon, vecAoff, vecBon, vecBoff, TC] = lastDuration(vecAon, vecAoff, vecBon, vecBoff, TC, timeMaxTS)

%keyboard

len_TC = length(TC(:,1));
TC(len_TC + 1, 1) = len_TC + 1; % add new index to time course column 1
TC(len_TC + 1, 2) = timeMaxTS; % set last 'press' in column 2 to last frame of time series

% Button A
if (length(vecAon)-length(vecAoff))==1 %end of trial occurred during Aon
    vecAoff(length(vecAoff)+1) = vecAon(length(vecAon) + 1);   % add new index to vecAoff
    TC(len_TC + 1, 3) = 2; % set event label in column 3 to Aoff
else
    if (length(vecAon)~=length(vecAoff)) %if end of trial was during Aoff,
        fprintf('Warning: Aon and Aoff should be of equal length\n')            
    end
end

if min(vecAoff-vecAon)<0
      fprintf('Warning: each AOff event must be after an AOn event\n')  
      diff = vecAoff-vecAon
      disp('difference between vecAon and vecAoff')
end

% Button B
if (length(vecBon)-length(vecBoff))==1
    vecBoff(length(vecBoff)+1)= vecBon(length(vecBon)) + 1; % add new index to vecBoff
    TC(len_TC + 1, 3) = -2; % set event label in column 3 to Boff
else
    if (length(vecBon)~=length(vecBoff))
        fprintf('Warning: Bon and Boff should be of equal length\n')
    end
end

if min(vecBoff-vecBon)<0
      fprintf('Warning: each BOff event must be after an BOn event\n')
      diff = vecBoff-vecBon
      disp('difference between vecBon and vecBoff')
end