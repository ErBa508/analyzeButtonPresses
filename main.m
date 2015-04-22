%% Script to analyze button press data
% Created by Erin, Feb 10, 2015
% Modified from NR analyzeTC.m function


%%%%%%%%%%%%%%%%%%%%%
%% Clear workspace %%
%%%%%%%%%%%%%%%%%%%%%

clc
clear all
close all


%%%%%%%%%%%%%%%%%%
%% INPUT PARAMS %%
%%%%%%%%%%%%%%%%%%

P = config(); % function to set parameters
st_dir = P.input_path; % input directory
out_dir = P.output_path; % output directory
raw_mat = P.data_mat_name; % structure with raw data for all subjects
res_mat = P.results_mat_name; % structure with results data for all subjects

AnalysisType = P.analysis_type; %if single file analysis = 1; if batch analysis = 2; if simulation = 3 
FR = P.FR; % frame rate
plot_yn = P.plot_yn; % if want to see summary plots (1 if yes, 0 if no)
formatType = P.input_format_vers; % new format


%%%%%%%%%%%%%%
%% GET DATA %%
%%%%%%%%%%%%%%

if AnalysisType == 1
    %%%%%%%%%%%%%%%%%%%
    %%% Select data %%%
    %%%%%%%%%%%%%%%%%%%
    
    [numFiles, keyData, subInd] = selectData(formatType, st_dir, out_dir, raw_mat);
    
elseif AnalysisType == 2
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% Get raw data mat file %%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    load(strcat(out_dir, raw_mat)); % load keyData.mat
    
    numFiles = length(keyData.subjects);
    
elseif AnalysisType == 3
      
    %%%%%%%%%%%%%%%%%%%%%
    %%% Simulate data %%%
    %%%%%%%%%%%%%%%%%%%%%
    
    numFiles = 2;

    simData.es(1,1).data = simTC_wJitter(3500,500,4800,800,600,150,20); % generate a simulated event series
    simData.es(1,1).data(:,2) = simData.es(1,1).data(:,2)/1000; % convert event series (col 2) to seconds
    simData.es(1,1).name = 'Simulation 1'; 
    
    simData.es(1,2).data = simTC_wJitter(3000,500,4000,1600,200,150,20);
    simData.es(1,2).data(:,2) = simData.es(1,2).data(:,2)/1000;
    simData.es(1,2).name = 'Simulation 2';
end



%%%%%%%%%%%%%%%%%%%%
%% SUMMARIZE DATA %%
%%%%%%%%%%%%%%%%%%%%

for i = 1 : numFiles
    
    if AnalysisType == 1
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%% Select trial data from keyData struct %%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        clear selData; clear gapOverlap_pre; clear gapOverlap_post; % clear data from prev loop
        clear durA_pre; clear durA_post; clear durB_pre; clear durB_post; clear timeSeriesTC1;
        
        if formatType == 1
            
            selData = keyData.subjects(1,subInd).data; % subjInd is a scalar value
            filename = keyData.subjects(subInd).name;
            startTime = keyData.subjects(subInd).start;
            endTime = keyData.subjects(subInd).end; % time set to 0 as place holder (not in raw data file) and corrected in genTimeSeries.m
            
        elseif formatType == 2
            
            L = subInd(i) - 1; %subInd = vector of trial indices; subtract 1 from index because adding i in next line
            selData = keyData.subjects(1,L + 1).data;
            filename = keyData.subjects(L + 1).name;
            startTime = keyData.subjects(L + 1).start;
            endTime = keyData.subjects(L + 1).end; % this time is accurate as it has been recorded in the file
        end
        
    elseif AnalysisType == 2      
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%% Select raw data from mat file %%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        clear selData; clear gapOverlap_pre; clear gapOverlap_post; % clear data from prev loop
        clear durA_pre; clear durA_post; clear durB_pre; clear durB_post; clear timeSeriesTC1;
        selData = keyData.subjects(1,i).data;
        filename = keyData.subjects(i).name;
        startTime = keyData.subjects(i).start;
        endTime = keyData.subjects(i).end;
        
    elseif AnalysisType == 3
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%% Select simulated data from structure %%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        clear selData; clear gapOverlap_post % clear data from prev loop
        clear durA_post; clear durB_post; clear timeSeriesTC1;
        selData = simData.es(1,i).data;
        filename = simData.es(1,i).name;
        startTime = 0;
        endTime = 0; % this time is set to 0 as a place holder and corrected at end of genTimeSeries.m
   
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% Generate press time series %%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    [timeSeriesTC1, endTime] = genTimeSeries(selData, FR, endTime); 
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% Summarize and visualize time series pre-clean-up %%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % Summarize gap and overlap data with plots %
    [gapOverlap_pre, meanGapOverlap_pre, stdGapOverlap_pre, durA_pre, durB_pre, numSwitches_pre] = summarizeData(timeSeriesTC1, filename, plot_yn, startTime);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% Clean-up gaps and overlaps %%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    timeSeriesTC1 = cleanUpTS(timeSeriesTC1); % TO-DO; only cleans up overlaps so far
    
    % TO-DO; set dominance durations less than 300 ms to zero
        
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% Summarize and visualize time series POST-clean-up %%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    [gapOverlap_post, meanGapOverlap_post, stdGapOverlap_post, durA_post, durB_post, numSwitches_post] = summarizeData(timeSeriesTC1, filename, plot_yn, startTime);
    
    fprintf('Script paused: press any button to continue\n')
    pause % to view histogram and plot for each subject
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% Derive new variables %%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % (1) relative dominance duration per percept, (2) mean dominance
    % duration per percept, 3) reaction time for 1st percept (s), (4)
    % alternation rate (s)
    
    [percTimeA, percTimeB, meanDurA, meanDurB, RT, alternRate] = deriveVars(timeSeriesTC1, numSwitches_post, durA_post, durB_post, startTime, endTime);

    if AnalysisType == 2
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%% Save result data to mat file %%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        %save key press RESULTS to .mat file %
        % NB - currently re-writing .mat file each time run script %
        keyRes.subjects(1,i).name = filename; %save filename
        keyRes.subjects(1,i).data = timeSeriesTC1; % save time series
        keyRes.subjects(1,i).gap = gapOverlap_post; %save gaps/overlaps values
        keyRes.subjects(1,i).resLabel = {'meanGapOverlap' 'stdGapOverlap' 'percTimeA' 'percTimeB' 'meanDurA' 'meanDurB' 'RT' 'alternRate'};
        keyRes.subjects(1,i).results(1) = meanGapOverlap_post; %save single val results in results bin
        keyRes.subjects(1,i).results(2) = stdGapOverlap_post;
        keyRes.subjects(1,i).results(3) = percTimeA;
        keyRes.subjects(1,i).results(4) = percTimeB;
        keyRes.subjects(1,i).results(5) = meanDurA;
        keyRes.subjects(1,i).results(6) = meanDurB;
        keyRes.subjects(1,i).results(7) = RT;
        keyRes.subjects(1,i).results(8) = alternRate;
        save(strcat(out_dir, res_mat),'keyRes');
        
    elseif AnalysisType == 3
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%% Add result data to structure %%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        simRes.run(1,i).name = filename; %add filename
        simRes.run(1,i).data = timeSeriesTC1;
        simRes.run(1,i).gap = gapOverlap_post; %add gaps/overlaps values
        simRes.run(1,i).resLabel = {'meanGapOverlap' 'stdGapOverlap' 'percTimeA' 'percTimeB' 'meanDurA' 'meanDurB' 'RT' 'alternRate'};
        simRes.run(1,i).results(1) = meanGapOverlap_post; %add single val results in results bin
        simRes.run(1,i).results(2) = stdGapOverlap_post;
        simRes.run(1,i).results(3) = percTimeA;
        simRes.run(1,i).results(4) = percTimeB;
        simRes.run(1,i).results(5) = meanDurA;
        simRes.run(1,i).results(6) = meanDurB;
        simRes.run(1,i).results(7) = RT;
        simRes.run(1,i).results(8) = alternRate;
    end
    
end


%%%%%%%%%%%%%%%%%%%%%%%%
%% ANALYZE GROUP DATA %%
%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Visualize group data %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Evaluate group data if real data

if AnalysisType == 2
    
    load(strcat(out_dir, res_mat),'keyRes');
    
    for i = 1 : length(keyData.subjects)
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%% Add results to group matrix %%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        groupRes(i,:) = keyRes.subjects(1,i).results; % take the results for each subject and add to a 'Group Results' matrix
    end
    
    for j = 1 : size(groupRes,2)
        %%%%%%%%%%%%%%%%%
        %%% Histogram %%%
        %%%%%%%%%%%%%%%%%
        figure
        hist(groupRes(:,j))
        str = sprintf('%s for %d subjects with mean of %.2f s', keyRes.subjects(1,1).resLabel{1,j}, length(groupRes(:,1)), mean(groupRes(:,j)));
        title(str)
    end
    
    %~ 120 ms gap is the mean, ~ 50 is 1 SD : anything > 220 ms is an 'outlier'
end

%% Evaluate data if simulated

if AnalysisType == 3
    

    %%%%%%%%%%%%%%%%%%%%%%%
    %%% Autocorrelation %%%
    %%%%%%%%%%%%%%%%%%%%%%%
    
    % Autocorrelation (return best lag(sec) and best normalized r coeff)
    [lagTC1, rTC1] = autocorrelation(simRes.run(1,1).data(:,2), FR, simRes.run(1,1).name);

    %%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% Cross- correlation %%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%
       
    % cross-correlation analysis (return best lag(sec), best norm r-coeff,
    % r-coeff at 0 sec lag (xcorr), r-coeff at 0 sec lag (corrcoef)
    [lagA, rA, rA0_1, rA0_2] = crossCorrelation(simRes.run(1,1).data(:,2), simRes.run(1,2).data(:,2), FR, 'press A');
    [lagB, rB, rB0_1, rB0_2] = crossCorrelation(simRes.run(1,1).data(:,3), simRes.run(1,2).data(:,3), FR, 'press B');
      
  
end