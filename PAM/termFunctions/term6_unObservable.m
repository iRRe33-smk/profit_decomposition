function [T6RF, T6Common] = term6_unObservable(h,dP, f)
%TERM6 sixth term of PAM -> array[nP]
%   h = holdings, array[nP]
%   dP = daily changes in market prices, observed or calculated, array[nP, nC, nRF +1]
%   f = FX-rates, array[nC]


[nP, nC, nRF] = size(dP);
nRF = nRF -1; %last index is common, passage of time not included for first 6
H = repmat(h,1,nC);

T6RF = zeros(nP,nRF);
for i=1:nRF
    T6RF(:,i) = H .* squeeze(dP(:,:,i)) * f; 
end
T6Common = H .* squeeze(dP(:,:,nRF+1)) * f; %[nP,1]
end

