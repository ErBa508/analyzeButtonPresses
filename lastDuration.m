function [vecAon, vecAoff, vecBon, vecBoff] = lastDuration(vecAon, vecAoff, vecBon, vecBoff, Tmax, epsilon)


% Button A
if (length(vecAon)-length(vecAoff))==1 %end of trial occurred during Aon
    vecAoff(length(vecAoff)+1)=Tmax-epsilon;   % to use find(t(..)=f(epsilon)) etc
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
    vecBoff(length(vecBoff)+1)=Tmax-epsilon;
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