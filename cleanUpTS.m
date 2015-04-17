function [TS] = cleanUpTS(TS)

%keyboard 

% find indices when col 2 (press A) and col 3 (press B) are both pressed
% (== 1)
overlapInd = find(TS(:,2) + TS(:,3) == 2); 

for i = length(overlapInd):-1:1 % loop backward (forward will not work for consec overlaps)
    
    % if the trial ends with both buttons pressed
    if max(overlapInd) == length(TS) 
        bin = find(TS(:,2) + TS(:,3) == 1, 1, 'last'); % find the last non-overlapping frame
        
        if TS(bin, 2) == 0 % if button A is not pressed right before the overlap
           TS(bin + 1 : length(TS), 3) = 0; % set button B to 0 in the last frames
        else
           TS(bin + 1 : length(TS), 2) = 0; % else set button A to 0 in the last frames
        end
        
    % if the trial ends with only one button pressed
    else
        
        if TS(overlapInd(i) + 1 , 2) == 0 % if button A in frame i + 1 == 0
            TS(overlapInd(i), 2) = 0; % button A in frame i should = 0
        else
            TS(overlapInd(i), 3) = 0; % else button B in frame i should = 0
        end
    end
end

% make sure no remaining overlaps
overlapInd = find(TS(:,2) + TS(:,3) == 2); 
isempty(overlapInd)