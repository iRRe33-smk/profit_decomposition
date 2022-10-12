function [T6] = term6(h,dP, f)
%TERM6 sixth term of PAM -> array[TODO]
%   h = holdings, array[nP]
%   dP = daily changes in market prices, observed or calculated, array[nP, nC]
%   f = FX-rates, array[nC]

T6 = h .*  (dP * f);

end

