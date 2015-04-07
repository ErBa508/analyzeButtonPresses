function [bestLag, bestR, r0_1, r0_2] = crossCorrelation(TC1, TC2, FR, string)
%%% In signal processing, cross-correlation is a measure of similarity of
%%% two series as a function of the lag of one relative to the other. This
%%% is also known as a sliding dot product or sliding inner-product. It is
%%% commonly used for searching a long signal for a shorter, known feature.
%%% In probability and statistics, the term cross-correlations is used for
%%% referring to the correlations between the entries of two random vectors
%%% X and Y.

% simulations need to be the same length (like behavioral data)
if length(TC1) > length(TC2)
    endFr = length(TC2);
else
    endFr = length(TC1);
end

% need to normalize 'numerator' values by mean of each TC before using xcorr
normTC1 = TC1(1:endFr) - mean(TC1(1:endFr));
normTC2 = TC2(1:endFr) - mean(TC2(1:endFr));

% cross-corr betw TC1 & TC2
% 'Coeff' normalizes r values by dividing r by "sqrt(sum(abs(a).^2)*sum(abs(b).^2))"
[r, lagVec] = xcorr( normTC1 , normTC2 , 'coeff');

%[r, lagVec] = xcorr( TC1(1:endFr) , TC2(1:endFr) ); 
[~,I] = max(abs(r)); % find index of row with max correlation coeff
bestLag = lagVec(I)/FR; % find lag (s) at that index (after divide by frame rate)
[~, ind] = max(abs(r));
bestR = r(ind);
r0_1 = xcorr( normTC1, normTC2, 0,  'coeff');  %return r-coeff when lag is 0 s

% plot cross-correlation
figure()
str = sprintf('Cross-correlation is for %s; best lag is %.1f s; best r is %.2f', string, bestLag, bestR);
plot(lagVec/FR,r, '.') % lags are in seconds
title(str)
xlabel('Lag in seconds')
ylabel('Normalized r value')

% check cross-correlation results
% correlation test = mean((TC1-mean(TC1)).*(TC2-mean(TC2)))/(std(TC1)*std(TC2))
r0_2 = corrcoef(TC1(1:endFr),TC2(1:endFr)); % return r-coeff when lag is 0 s
r0_2 = r0_2(2);
