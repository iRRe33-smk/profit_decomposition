function [T3] = term3(h, D, df, t, T_max)
%TERM3 third term of PAM -> vector[numCurr x numFinishedProducts]
%   h = holdings
%   D = dividends
%   df = daily changes of FX-rate


%T3 = ((h * df') .* D)';

%[nP, nC] = size(D);

%H = repmat(h,1,nC);
%dF = repmat(df',nP,1);
 
T3 = ones(size(D,[2,1]));
for i = t:T_max
    T3_i = term6_observable(h,squeeze(D(:,:,i)),df)';
    %T3_i = ((h * df') .* squeeze(D(:,:,i)))';
T3 = T3 + T3_i;



end


end

