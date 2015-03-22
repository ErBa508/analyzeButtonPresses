function TCnew = sortData(TC)

TCnew = TC(:, 2:3);
[d1, d2] = sort(TCnew(:,2));
TCnew = TCnew(d2,:);