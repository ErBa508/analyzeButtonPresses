function [relA, relB, meanDurA, meanDurB, RT, altRate] = deriveVars(TS, numSwitches, domDurA, domDurB)
% Derive new variables from time series data
% Input: timeseries
% Output: % time of percept A and B; mean dominance durations of A and B;
% reaction time to first button press (s); alternation rate per sec

% TO-DO - currently includes first epoch (1st dominance duration) - make
% option to not include first epoch

maxVec = length(TS(:,2));

% Relative time of percept A and B
relA = sum(TS(:,2))/maxVec;
relB = sum(TS(:,3))/maxVec;

% Mean dominance duration of each percept
meanDurA = mean(domDurA);
meanDurB = mean(domDurB);

% Reaction time from stimulus onset (in seconds)
indA = find(TS(:,2),1);
indB = find(TS(:,3),1);
RT = TS(min(indA, indB), 1); % 1st button press index is used to find RT

% Alternation rate (in seconds)
altRate = numSwitches/TS(maxVec,1); 
end

