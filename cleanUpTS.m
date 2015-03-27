function [TS] = cleanUpTS(TS)

% find indices when col 2 (press A) and col 3 (press B) are both pressed
% (== 1)
overlapInd = find(TS(:,2) + TS(:,3) == 2); 

for i = length(overlapInd):-1:1 % loop backward (forward will not work for consec overlaps)
    if TS(overlapInd(i) + 1 , 2) == 0 % if button A in frame i + 1 == 0
        TS(overlapInd(i), 2) = 0; % button A in frame i should = 0
    else
        TS(overlapInd(i), 3) = 0; % else button B in frame i should = 0
    end
end

% make sure no remaining overlaps
overlapInd = find(TS(:,2) + TS(:,3) == 2); 
isempty(overlapInd)