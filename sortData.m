function TCnew = sortData(TC)

TCnew = TC(:, 2:3); % TCnew == 2nd and 3rd cols
[~, d2] = sort(TCnew(:,2)); % sort by button press value and d2 == indices
TCnew = TCnew(d2,:); % sort time course by indices