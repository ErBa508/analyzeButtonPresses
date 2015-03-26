function [timeSeries] = simTimeCourseByPress(TC,FR)

% find time of last button press/release
 timeMaxTC = max(TC(:,2)); 
 
 % make new timeSeries vector with resolution of 120 Hz
 timeSeries = (0:1/FR:timeMaxTC)'; 
 
 % add a second column of zeros to new timeSeries vector
 timeSeries(:,2:3) = zeros(size(timeSeries,1),2);
 
 % make a vector with the indices of (a) press Aon and (b) pressAoff
 indAStart = find(TC(:,3) == 1);
 indAEnd = find(TC(:,3) == 2);
 
 % make a vector with the indices of (a) press Bon and (b) pressBoff
 indBStart = find(TC(:,3) == -1);
 indBEnd = find(TC(:,3) == -2);
 
 % loop through vector of keypress indices to get frames where start  
 % press and end press. Then mark all frames in between as the corresponding
 % press A or B.
 for i = 1: length(indAEnd)
     
     [indAStartVal, indAEndVal] = findPressInd(indAStart,indAEnd, i, TC);
     timeSeries(indAStartVal:indAEndVal, 2) = 1; % use indices to mark when press Aon (col 2)
     
     [indBStartVal, indBEndVal] = findPressInd(indBStart,indBEnd, i, TC);
     timeSeries(indBStartVal:indBEndVal, 3) = 1; % use indices to mark when press Bon (col 3)
 end