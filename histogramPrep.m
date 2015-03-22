function [histA, histB, bins] = histogramPrep(durA, durB, binw)

% not sure how this calculation was determined yet...
% tmp=floor((size(durA,1)+size(durB,1))/(2*minItemsPerBin));

% for hist - want at most 15 bins and at min 5 bins
% if tmp > maxNumBins
%     numBins = maxNumBins;
% else
%     numBins = max((tmp),minNumBins);
% end

% calculate max and min domin duration
tmpmin=min(min(durA),min(durB));
tmpmax=max(max(durA),max(durB));

% calculate bin width
%binw=(tmpmax-tmpmin)/numBins;


bins=tmpmin:binw:tmpmax;     % note length(bins) is numBins+1 but last element in histc will be 0
if bins(end) < tmpmax
   bins(end + 1) = bins(end) + binw; 
end

histA = histc(durA,bins); % counts # of values WITHIN specified bin range and so need to inc range to one more than max
histB = histc(durB,bins);


