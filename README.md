## Project - AnalyzeButtonPresses
Date started: April 2014
Date ended: ACTIVE

## Synopsis

This project analyzes the timing of alternating mouse button presses 
(right/left or a/b) made in response to a bi-stable visual stimulus.

## Motivation

Analyze the responses of experimental subjects in a vision science
experiment.

## TODO

- check quality of clean-up code on "data file testN Gerald 2.dat"

## Important files

- **main.m** - entry point for running analysis script (Written by EB) 

## Short instructions 

Open main.m and modify the value of the variable "AnalysisType". Set equal to 
1 to analyze a single .dat file. Set equal to 2 to analyze all subject data 
saved in keyData.mat. Set equal to 3 to analyze simulated dataset. 

## Supporting functions 

1. GENERATE DATA: 
- **simTC_wJitter.m** - simulate pseudo-random button press time course 
(Written by NR)

2. CLEAN DATA: 

- **lastDuration.m** - return button press vectors of equal length
after accounting for last button press of trial (Written by NR)
- **sortData.m** - POSSIBLY DELETE - simple sorting function (Written by EB) 
- **cleanUpTC.m**
- **simTimeCourseByPress.m** -

3. SUMMARIZE DATA:

- **analyzePress.m** - SHOULD BE "summarizePressData.m"
    - INPUT: inputData, filename = string
    	- inputData (3 columns)
    		- column 1 = count from 1 : length(column 2)
    		- column 2 = time of left/right button press/release
    		- column 3 = label of event; Aon = 1; Aoff = 2; Bon = -1; Boff = -2
    - OUTPUT: gapOverlap, meanGapOverlap = #, stdGapOverlap = #, durA, durB
    	- gapOverlap (2 columns)
    		- column 1 = duration of each gap ('pos' #) or overlap ('neg' #)
    		- column 2 = label of each event; A to B = -2; B to A = 2; 
    		repeat press = 0
    	- durA (1 column)
    		- column 1 = duration of each A press
    	- durB (1 column)
    		- column 1 = duration of each B press
	- (Written by EB, adapted from 'analyzeTC.m' written by NR)
- **analyzeTC.m** - returns timestamps of button presses (Written by NR)

- **findPressInd.m** -

4. VISUALIZE DATA:
- **plotTC.m** - plot time course of button presses (Written by NR)
- **histogramPrep.m** - return hist vectors for mouse press durations 
(Written by EB, adapted from NR)

5. ANALYZE DATA:
- **crossCorrelation.m**
- **autocorrelation.m**