function [numFiles, keyData, index] = selectData( formatType, st_dir, out_dir, raw_mat )
%selectData This function imports the text or dat raw data files

%keyboard

%%%%%%%%%%%%%%%%%%%%%%%
%%% old data format %%%
%%%%%%%%%%%%%%%%%%%%%%%

if formatType == 1
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% MASTER: Select data %%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    numFiles = 1;
        
    [filename, pathname] = uigetfile(st_dir, 'Pick a .dat data file');
    rawData = importdata(strcat(pathname, filename));
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% Save raw data to mat file %%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % See if data already saved to mat file %
    if exist(strcat(out_dir, raw_mat), 'file')
        load(strcat(out_dir, raw_mat));
        L = length(keyData.subjects);
        
        % if file exists, see if subject data saved yet
        for i = 1 : L
            fileRepeat(i,1) =  strcmp(keyData.subjects(1,i).name, filename);
        end
        
        % if subject data not saved, save raw data to mat file %
        if sum(fileRepeat) < 1
            keyData.subjects(1, L + 1).name = filename;
            keyData.subjects(1, L + 1).data = rawData;
            save(strcat(out_dir, raw_mat),'keyData');
            index = L + 1; % subject index is length of subjt struct plus 1
        else
            [index,~] = find(fileRepeat == 1); % subject index is index found in subjt struct
        end
        
        % if file does not exist, save subject data into new mat file
    else
        keyData.subjects(1, 1).name = filename;
        keyData.subjects(1, 1).data = rawData;
        save(strcat(out_dir, raw_mat),'keyData');
        index = 1; % subject index is first index in new subjt struct
    end
    
    
    
    
    %%%%%%%%%%%%%%%%%%%%%%%
    %%% new data format %%%
    %%%%%%%%%%%%%%%%%%%%%%%
    
elseif formatType == 2
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% NwDATAFORMAT: Select data %%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    [filename, pathname] = uigetfile(st_dir, 'Pick a .txt data file');
    rawData = importfile(strcat(pathname, filename)); % importfile is a Matlab generated function that generates a matrix (string information dropped)
    splitData = sepTrials( rawData, filename); % Separate data file into separate trials
    
    numTrials = length(splitData.trial);
    numFiles = numTrials; % save as numFiles for output to main.m
    index = zeros(numTrials, 1); % so we can retrieve subject # in raw data struct "keyData"
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% Save raw data to mat file %%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      
    for j = 1 : numTrials 
        
        % See if data already saved to mat file %
        if exist(strcat(out_dir, raw_mat), 'file')
            
            load(strcat(out_dir, raw_mat));

            L = length(keyData.subjects);
            
            % is subject data saved yet
            for i = 1 : L
                fileRepeat(i,1) =  strcmp(keyData.subjects(1,i).name, splitData.trial(1,j).name); %subject name/trial saved yet?
            end
            
            % if subject data not saved, save raw data to mat file %
            if sum(fileRepeat) < 1
                keyData.subjects(1, L + 1).name = splitData.trial(1,j).name;
                keyData.subjects(1, L + 1).data = splitData.trial(1,j).data;
                save(strcat(out_dir, raw_mat),'keyData');
                index(j) = L + 1; % subject index is length of subjt struct plus 1
            else
                [index(j),~] = find(fileRepeat == 1); % subject index is index found in subjt struct
            end
            
            
            % if file does not exist, save subject data into new mat file
            % (only possible for 1st trial)
        else
            keyData.subjects(1, 1).name = splitData.trial(1,j).name;
            keyData.subjects(1, 1).data = splitData.trial(1,j).data;
            save(strcat(out_dir, raw_mat),'keyData');
            index(j) = 1; % subject index is first index in new subjt struct
        end
    end
    
end

end

