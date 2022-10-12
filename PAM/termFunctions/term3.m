function [T3] = term3(h, D, df)
%TERM3 third term of PAM -> vector[numProducts]
%   h = holdings
%   D = dividends
%   df = daily changes of FX-rate


szD = size(D);
numCurrencies = szD(2);

T3 = zeros(numCurrencies,1);
for c = 1:numCurrencies
    T3 = T3 + D(:,1,c) * df(c);

end



end

