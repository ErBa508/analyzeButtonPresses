function [relAtotal, relBtotal, relApress, relBpress, meanDurA, meanDurB, RT, altRate] = deriveVars(TS, numSwitches, domDurA, domDurB, startTime, endTime, FR, motion_dir)
% Derive new variables from time series data
% Input: timeseries
% Output: % time of percept A and B; mean dominance durations of A and B;
% reaction time to first button press (s); alternation rate per sec

% TO-DO - currently includes first epoch (1st dominance duration) - make
% option to not include first epoch
% keyboard

startFrame = round(startTime*FR); % find the frame where trial starts (rounding errors if compare in seconds)
tsFrames = round(TS(:,1) * FR); % convert time series to frames
binStart = find(tsFrames(:,1) == startFrame); % find index where startFrame = tsFrame (note tsStart is startFrame + 1)
binEnd = find(TS(:,1) == endTime);

numFrames = length(TS(binStart:binEnd,2));

% if motion_dir of grating one is negative (moving to left) use col 2 for
% grating one
if motion_dir == -1                              
    numAframes = sum(TS(binStart:binEnd,2));
    numBframes = sum(TS(binStart:binEnd,3));
    
% if motion_dir of grating one is positive (moving to the right) use col 3
% for grating one
elseif motion_dir == 1                                             
    numBframes = sum(TS(binStart:binEnd,2));
    numAframes = sum(TS(binStart:binEnd,3));
end

% Relative time of percept A or B relative to total trial time
relAtotal = numAframes/numFrames;
relBtotal = numBframes/numFrames;

% Relative time of percept A or B relative to duration when key pressed (A + B)
relApress = numAframes/(numAframes + numBframes);
relBpress = numBframes/(numAframes + numBframes);

% Mean dominance duration of each percept
if motion_dir == -1     % see explanation above for numA(B)frames
    meanDurA = mean(domDurA);
    meanDurB = mean(domDurB);
elseif motion_dir == 1
    meanDurB = mean(domDurA);
    meanDurA = mean(domDurB);
end

% Reaction time from stimulus onset (in seconds)
indA = find(TS(binStart:binEnd,2),1) + binStart;
indB = find(TS(binStart:binEnd,3),1) + binStart;
if isempty(indA)
    RT = TS(indB,1) - startTime;
elseif isempty(indB)
    RT = TS(indA,1) - startTime;
else
    RT = TS(min(indA, indB), 1)  - startTime; % 1st button press index is used to find RT
end
% Alternation rate (per minute)
altRate = (numSwitches/TS(numFrames,1))*60;

end

