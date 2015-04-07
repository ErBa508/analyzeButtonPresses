function [bestLag, bestR] = autocorrelation(TC, FR, string)
%%% Autocorrelation, also known as serial correlation, is the
%%% cross-correlation of a signal with itself. Informally, it is the
%%% similarity between observations as a function of the time lag between
%%% them. It is a mathematical tool for finding repeating patterns, such as
%%% the presence of a periodic signal obscured by noise, or identifying the
%%% missing fundamental frequency in a signal implied by its harmonic
%%% frequencies. It is often used in signal processing for analyzing
%%% functions or series of values, such as time domain signals.

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



