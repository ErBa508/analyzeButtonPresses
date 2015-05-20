function [ trialData ] = sepTrials( rawData, filename )
%sepTrials Separate button press data from a subject into separate trials
%   Detailed explanation goes here


% Get only the relevant information (a) timestamp vector and (b) key press
% label vector
sampleData = cat(2, rawData(:,1), rawData(:,5));


% Re-label key press label 1/-1

% ind1 = sampleData(:,2) == 1; % Bon: 1 goes to 1
% sampleData(ind1,2) = 1;

indm1 = sampleData(:,2) == -1; % Boff: -1 goes to 2
sampleData(indm1, 2) = 2;

% Re-label key press label 4/-4

ind4 = sampleData(:,2) == 4; % Aon: 4 goes to -1
sampleData(ind4,2) = -1;

indm4 = sampleData(:,2) == -4; % Aoff: -4 goes to -2
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
   trialData.trial(1,i).params = rawData(1:33, 7 + i); % add trial parameters (@@ if add new parameters will need to change number of rows selected @@)
   trialData.trial(1,i).paramsNames(1:10,1) = {'mheight'; 'mpdist'; 'mvres'; 'framerate'; 'bit_per_pixel'; 'fpsize'; 'aperture_switch'; 'aperturediv'; 'aperture_radius'; 'verthor'};
   trialData.trial(1,i).paramsNames(11:20,1) ={'stereo1'; 'stereo2'; 'speed'; 'time_fxp'; 'forced'; 'eyetracker'; 'randomize_trials'; 'fixationpoint'; 'create_transitions'; 'numtrials'};
   trialData.trial(1,i).paramsNames(21:33,1) ={'mylambda1_deg'; 'duty_cycle1'; 'speed1_deg'; 'orientation1'; 'mylambda2_deg'; 'duty_cycle2'; 'speed2_deg'; 'orientation2'; 'timetrial'; 'mylambda1'; 'speed1'; 'mylambda2'; 'speed2'};
end

end

