function [timeSeries] = genTimeSeries(TC,FR)

 % find time of last button press/release
 timeMaxTC = max(TC(:,2)); 
 
 % make new timeSeries vector with resolution of 120 Hz
 timeSeries = (0:1/FR:timeMaxTC)'; 
 timeMaxTS = max(timeSeries(:,1));
 
 % add a second column of zeros to new timeSeries vector
 timeSeries(:,2:3) = zeros(size(timeSeries,1),2);
 
 % make a vector with the indices of (a) press Aon and (b) pressAoff
 indA_ON = find(TC(:,3) == 1);
 indA_OFF = find(TC(:,3) == 2);
 
 % make a vector with the indices of (a) press Bon and (b) pressBoff
 indB_ON = find(TC(:,3) == -1);
 indB_OFF = find(TC(:,3) == -2);
 
 % check whether last button press of trial is still "on"; e.g. was not
 % released when trial ended. This will make lengths of ind_ON vs ind_OFF
 % unequal. We can fix that by adding a dummy "off" press in last frame of
 % the trial (we add this new event to the time course (TC)).
 [indA_ON, indA_OFF, indB_ON, indB_OFF, TC] = lastDuration(indA_ON, indA_OFF, indB_ON, indB_OFF, TC, timeMaxTS);
 
 % loop through vector of keypress indices to get frames where start  
 % press and end press. Then mark all frames in between as the corresponding
 % press A or B.
 for i = 1: length(indA_OFF)
     
     [indAStartVal, indAEndVal] = findPressInd(indA_ON,indA_OFF, i, TC, FR);
     timeSeries(indAStartVal:indAEndVal, 2) = 1; % use indices to mark when press Aon (col 2)
     
     [indBStartVal, indBEndVal] = findPressInd(indB_ON,indB_OFF, i, TC, FR);
     timeSeries(indBStartVal:indBEndVal, 3) = 1; % use indices to mark when press Bon (col 3)
 end
 
 