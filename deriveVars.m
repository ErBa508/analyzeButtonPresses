function [relA, relB, meanDurA, meanDurB, RT, altRate] = deriveVars(TS, numSwitches, domDurA, domDurB, startTime, endTime)
% Derive new variables from time series data
% Input: timeseries
% Output: % time of percept A and B; mean dominance durations of A and B;
% reaction time to first button press (s); alternation rate per sec

% TO-DO - currently includes first epoch (1st dominance duration) - make
% option to not include first epoch
keyboard

binStart = find(TS(:,1) == startTime);
binEnd = find(TS(:,1) == endTime);

numFrames = length(TS(binStart:binEnd,2));

% Relative time of percept A and B
relA = sum(TS(binStart:binEnd,2))/numFrames;
relB = sum(TS(binStart:binEnd,3))/numFrames;

% Mean dominance duration of each percept
meanDurA = mean(domDurA);
meanDurB = mean(domDurB);

% Reaction time from stimulus onset (in seconds)
indA = find(TS(binStart:binEnd,2),1);
indB = find(TS(binStart:binEnd,3),1);
RT = TS(min(indA, indB), 1)  - startTime; % 1st button press index is used to find RT

% Alternation rate (per minute)
altRate = (numSwitches/TS(numFrames,1))*60;

end

