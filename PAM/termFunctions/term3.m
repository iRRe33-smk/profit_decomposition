function [T3] = term3(h, D, df)
%TERM3 third term of PAM -> vector[numCurr x numFinishedProducts]
%   h = holdings
%   D = dividends
%   df = daily changes of FX-rate


T3 = ((h * df') .* D)';

%[nP, nC] = size(D);

%H = repmat(h,1,nC);
%dF = repmat(df',nP,1);




end

