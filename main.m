%% Script to analyze button press data
% Created by Erin, Feb 10, 2015
% Modified from NR analyzeTC.m function


%%%%%%%%%%%%%%%%%%%%%
%% Clear workspace %%
%%%%%%%%%%%%%%%%%%%%%

clc
clear all
close all



%%%%%%%%%%%%%%%
%% CONSTANTS %%
%%%%%%%%%%%%%%%

AnalysisType = 2; %if single file analysis = 1; if batch analysis = 2; if simulation = 3

FR = 120; % frame rate

plot_yn = 1; % if want to see summary plots (1 if yes, 0 if no)



%%%%%%%%%%%%%%
%% GET DATA %%
%%%%%%%%%%%%%%

if AnalysisType == 1
    %%%%%%%%%%%%%%%%%%%
    %%% Select data %%%
    %%%%%%%%%%%%%%%%%%%
    
    [filename, pathname] = uigetfile('C:\Users\Erin\Box Sync\UPF\PlaidProj\Data\raw\2013 ButtonPress dat files\*.dat', 'Pick a .dat data file');
    rawData = importdata(strcat(pathname, filename));
    numFiles = 1;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% Save raw data to mat file %%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % See if data already saved to mat file %
    load('C:\Users\Erin\Box Sync\UPF\PlaidProj\Data\processed\keyPressData\keyData.mat');
    L = length(keyData.subjects);
    
    for i = 1 : L
        fileRepeat(i,1) =  strcmp(keyData.subjects(1,i).name, filename);
    end
    
    % Save raw data to mat file %
    if sum(fileRepeat) < 1
        keyData.subjects(1, L + 1).name = filename;
        keyData.subjects(1, L + 1).data = rawData;
        save('C:\Users\Erin\Box Sync\UPF\PlaidProj\Data\processed\keyPressData\keyData.mat','keyData');
    end
    
elseif AnalysisType == 2
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% Get raw data mat file %%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    load('C:\Users\Erin\Box Sync\UPF\PlaidProj\Data\processed\keyPressData\keyData.mat');
    numFiles = length(keyData.subjects);
end



%%%%%%%%%%%%%%%%%%%%
%% SUMMARIZE DATA %%
%%%%%%%%%%%%%%%%%%%%

for i = 1 : numFiles
    
    if AnalysisType == 2      
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%% Select raw data from mat file %%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        clear rawData; clear gapOverlap; % clear data from prev loop
        rawData = keyData.subjects(1,i).data;
        filename = keyData.subjects(i).name;
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% Generate press time series %%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    timeSeriesTC1 = genTimeSeries(rawData,FR); 
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% Summarize and visualize time series pre-clean-up %%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % Summarize gap and overlap data with plots %
    [gapOverlap_pre, meanGapOverlap_pre, stdGapOverlap_pre, durA_pre, durB_pre] = summarizeData(timeSeriesTC1, filename, plot_yn);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% Clean-up gaps and overlaps %%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    timeSeriesTC1 = cleanUpTS(timeSeriesTC1);
        
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% Summarize and visualize time series POST-clean-up %%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    [gapOverlap_post, meanGapOverlap_post, stdGapOverlap_post, durA_post, durB_post] = summarizeData(timeSeriesTC1, filename, plot_yn);
    
    pause % to view histogram and plot for each subject
    
    %if AnalysisType == 2
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%% Save result data to mat file %%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        %         %save key press RESULTS to different .mat file %
        %         keyRes.subjects(1,i).name = keyData.subjects(1, i).name; %save filename
        %         keyRes.subjects(1,i).gap = gapOverlap; %save gaps/overlaps values
        %         keyRes.subjects(1,i).results(1) = meanGapOverlap; %save single val results in results bin
        %         keyRes.subjects(1,i).results(2) = stdGapOverlap;
        %         save('C:\Users\Erin\Box Sync\UPF\PlaidProj\Data\processed\keyPressData\keyRes.mat','keyRes');
    %end
    
end



%% Option (3) SIMULATION

if AnalysisType == 3
    
    %"TC" == 4 col vector: col 1 == count from 1:len(col1); col 2 == time (s)
    % of any button press/release; col 3 == press label (+/- 1, +/- 2); col 4 ==
    % zeros
    
    % simulation 1 %
    
    TC1=simTC_wJitter(3500,500,4800,800,600,150,20); % generate a simulated time course
    TC1(:,2)=TC1(:,2)/1000; % convert time course (col 2) to seconds
    [TimesA1,TimesB1,histA1,histB1] = analyzeTC(TC1, max(TC1(:,2)), 1); %TimesA1 == 2 cols (time on & off of each press), histA1 == 2 cols (bin vals, # in bin)
    
    
    % simulation 2 %
    
    TC2=simTC_wJitter(2000,1000,4000,1600,200,150,20);
    TC2(:,2)=TC2(:,2)/1000;
    [TimesA2,TimesB2,histA2,histB2] = analyzeTC(TC2, max(TC2(:,2)), 1);
    
end

%% POST-PROCESSING %%%%

%% Evaluate group data if real data

% if AnalysisType == 2
%     
%     load('C:\Users\Erin\Box Sync\UPF\PlaidProj\Data\processed\keyPressData\keyRes.mat','keyRes');
%     
%     for i = 1 : length(keyData.subjects)
%         groupMeanGap(i,1) = keyRes.subjects(1,i).results(1);
%         groupMeanStd(i,1) = keyRes.subjects(1,i).results(2);
%     end
%     
%     
%     figure
%     hist(groupMeanGap)
%     str = sprintf('Mean gap time between press for %d subjects with mean gap %.2f \n (a negative # would indicate overlap)', length(groupMeanGap), mean(groupMeanGap));
%     title(str)
%     figure
%     hist(groupMeanStd)
%     str2 = sprintf('Standard deviation for gap time for %d subjects with mean SD %.2f', length(groupMeanStd), mean(groupMeanStd));
%     title(str2)
%     
%     %~ 120 ms gap is the mean, ~ 50 is 1 SD : anything > 220 ms is an 'outlier'
% end

%% Evaluate data if simulated

if AnalysisType == 3
    
    %"timeSeries" == 3 col vector: col 1 is time at 120 Hz; col 2 vals == 1 
    % if A press; col 3 == 1 if B press (zero otherwise)
    
    timeSeriesTC1 = genTimeSeries(TC1,FR);
    
    timeSeriesTC2 = genTimeSeries(TC2,FR);
    
    % clean-up data; replace overlaps, leave gaps as 0 for now
    timeSeriesTC1 = cleanUpTC(timeSeriesTC1);
    timeSeriesTC2 = cleanUpTC(timeSeriesTC2);    
   
    
    % auto-correlation (return best lag(sec) and best normalized r coeff)
    [lagTC1, rTC1] = autocorrelation(timeSeriesTC1(:,2), FR, 'timeSeriesTC1');
    %[lagTC2, rTC2] = autocorrelation(timeSeriesTC2(:,2), FR, 'timeSeriesTC1');

       
    % cross-correlation analysis (return best lag(sec), best norm r-coeff,
    % r-coeff at 0 sec lag (xcorr), r-coeff at 0 sec lag (corrcoef)
    [lagA, rA, rA0_1, rA0_2] = crossCorrelation(timeSeriesTC1(:,2), timeSeriesTC2(:,2), FR, 'press A');
    [lagB, rB, rB0_1, rB0_2] = crossCorrelation(timeSeriesTC1(:,3), timeSeriesTC2(:,3), FR, 'press B');
      
  
end