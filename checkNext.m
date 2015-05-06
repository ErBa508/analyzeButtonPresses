function [ TS ] = checkNext( TS, overlapInd, i )
%checkNext looks for the next non-overlapping frame
% %   In most instances, an overlap occurs and we can look at the next
% frame to resolve whether press A or press B should be set to zero. This
% function looks at the next non-overlapping frame, following an overlap.
% If press A is set to 0 and press B is set to 1, in this non-overlapping
% frame, then the overlap will be cleaned-up by setting press A to 0 and
% keeping press B as 1.

% if button A in frame i + 1 == 0
if TS(overlapInd(i) + 1 , 2) == 0
    TS(overlapInd(i), 2) = 0; % button A in frame i should = 0
else
    TS(overlapInd(i), 3) = 0; % else button B in frame i should = 0
end

end

