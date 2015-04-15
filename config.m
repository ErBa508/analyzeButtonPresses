function [ param ] = config()
%config(): this function sets the initial parameters for the button press analysis

param.input_path = 'C:\Users\Erin\Box Sync\UPF\PlaidProj\Data\raw\2013 ButtonPress dat files\*.dat';
%param.output_path = 'C:\Users\Erin\Box Sync\UPF\PlaidProj\Data\processed\keyPressData\';
param.output_path = 'C:\Users\Erin\Box Sync\UPF\PlaidProj\SrcCode\analyzeKeyPress\';

param.analysis_type = 1; %if single file analysis = 1; if batch analysis = 2; if simulation = 3
param.input_format_vers = 1; %if old format = 1 (key-press labels are 1's and 2's); if new format = 2 (key-press labels are 1's and 4's) 

param.plot_yn = 1; % if want to see summary plots (1 if yes, 0 if no)

param.data_mat_name = 'keyData.mat';
param.results_mat_name = 'keyRes.mat';

param.FR = 120; % frame rate (or sampling frequency for time series data)

end

