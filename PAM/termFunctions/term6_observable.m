function T6_observable = term6_observable(h,dP, f)
%TERM6 sixth term of PAM -> array[nP]
%   h = holdings, array[nP]
%   dP = daily changes in market prices observed, array[nP, nC]
%   f = FX-rates, array[nC]


[nP, nC] = size(dP);
H = repmat(h,1,nC);


T6_observable = H .* dP * f; 

end

