function [error_f] = termError(dP, df, numProducts)
% termError -> array[numProducts x numRiskFactors + 1]

[nP_unObserved,nC,nRF] = size(dP); %only unobserved priceChanges

error_f = zeros(numProducts,nRF);
for i=1:nRF
    error_f(1:nP_unObserved ,i) = squeeze(dP(:,:,i)) * df;
end
dP_tot = squeeze(dP(:,:,10));
error_f = dP_tot * df;
error_f(nP_unObserved+1:numProducts,:) = 0;
end

