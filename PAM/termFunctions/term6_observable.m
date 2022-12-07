function T6_observable = term6_observable(h,dP)
%TERM6 sixth term of PAM -> array[nP]
%   h = holdings, array[nP]
%   dP = daily changes in market prices observed in SEK, array[nP] 


%[nP, nC] = size(dP);
%H = repmat(h,1,nC);

T6_observable = h .* dP; %[nP,1]
%T6_observable = H .* dP * f; 

end

