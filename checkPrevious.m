function [ TS ] = checkPrevious( TS, overlapInd, i )
%checkPrevious looks for previous non-overlapping frame
% %   In some situations, an overlap occurs but the next frame does not
% resolve whether press A or press B should be set to zero. This is because
% either (a) the trial ends and there is no next frame, or (b) the next
% frame does not record a button press for either press A or press B (e.g.,
% both bins are set as zero). This function therefore looks for a previous
% non-overlapping frame and if press A was previously set to 1 and press B
% was set to 0, then the overlap will be cleaned-up by setting press A to 0
% and keeping press B as 1.

% find all non-Overlaps
nonOverlap = TS(:,2) + TS(:,3) == 1;

% find the last non-Overlap prior to the current Overlap
ind = find(nonOverlap(1:overlapInd(i),1) == 1, 1, 'last');

% if button A is pressed right prior to the overlap
if TS(ind, 2) == 1 
    TS(overlapInd(i), 2) = 0; % set button A to 0 in the overlap frame
else
    TS(overlapInd(i), 3) = 0; % else set button B to 0 in the overlap frame
end
end

