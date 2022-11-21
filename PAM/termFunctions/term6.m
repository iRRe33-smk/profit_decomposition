function [T6] = term6(h,dP, f)
%TERM6 sixth term of PAM -> array[nP]
%   h = holdings, array[nP]
%   dP = daily changes in market prices, observed or calculated, array[nP, nC]
%   f = FX-rates, array[nC]


[nP, nC, nRF] = size(dP);

H = repmat(h,1,nC);

T6 = zeros(nP,nRF);
for i=1:nRF
    T6(:,i) = H .* squeeze(dP(:,:,i)) * f; 
end

end

