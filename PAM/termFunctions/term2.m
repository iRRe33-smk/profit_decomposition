function [T2] = term2(h_c, R, df )
%TERM2 second term of PAM -> vector[numCurrencies]
%   h_c holdings of the currencies. Note only currency holdings are passed
%   R ON-interest returns ~1
%   df  changes in FX-rate to base currency
    T2 = h_c' .* R' * df;
end

