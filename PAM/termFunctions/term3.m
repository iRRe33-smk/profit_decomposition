function [T3] = term3(h, D, df)
%TERM3 third term of PAM -> vector[numProducts]
%   h = holdings
%   D = dividends
%   df = daily changes of FX-rate


[nP, nC] = size(D);

H = repmat(h,1,nC);
dF = repmat(df',nP,1);

T3 = H.* D.* dF;



end

