# Project - AnalyzeButtonPresses
Date started: April 2014
Date ended: ACTIVE

# Synopsis

This project analyzes the timing of alternating mouse button presses 
(right/left or a/b) made in response to a bi-stable visual stimulus.

main.m will (1) get data, (2) generate a button press time series (list of mouse 
states as a function of time with a fixed dt), (3) summarize and visualize the 
time series pre-clean-up, (4) clean-up overlaps (not yet gaps) in button presses, 
(5) summarize and visualize time series post-clean-up, and (6) analyze the time 
series data.

# Motivation

Analyze the responses of experimental subjects in a vision science
experiment.

# TODO

- add option to remove 1st epoch in deriveVars.m
- clean-up plots
- clean-up gaps 
- remove dominance durations < 300 ms; see, 'Plaid-200415_MR_glassesWfilter_manipulatedLambdasB.txt_trial_2'
- analysis section for group data

# Important files

- **config.m** - set parameters including working directories/paths to data (Written by EB)
- **main.m** - entry point for running analysis script (Written by EB) 

# Short instructions 

Open config.m and (a) set the path to select data, (b) set the path to store data
and results, and (c) set the value of the variable "analysis_type". "analysis_type" can
be set equal to 1 to analyze a single file; equal to 2 to analyze all subject data 
saved in keyData.mat; set equal to 3 to analyze simulated dataset. (d) Also, set the
value for "input_format_vers", e.g., the version of the raw data (1 = old format; 2 = 
new format). Then run main.m.

# Supporting functions 

## GENERATE DATA: 

- **simTC_wJitter.m** - simulate pseudo-random button press event series
	- SUMMARY: Simulates pseudo-random event series of alternations between percept 
	A and B. Percept durations are drawn from a log-normal distribution. Called by
	**main.m**.
	- INPUT: meanAmsec, stdAmsec, meanBmsec, stdBmsec, meanRT, RTj, N
		- The average ('mean') and std of percepts A and B are specified independently
		- meanRT = mean reaction time 
		- RTj = jitter in reaction time (standard deviation)
		- N = number of simulated durations for each percept
	- OUTPUT: 
		- simTC (3 columns)
		    - column 1 = count from 1 : length(column 2)
    		- column 2 = time of left/right button press/release
    		- column 3 = label of event; Aon = 1; Aoff = 2; Bon = -1; Boff = -2
	- (Written by NR)
- NB: behavioral data is imported via main.m

## CLEAN DATA: 

- **selectData.m** -
	- SUMMARY: This function imports the .txt or .dat raw data files. Called by
	**main.m**.
	- INPUT: formatType(#), st_dir(string), out_dir(string), raw_mat(string)
	- OUTPUT: numFiles(#), keyData, index(scalar for format 1; vector for format 2)
		- keyData (3 columns)
			- column 1 = count from 1 : length(column 2)
    		- column 2 = time of left/right button press/release
    		- column 3 = label of event; Aon = 1; Aoff = 2; Bon = -1; Boff = -2
    - (Written by EB)

- **sepTrials.m** -
	- SUMMARY: Raw data in format type #2 has multiple trials in one file. This 
	function separates the button press data into those multiple trials. Called
	by the **selectData.m** function.
	- INPUT: rawData(n x 10 matrix), filename (string)
	- OUTPUT: trialData (1 x n structure, with n = # trials)
		- trial (2 fields; 'data', 'name' = filename + trial#)
			- data (3 columns)
				- column 1 = count from 1 : length(column 2)
    			- column 2 = time of left/right button press/release
    			- column 3 = label of event; Aon = 1; Aoff = 2; Bon = -1; Boff = -2
   	- (Written by EB)

- **genTimeSeries.m** -
	- SUMMARY: raw data is in the format of a column of mouse press/release 
	events and needs to be converted to continuous time series format. Called by
	**main.m**.
	- INPUT: rawData, framerate (#), endTime(#)
    	- rawData (3 columns)
    		- column 1 = count from 1 : length(column 2)
    		- column 2 = time of left/right button press/release
    		- column 3 = label of event; Aon = 1; Aoff = 2; Bon = -1; Boff = -2
	- OUTPUT: timeSeries (3 columns), endTime(#)
			- column 1 = time at 120 Hz
			- column 2 = label of A events; Aon = 1, Aoff = 0
			- column 3 = label of B events; Bon = 1, Boff = 0
	- (Written by EB in conjunction with NR)

- **addLastRelease.m** - 
	- SUMMARY: sometimes a button is still pressed at the end of a trial; this 
	function adds a dummy 'release' to the last frame of the trial; the 
	function returns button press vectors of equal length. Called by 
	**genTimeSeries.m**.
	- INPUT: vecAon, vecAoff, vecBon, vecBoff, ES, timeMaxTS(#)
		- vecAon/vecAoff/vecBon/vecBoff (1 column)
			- column 1 = indices of that button event in ES
		- ES (3 columns) == rawData (see above)
	- OUTPUT: vecAoff, vecBoff, ES
		- vecAoff/vecBoff (1 column)
			- column 1 = indices of that button event in ES, plus one additional
			index for either vecAoff or vecBoff (in effect, to add last release)
		- ES (3 columns) - new row added at end
			- column 1 = last cell set as len(col) + 1
			- column 2 = last cell set as timeMaxTS (last timestamp in trial)
			- column 3 = last cell set equal to either 2 (if add last release to 
			vecAoff) or -2 (if add last release to vecBoff)
	- (Written by EB adapted from NR's 'analyzeTC.m')

- **findPressInd.m** -	
	- SUMMARY: the time series vector needs to be labeled with the corresponding 
	button press events. Events are labeled for each frame with a 1 if the button
	was pressed or 0 if a button was not pressed (press A = column 2; press B = 
	column 3). This function finds the times when a button was pressed 
	(pressOn) and released (pressOff) and returns the index of the nearest frame
	at 120Hz. Called by **genTimeSeries.m**.
	- INPUT: vecPressOn, vecPressOff, i (#), ES, FR(#)
		- vecPressOn (1 column)
			- column 1 = indices of that button event (see vecAon, vecBon)
		- vecPressOff (1 column)
			- column 1 = indices of that button event (see vecAoff, vecBoff)
		- ES (3 columns) == rawData (see above)
	- OUTPUT: indStart (#), indEnd (#)
	- (Written by EB in conjunction with NR)

- **sortData.m** - POSSIBLY DELETE - simple sorting function (Written by EB) 

- **cleanUpTS.m**
	- SUMMARY: Find indices when col2 and col3 of TS are both pressed (==1).
	Loop backward (check last overlap 1st). If 1 frame after that overlap for
	pressA is equal to zero, change that overlap frame for pressA to zero. Else,
	pressB for that overlap frame is changed to zero. Called by **main.m**.
	- INPUT: TS (== timeSeries, see above)
	- OUTPUT: TS (3 columns)
		- column 1 = no change
		- column 2 = change 1's to 0's for press A if meets conditions in summary
		- column 3 = change 1's to 0's for press B if meets conditions in summary
	- (Written by EB)
	- NB: TO-Do; this function clean-ups overlaps but not gaps

## SUMMARIZE DATA:

- **summarizeData.m** - 
	- SUMMARY: this function takes the timeSeries data (button press as a 
	function of time at 120 Hz) and returns (1) the length of each gap/overlap
	between press A and B, (2) the duration of each press, and (3) the # of press switches. Called by **main.m**.
    - INPUT: TS, filename (string), plot_yn (#), startTime(#)
    	- TS (3 columns) (== timeSeries, see above)
			- column 1 = time at 120 Hz
			- column 2 = label of A events; Aon = 1, Aoff = 0
			- column 3 = label of B events; Bon = 1, Boff = 0
    - OUTPUT: gapOverlap, meanGapOverlap (#), stdGapOverlap (#), durA, durB, numSwitch (#)
    	- gapOverlap (2 columns)
    		- column 1 = duration of each gap ('pos' #) or overlap ('neg' #)
    		- column 2 = label of each event; A to B = -2; B to A = 2; 
    		repeat button (same press) = 0
    	- durA (1 column)
    		- column 1 = duration of each A press
    	- durB (1 column)
    		- column 1 = duration of each B press
	- (Written by EB, adapted from 'analyzeTC.m' written by NR)

- **deriveVars.m** -
	- SUMMARY: this function inputs the timeSeries data and returns (1) the % time of 
	percept A and B, (2) the mean dominance durations of press A and B, (3) the reaction 
	time to the first button press (s), and (4) the rate of button press alternations (s).
	Called by **main.m**.
	- INPUT: TS (see TS above), numSwitches (#), domDurA (see durA above), domDurB (durB above),
	FR(#)
	- OUTPUT: relA (#), relB (#), meanDurA (#), meanDurB (#), RT (#), altRate (#)
	- (Written by EB)

- **analyzeTC.m** - returns timestamps of button presses (Written by NR)

## VISUALIZE DATA:

- **plotTC.m** - plot time course of button presses 
	- Called by **summarizeData.m**.
	- (Written by NR)
- **histogramPrep.m** - return hist vectors for mouse press durations 
	- Called by **summarizeData.m**.
	- (Written by EB, adapted from NR)

## ANALYZE DATA:

- **crossCorrelation.m**
- **autocorrelation.m**