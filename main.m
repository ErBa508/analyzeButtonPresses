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
            
            L = subInd(i); %subInd = vector of trial indices relative to placement in keyData structure
            selData = keyData.subjects(1,L).data;
            filename = keyData.subjects(L).name;
            startTime = keyData.subjects(L).start;
            endTime = keyData.subjects(L).end; % this time is accurate as it has been recorded in the file
            params = keyData.subjects(L).params;
            paramsNames = keyData.subjects(L).paramsNames;
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
        params = keyData.subjects(i).params;
        paramsNames = keyData.subjects(i).paramsNames;
        
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
    
    [fractA_totalTime, fractB_totalTime, fractA_pressTimeOnly, fractB_pressTimeOnly, meanDurA, meanDurB, RT, alternRate] = deriveVars(timeSeriesTC1, numSwitches_post, durA_post, durB_post, startTime, endTime, FR);

    if AnalysisType == 2
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%% Save result data to mat file %%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        %save key press RESULTS to .mat file %
        % NB - currently re-writing .mat file each time run script %
        keyRes.subjects(1,i).name = filename; %save filename
        keyRes.subjects(1,i).data = timeSeriesTC1; % save time series
        keyRes.subjects(1,i).gap = gapOverlap_post; %save gaps/overlaps values
        keyRes.subjects(1,i).resLabel = {'meanGapOverlap' 'stdGapOverlap' 'fractA_totalTime' 'fractB_totalTime' 'fractA_pressTimeOnly' 'fractB_pressTimeOnly' 'meanDurA' 'meanDurB' 'RT' 'alternRate'};
        keyRes.subjects(1,i).results = [meanGapOverlap_post stdGapOverlap_post fractA_totalTime fractB_totalTime fractA_pressTimeOnly fractB_pressTimeOnly meanDurA meanDurB RT alternRate]; %save single val results in results bin
        keyRes.subjects(1,i).params = params;
        keyRes.subjects(1,i).paramsNames = paramsNames;
        save(strcat(out_dir, res_mat),'keyRes');
        
        
    elseif AnalysisType == 3
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%% Add result data to structure %%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        simRes.run(1,i).name = filename; %add filename
        simRes.run(1,i).data = timeSeriesTC1;
        simRes.run(1,i).gap = gapOverlap_post; %add gaps/overlaps values
        keyRes.subjects(1,i).resLabel = {'meanGapOverlap' 'stdGapOverlap' 'fractA_totalTime' 'fractB_totalTime' 'fractA_pressTimeOnly' 'fractB_pressTimeOnly' 'meanDurA' 'meanDurB' 'RT' 'alternRate'};
        keyRes.subjects(1,i).results = [meanGapOverlap_post stdGapOverlap_post fractA_totalTime fractB_totalTime fractA_pressTimeOnly fractB_pressTimeOnly meanDurA meanDurB RT alternRate]; %save single val results in results bin
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
    
    %THIS ASSUMES THAT PARAMETERS & HEADERS ARE THE SAME FOR ALL SUBJECTS
%     param_index = [11 12 15 21:33]; % which config/trial parameters do we want to pull out?
%     headers_for_output = horzcat(keyRes.subjects(1,1).resLabel, (keyRes.subjects(1,1).paramsNames(param_index))'); 
    headers_for_output = horzcat(keyRes.subjects(1,1).resLabel, (keyRes.subjects(1,1).paramsNames)'); % no param_index, include all parameter variables and values
    ind = size(keyRes.subjects(1,1).results, 2); 
    width = size(headers_for_output,2);
    height = size(keyData.subjects,2);
    groupRes = zeros(height, width);
    
    for i = 1 : size(keyData.subjects,2)
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%% Add results to group matrix %%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%         groupRes(i,:) = horzcat(keyRes.subjects(1,i).results, (keyRes.subjects(1,i).params(param_index))'); % take the results for each subject and add to a 'Group Results' matrix
        groupRes(i,:) = horzcat(keyRes.subjects(1,i).results, (keyRes.subjects(1,i).params)'); % take the results for each subject and add to a 'Group Results' matrix
        name(i,1) = cellstr(keyRes.subjects(1,i).name);
        %         groupRes(i, (ind+1):end) = ; %add the parameter values for each trial
    end
    
    for j = 1 : ind
        %%%%%%%%%%%%%%%%%
        %%% Histogram %%%
        %%%%%%%%%%%%%%%%%
        figure
        hist(groupRes(:,j))
        if j == 3 || j == 4 || j == 5 || j == 6
            str = sprintf('%s for %d trials/subjects with mean of %.2f %%', keyRes.subjects(1,1).resLabel{1,j}, length(groupRes(:,1)), 100 * mean(groupRes(:,j)));
        elseif j == 10
            str = sprintf('%s for %d trials/subjects with mean of %.2f per minute', keyRes.subjects(1,1).resLabel{1,j}, length(groupRes(:,1)), mean(groupRes(:,j)));
        else  
            str = sprintf('%s for %d trials/subjects with mean of %.2f s', keyRes.subjects(1,1).resLabel{1,j}, length(groupRes(:,1)), mean(groupRes(:,j)));
        end
        title(str)
    end
    
    % OUTPUT RESULTS AS CSV FILE
    
    if size(headers_for_output,2) == size(groupRes,2)
        combo = [headers_for_output; num2cell(groupRes)]; % matrix with results and header with labels
        name_col = vertcat('filename', name); % new column with filenames
        combo2 = horzcat(name_col, combo); % matrix with results plus filenames
        cell2csv('keyPress_results.csv', combo2)
        fprintf('\nTo view subject data: open csv file labeled "keyPress_results"\n')
        fclose('all');
    else
        fprintf('\nThe number of columns for headers and for numeric data are not the same')
    end

%     fprintf('\nTo view subject data: double click the variable named "groupRes"\n')
%     fprintf('\nThe headers for groupRes columns are: (1)"meanGap" (2)"standDevGap" (3)"fractA_totalTime"\n (4)"fractB_totalTime" (5)"fractA_pressTimeOnly" (6)"fractB_pressTimeOnly" (7)"meanDurA"\n (8)"meanDurB" (9)"reactionTime" (10)"alternRate"\n')
%     fprintf('\n Each groupRes row represents a new trial or subject\n')
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