function [T3] = term3(h, D, df)
%TERM3 third term of PAM -> vector[numFinishedProducts]
%   h = holdings
%   D = dividends
%   df = daily changes of FX-rate

T3 = h .* (D * df);



%[nP, nC] = size(D);

%H = repmat(h,1,nC);
%dF = repmat(df',nP,1);

%disp("%%%%%%%%%")
%disp(size(H))
%disp(size(D))
%disp(size(dF))

%T3 = sum(H.* D.* dF, 2);
%disp(size(T3))



end

