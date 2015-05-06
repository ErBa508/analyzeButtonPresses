function [TS] = cleanUpTS(TS)

%keyboard 

% find indices when col 2 (press A) and col 3 (press B) are both pressed
% (== 1)
overlapInd = find(TS(:,2) + TS(:,3) == 2); 

for i = length(overlapInd):-1:1 % loop backward and check NEXT frame after overlap, where possible
    
    % need to check if last overlap of the trial is the last frame of trial
    if i == length(overlapInd)
        
        % if the trial ends with both buttons pressed, look for PREVIOUS
        % non-overlapping frame, and update TS
        if max(overlapInd) == size(TS,1)
            TS = checkPrevious(TS, overlapInd, i);
        
        % else clean-up last overlap as follows
        else
            % if at least one button is pressed following the overlap
            % (e.g., both presses are not equal to 0 in the next frame),
            % use NEXT frame to update TS
            if TS(overlapInd(i) + 1 , 2) == 1 || TS(overlapInd(i) + 1 , 3) == 1
               TS = checkNext(TS, overlapInd, i);
                
            % being cautious, if both presses in the next frame are == 0,
            % check PREVIOUS non-overlapping frame to update TS
            elseif TS(overlapInd(i) + 1 , 2) == 0 || TS(overlapInd(i) + 1 , 3) == 0
                TS = checkPrevious(TS, overlapInd, i);     
            end
        end
        
    % check every overlap other than the last overlap of trial
    else
        % if at least one button is pressed following the overlap
        % (e.g., both presses are not equal to 0 in the next frame),
        % use NEXT frame to update TS
        if TS(overlapInd(i) + 1 , 2) == 1 || TS(overlapInd(i) + 1 , 3) == 1
            TS = checkNext(TS, overlapInd, i);
            
        % being cautious, if both presses in the next frame are == 0, check
        % PREVIOUS non-overlapping frame to update TS
        elseif TS(overlapInd(i) + 1 , 2) == 0 || TS(overlapInd(i) + 1 , 3) == 0
            TS = checkPrevious(TS, overlapInd, i);
        end
    end
    
end

% make sure no remaining overlaps
overlapInd = find(TS(:,2) + TS(:,3) == 2); 
if ~isempty(overlapInd)
    fprintf('Warning: There are overlaps that have not been taken care of\n')
end