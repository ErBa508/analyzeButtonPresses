function [TimesA,TimesB,histA,histB] = analyzeTC(TCraw, Tmax, plot_yn)
% Usage: [TimesA,TimesB,histA,histB] = analyzeTC(TCraw, Tmax, plot_yn)

% CONSTANTS: data-file output file convensions
colSeq=1;  % 1st column, sequantial index of mouse/keyboard events
colTime=2; % 2nd column, time of event (NOTE: in sec, not millisec!!!)
colKey=3;  % 3rd column, identifier of event (full list below)
colTot=4;  % rest of columns (legacy/real-data) will be padded w/zeros
keyAon=1; keyAoff=2;
keyBon=-1; keyBoff=-2;
% 
% CONSTANTS: Other
epsilon = 0.0123;      % to mark epochs interrupted by end-of-trial 
colorA=[1.0 0.0 0.0];  % to use in case plot_yn=1
colorB=[0.0 1.0 0.0];
YvalsA=[0.80 0.90 0 1];
YvalsB=[0.75 0.85 0 1];
% for histogram
minNumBins = 5;
maxNumBins = 15;
minItemsPerBin = 4;
% OR
% numBins = 5  % fixed # of bins; Note: need to comment-out numBin calc below!   

% ACTION..
%
vecAon=TCraw(find(TCraw(:,colKey)==keyAon),colTime);
vecAoff=TCraw(find(TCraw(:,colKey)==keyAoff),colTime);
vecBon=TCraw(find(TCraw(:,colKey)==keyBon),colTime);
vecBoff=TCraw(find(TCraw(:,colKey)==keyBoff),colTime);
%
% simple cleaups and sanity-checks (percept A) 
if (length(vecAon)-length(vecAoff))==1 %end of trial occurred during Aon
    vecAoff(length(vecAoff)+1)=Tmax-epsilon;   % to use find(t(..)=f(epsilon)) etc
else
    if (length(vecAon)~=length(vecAoff)) %if end of trial was during Aoff,
        fprintf('Warning:\n')            %Aon and Aoff should be of equal length.
    end
end
if min(vecAoff-vecAon)<0
      fprintf('Warning:\n')     %each Off event must be after an On event
end
% (repeat for B)
if (length(vecBon)-length(vecBoff))==1
    vecBoff(length(vecBoff)+1)=Tmax-epsilon;
else
    if (length(vecBon)~=length(vecBoff))
        fprintf('Warning:\n')
    end
end
if min(vecBoff-vecBon)<0
      fprintf('Warning:\n')
end

% stage 1: no treatment of gaps/overlaps
TimesA=[vecAon vecAoff];
TimesB=[vecBon vecBoff];
% 
if plot_yn==1
    h=figure();
    %
    h1 = subplot(2,1,1);             % plot of 'raw' TC
    plotTC(h1,TimesA,Tmax,YvalsA,colorA)
    hold on
    plotTC(h1,TimesB,Tmax,YvalsB,colorB)
end

% stage 2: *** INCOMPLETE ***
durA=TimesA(:,2)-TimesA(:,1);
durB=TimesB(:,2)-TimesB(:,1);
%
% prepare bins for histogram of percept durations    
tmp=floor((size(durA,1)+size(durB,1))/(2*minItemsPerBin));
if tmp>maxNumBins
    numBins=maxNumBins;
else
    numBins=max((tmp),minNumBins);
end
tmpmin=min(min(durA),min(durB));
tmpmax=max(max(durA),max(durB));
binw=(tmpmax-tmpmin)/numBins;
bins=tmpmin:binw:tmpmax;     % note length(bins) is numBins+1 but last element in histc will be 0
%
histA = histc(durA,bins);
histB = histc(durB,bins);
%
if plot_yn==1
    h2 = subplot(2,1,2);
    shift=0.1*binw*ones(size(bins));
    bar(bins-shift,histA,0.1*binw,'EdgeColor',colorA,'FaceColor',colorA)
    hold on
    bar(bins+shift,histB,0.1*binw,'EdgeColor',colorB,'FaceColor',colorB)
end

% include bins w/hists of A and B passed as output
histA = [bins' histA];    
histB = [bins' histB];    
