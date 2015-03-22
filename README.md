## Synopsis

This project analyzes the timing of alternating mouse button presses 
made in response to a bi-stable visual stimulus.

## Motivation

Analyze the responses of experimental subjects in a vision science
experiment.

## Important files

- **main.m** - main entry point for running analysis script (Written by EB) 

## Short instructions 

Open main.m and modify the value of the variable "AnalysisType". Set equal to 
1 to analyze a single .dat file. Set equal to 2 to analyze all subject data 
saved in keyData.mat. Set equal to 3 to analyze simulated dataset. 

## Supporting functions 

- **analyzePress.m** - returns length of gaps or overlaps between mouse
presses, and mouse press durations (Written by EB, adapted from 'analyzeTC.m' 
written by NR)
- **analyzeTC.m** - returns timestamps of button presses (Written by NR)
- **simTC_wJitter.m** - simulate pseudo-random button press time course 
(Written by NR)
- **lastDuration.m** - return button press vectors of equal length
after accounting for last button press of trial (Written by NR)
- **sortData.m** - simple sorting function (Written by EB)
- **plotTC.m** - plot time course of button presses (Written by NR)
- **histogramPrep.m** - return hist vectors for mouse press durations 
(Written by NR)
