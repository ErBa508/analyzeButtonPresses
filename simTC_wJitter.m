function simTC = simTC_wJitter(meanAmsec,stdAmsec,meanBmsec,stdBmsec,meanRT,RTj,N)
% Simulates pseudo-random time-course of alternations between percept A and B
% Percept durations are drawn from a log-normal distribution
% The average ('mean') and std of percepts A and B are specified independently
% 
% Usage: simTC=simTC_lognormal(A_avrg,A_std,B_avrg,B_std,N);
%        where N is the number of simulated durations for each percept
% Example: simTC=simTC_lognormal(5500,1500,8500,2300,10); 
% (Note: by convention we specify durations in msec (as per inp variables' names),
%        but the code does not depend on it and will work w/any time units.) 

% meanRT=600;  %in msecs
% RTj=200;     % jitter RT by "std" (in msec)
               %               ^-- "" b/c RTs are not normally distrib

% CONSTANTS: data-file output file convensions
colSeq=1;  % 1st column, sequantial index of mouse/keyboard events
colTime=2; % 2nd column, time of event (NOTE: in sec, not millisec!!!)
colKey=3;  % 3rd column, identifier of event (full list below)
colTot=4;  % rest of columns (legacy/real-data) will be padded w/zeros
keyAon=1; keyAoff=2;
keyBon=-1; keyBoff=-2;

% ACTION..
%
% calc mu,sigma needed to get the desired durations' mean and variance in msec
varAmsec=power(stdAmsec,2);
varBmsec=power(stdBmsec,2);
muA=log(power(meanAmsec,2)/sqrt(varAmsec+power(meanAmsec,2)));
sigA=sqrt(log(1+varAmsec/power(meanAmsec,2)));
muB=log(power(meanBmsec,2)/sqrt(varBmsec+power(meanBmsec,2)));
sigB=sqrt(log(1+varBmsec/power(meanBmsec,2)));
%
% generate the log-normally distributed random durations
durA=lognrnd(muA,sigA,1,N);
durB=lognrnd(muB,sigB,1,N);
%
% flip-coin which percept is first
if rand()<(meanAmsec/(meanAmsec+meanBmsec)) %ToDo NOTE: change to sigmoid(f) !!!
%                                       %if rand()<0.5 (obsolete but keep for rec)
    durP1=durA; durP2=durB;
    keyP1on=keyAon; keyP1off=keyAoff; keyP2on=keyBon; keyP2off=keyBoff;
else
    durP1=durB; durP2=durA;
    keyP1on=keyBon; keyP1off=keyBoff; keyP2on=keyAon; keyP2off=keyAoff;
end
%
% simTC stores the time-course in msec, w/o jitter
simTC=zeros(4*N,colTot); % each P1 or P2 duration makes 2 mouse/keyboad events
t_cum=0;
for i=1:N
    k=4*(i-1);   % basis for mouse-event index
    simTC((k+1):(k+4),colSeq)=(k+1):(k+4);
    
    simTC(k+1,colTime)=t_cum;          % P1(i) starts 
    simTC(k+1,colKey)=keyP1on;
    simTC(k+2,colTime)=t_cum+durP1(i); % P1(i) ends
    simTC(k+2,colKey)=keyP1off;
    simTC(k+3,colTime)=t_cum+durP1(i); % P2(i) starts when P1(i) ends (no jitter)
    simTC(k+3,colKey)=keyP2on;
    simTC(k+4,colTime)=t_cum+durP1(i)+durP2(i); % P2(i) ends
    simTC(k+4,colKey)=keyP2off;
    
    t_cum=t_cum+durP1(i)+durP2(i);
end

%add RT+RTjitter:
varRTj=power(RTj,2);
muRTj=log(power(meanRT,2)/sqrt(varRTj+power(meanRT,2)));
sigRTj=sqrt(log(1+varRTj/power(meanRT,2)));
% log-normally distributed, jittered RTs:
%    RTj=lognrnd(muRTj,sigRTj,1,N);
simTC(:,2)=simTC(:,2)+[lognrnd(muRTj,sigRTj,1,4*N)]';
%re-sort events by ascending time (time in column 2, columns 3-4 get sorted with it;
%                                  column 1 is event index, leaving unchanged.)
simTC(:,2:4) = sortrows(simTC(:,2:4),1);


