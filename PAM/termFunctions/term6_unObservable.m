function [T6RF, T6Common] = term6_unObservable(h,dP, f)
%TERM6 sixth term of PAM -> array[numFinishedProducts]
%   h = holdings, array[nP]
%   dP = daily changes in market prices, observed or calculated, array[nP, nC, nRF +1]
%   f = FX-rates, array[nC]


[nP, nC, nRF] = size(dP);
nRF = nRF -1; %last index is common, passage of time not included for first 6
%H = repmat(h,1,nC);

T6RF = zeros(nP,nC,nRF);
for i=1:nRF
    %T6RF(:,i) = h .* (squeeze(dP(:,:,i)) * f);
    T6RF(:,:,i) = ((h*f') .* squeeze(dP(:,:,i)));

    %
    T6RF(:,:,i) = term6_observable(h,squeeze(dP(:,:,i)),f);
end
%T6Common = h .* (squeeze(dP(:,:,nRF + 1)) * f);
%T6Common = ((h*f') .* squeeze(dP(:,:,nRF+1)));
T6Common = term6_observable(h,squeeze(dP(:,:,nRF+1)),f);
end

%((h * df') .* D)';