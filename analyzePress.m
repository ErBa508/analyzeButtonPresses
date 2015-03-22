function [gapOverlap, meanGapOverlap, stdGapOverlap, durA, durB] = analyzePress(inputData, filename)

%% Constants

plot_yn = 1;

% column reference for inputdata
colSeq = 1;
colTime = 2;
colKey = 3;
%colTot = 

% label key press
keyAon=1; keyAoff=2;
keyBon=-1; keyBoff=-2;

% Epsilon
epsilon = 0.0123;      % to mark epochs interrupted by end-of-trial 

% constants for plotting
colorA=[1.0 0.0 0.0];  % to use in case plot_yn=1
colorB=[0.0 1.0 0.0];
YvalsA=[0.80 0.90 0 1];
YvalsB=[0.75 0.85 0 1];

% constants for histogram
minNumBins = 5;
maxNumBins = 15;
minItemsPerBin = 4;

%% Assign to vectors the time of each respective button event

vecAon = inputData(inputData(:,colKey)== keyAon, colTime);
vecAoff = inputData(inputData(:,colKey)== keyAoff, colTime);
vecBon = inputData(inputData(:,colKey)== keyBon, colTime);
vecBoff = inputData(inputData(:,colKey)== keyBoff, colTime);

%% Clean-up for unequal # presses and releases of a button

% Tmax
Tmax = max(inputData(:,colTime));

[vecAon, vecAoff, vecBon, vecBoff] = lastDuration(vecAon, vecAoff, vecBon, vecBoff, Tmax, epsilon);

TimesA=[vecAon vecAoff ones(length(vecAon),1)]; % 3rd column is to label button press
TimesB=[vecBon vecBoff ones(length(vecBon),1)*-1];

%% Sort for button press order and measure gaps/overlaps

timesCat = cat(1,TimesA, TimesB);
[d1, d2] = sort(timesCat(:,1));
timesSort = timesCat(d2,:);

% gaps/overlaps
for i = 1: length(timesSort) - 1 % -1 because # of switches is one less than # of presses
    gapOverlap(i,1) = timesSort(i+1,1) - timesSort(i,2); % next press minus previous button release
    gapOverlap(i,2) = timesSort(i+1,3) - timesSort(i,3); % gap between same button? if = +/-2 there is a button switch, if = 0 gap between same button
    
end

disp('gapOverlap var: positive value = gap, negative value = overlap');
meanGapOverlap = mean(gapOverlap(:,1));
stdGapOverlap = std(gapOverlap(:,1));

%% 1. Plot with no treatment of gaps/overlaps 

if plot_yn==1
    h=figure();
    %
    h1 = subplot(3,1,1);             % plot of 'raw' TC
    plotTC(h1,TimesA(:,1:2),Tmax,YvalsA,colorA)
    hold on
    plotTC(h1,TimesB(:,1:2),Tmax,YvalsB,colorB)
    
    str = sprintf('Filename is "%s" and # of presses = %d', strrep(filename, '_', ' '), length(timesCat)); %need to take out underscores or formats text as subscript in title
    title(str)
end

%% 2. Histogram for dominance durations (@ review hist plot organization; turn into separate function like plotTC)

durA=TimesA(:,2)-TimesA(:,1);
durB=TimesB(:,2)-TimesB(:,1);

binw = 5; % 5 secs % to spot outliers and keep interval constant

[histA, histB, bins] = histogramPrep(durA, durB, binw);

if plot_yn==1
    h2 = subplot(3,1,2);
    %figure
    shift=0.1*binw*ones(size(bins));
    bar(bins-shift,histA,0.1*binw,'EdgeColor',colorA,'FaceColor',colorA)
    hold on
    bar(bins+shift,histB,0.1*binw,'EdgeColor',colorB,'FaceColor',colorB)
    str = sprintf('Dominance durations;\n Bin width %.2f s and bin shift +/- %.2f ', binw, shift(1));
    title(str) 
end

% include bins w/hists of A and B passed as output
histA = [bins' histA];    
histB = [bins' histB]; 



%% 3. Histogram for gaps/overlaps

tmpmin = min(gapOverlap(:,1));
tmpmax = max(gapOverlap(:,1));

binw2 = (tmpmin+tmpmax)/6;

bins2 = tmpmin: binw2: tmpmax;
if bins2(end) < tmpmax
   bins2(end + 1) = bins2(end) + binw2; 
end

hist = histc(gapOverlap, bins2);
h3 = subplot(3,1,3);
%figure
bar(bins2, hist, 'EdgeColor', colorA, 'FaceColor', colorA)
str = sprintf('Gaps(+) and overlaps(-);\n Bin width %.2f s and and no bin shift\n Mean gap/overlap = %.3f s', binw2, meanGapOverlap);
title(str)

keyboard
