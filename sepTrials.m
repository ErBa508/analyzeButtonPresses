function [ trialData ] = sepTrials( rawData, filename )
%sepTrials Separate button press data from a subject into separate trials
%   Detailed explanation goes here

% Get only the relevant information (a) timestamp vector and (b) key press
% label vector
sampleData = cat(2, rawData(:,1), rawData(:,5));

% Re-label key press label 4/-4 to 2/-2
ind4 = sampleData(:,2) == 4;
sampleData(ind4,2) = 2;

indm4 = sampleData(:,2) == -4;
sampleData(indm4, 2) = -2;

% Find trial start and end
ind8 = find(sampleData(:,2) == 8);
indm8 = find(sampleData(:,2) == -8);

trials = length(ind8);

% Store timestamp/button labels and filename in structure that is split by trial
for i = 1 : trials
   clear countVec
   countVec = (1: indm8(i) - ind8(i) - 1)';
   trialData.trial(1,i).data = cat(2, countVec, sampleData( ind8(i)+1 : indm8(i)-1 , :)); % start at time button pressed, not time trial started
   trialData.trial(1,i).name = strcat(filename, '_trial_', num2str(i)); % add trial number to filename
    
end

end

