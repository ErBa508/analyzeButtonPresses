%% Script to analyze button press data
% Created by Erin, Feb 10, 2015
% Modified from NR analyzeTC.m function


%% Clear workspace

clc
clear all
close all

%% Constant

AnalysisType = 1; %if single file analysis = 1; if batch analysis = 2; if simulation = 3


%% Option (1) SINGLE file analysis

if AnalysisType == 1 
    
    % Select data %
    % use text files that are identical whether using eye tracker or not
    % if eye tracker data are compared, need to determine clock offset to sync data
    
    [filename, pathname] = uigetfile('C:\Users\Erin\Box Sync\UPF\PlaidProj\Data\raw\2013 ButtonPress dat files\*.dat', 'Pick a .dat data file');
    inputData = importdata(strcat(pathname, filename));
    
    % See if data already saved to mat file %
    load('C:\Users\Erin\Box Sync\UPF\PlaidProj\Data\processed\keyPressData\keyData.mat');
    L = length(keyData.subjects);
    
    for i = 1 : L
        fileRepeat(i,1) =  strcmp(keyData.subjects(1,i).name, filename);
    end
    
    % Save data to mat file %
    if sum(fileRepeat) < 1
        keyData.subjects(1, L + 1).name = filename;
        keyData.subjects(1, L + 1).data = inputData;
        save('keyData.mat','keyData');
    end
    
    % Start analysis function %
    [gapOverlap, meanGapOverlap, stdGapOverlap, durA, durB] = analyzePress(inputData, filename);
    
%% Option (2) BATCH analysis    
elseif AnalysisType == 2 %if > 0 then run batch analysis

    load('keyData.mat');
    %load('keyRes.mat');
    
    for i = 1 : length(keyData.subjects)
        clear inputData; clear gapOverlap; % clear data from prev loop
        inputData = keyData.subjects(1,i).data;
        [gapOverlap, meanGapOverlap, stdGapOverlap, durA, durB] = analyzePress(inputData,  keyData.subjects(i).name);
        
        % save key press RESULTS to different .mat file %
        keyRes.subjects(1,i).name = keyData.subjects(1, i).name; %save filename
        keyRes.subjects(1,i).gap = gapOverlap; %save gaps/overlaps values
        keyRes.subjects(1,i).results(1) = meanGapOverlap; %save single val results in results bin
        keyRes.subjects(1,i).results(2) = stdGapOverlap;
        save('keyRes.mat','keyRes');
        
        %pause % to view histogram and plot for each subject
    end
    
end

%% Option (3) SIMULATION

if AnalysisType == 3
    TC1=simTC_wJitter(3500,500,4800,800,600,150,20);
    TC1(:,2)=TC1(:,2)/1000;  
    TC11 = sortData(TC1);
    [TimesA1,TimesB1,histA1,histB1] = analyzeTC(TC1, max(TC1(:,2)), 1);
    
    TC2=simTC_wJitter(2000,1000,4000,1600,200,150,20);
    TC2(:,2)=TC2(:,2)/1000; 
    TC22 = sortData(TC2);
    [TimesA2,TimesB2,histA2,histB2] = analyzeTC(TC2, max(TC2(:,2)), 1);
end

%% POST-PROCESSING %%%%

%% Evaluate group data if real data

if AnalysisType == 1 || AnalysisType == 2
    
    for i = 1 : length(keyData.subjects)
        groupMeanGap(i,1) = keyRes.subjects(1,i).results(1);
        groupMeanStd(i,1) = keyRes.subjects(1,i).results(2);
    end
    
    
    figure
    hist(groupMeanGap)
    str = sprintf('Mean gap time between press for %d subjects with mean gap %.2f \n (a negative # would indicate overlap)', length(groupMeanGap), mean(groupMeanGap));
    title(str)
    figure
    hist(groupMeanStd)
    str2 = sprintf('Standard deviation for gap time for %d subjects with mean SD %.2f', length(groupMeanStd), mean(groupMeanStd));
    title(str2)
    
    % ~ 120 ms gap is the mean, ~ 50 is 1 SD : anything > 220 ms is an 'outlier'
end

%% Evaluate data if simulated

if AnalysisType == 3
    
    
    % find time of last button press
    timeMaxTC1 = max(TC1(:,2)); 
    timeMaxTC2 = max(TC2(:,2));
      
    % make new vector with resolution of 120 Hz
    timeSeriesTC1 = (0:1/120:timeMaxTC1)'; 
    timeSeriesTC2 = (0:1/120:timeMaxTC2)';
    
    % add a second column of zeros
    timeSeriesTC1(:,2:3) = zeros(size(timeSeriesTC1,1),2);
    timeSeriesTC2(:,2:3) = zeros(size(timeSeriesTC2,1),2);
    
    indAStart = find(TC1(:,3) == 1);
    indAEnd = find(TC1(:,3) == 2);
    
    for i = 1: length(indAEnd)
       tmp1 = TC1(indAStart(i),2);
       tmp2 = TC1(indAEnd(i),2);
       indAStart2 = round(tmp1/(1/120));
       indAEnd2 = round(tmp2/(1/120));
       timeSeriesTC1(indAStart2:indAEnd2, 2) = 1; 
    end
    
    figure
    plot(timeSeriesTC1(:,1), timeSeriesTC1(:,2), '.');
    
    % repeat for TC2
    
    % then clean-up data; replace overlaps, leave gaps as 0 for now
    
    % then find(Aon and Bon columns both ~= 0) because that should not
    % happne
    

    
    
    
    
    
    % cross-correlation analysis http://www.mathworks.com/help/signal/ref/xcorr.html#bucjo5f
    [r, lags] = xcorr(TC11(:,1),TC22(:,1));
    [~,I] = max(abs(r)); % find index of row with max correlation coeff
    lagDiff = lags(I); % find lag at that index
    figure
    plot(lags,r)
    
    % correlation
    R = corrcoef(TC11(:,1),TC22(:,1));
    figure
    scatter(TC11(:,1),TC22(:,1), 'r.')
   
end