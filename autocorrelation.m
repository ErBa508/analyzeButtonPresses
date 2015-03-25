function [bestLag, bestR] = autocorrelation(TC, FR, string)

[r, lagVec] = xcorr( TC , 'coeff');
[~,I] = max(abs(r)); % find index of row with max correlation coeff
bestLag = lagVec(I)/FR; % find lag (s) at that index (after divide by frame rate)
[~, ind] = max(abs(r));
bestR = r(ind);

% plot autocorrelation
figure()
str = sprintf('Autocorrelation variable is %s; best lag is %.1f s; best r is %.2f', string, bestLag, bestR);
plot(lagVec/FR,r) % lags are in seconds
title(str)
xlabel('Lag in seconds')
ylabel('Normalized r value')



