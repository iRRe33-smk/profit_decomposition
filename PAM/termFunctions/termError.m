function [error_f] = termError(dP, df)


[nP,nC,nRF] = size(dP);

error_f = zeros(nP,nRF);
for i=1:nRF
    error_f(: ,i) = squeeze(dP(:,:,i)) * df;
end
end

