function [T6] = term6(h,dP, f)
%TERM6 sixth term of PAM -> array[nP]
%   h = holdings, array[nP]
%   dP = daily changes in market prices, observed or calculated, array[nP, nC]
%   f = FX-rates, array[nC]


[nP, nC] = size(dP);

H = repmat(h,1,nC);
F = repmat(f',nP,1);

T6 = H.* dP .* F;

end

