function [T1] = term1(h_c, R, f, deltaT)
%TERM1 first term of PAM -> vector[numCurrencies]
%   h_c holdings of the currencies. Note only currency holdings are passed
%   R ON-interest returns ~1
%   f  FX-rate to base currency

    T1 = h_c .* (R - 1).* f;


end

