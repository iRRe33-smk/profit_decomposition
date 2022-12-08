function T6_observable = term6_observable(h,dP)
%TERM6 sixth term of PAM -> array[numRawProducts]
%   h = holdings, array[nP]
%   dP = daily changes in market prices observed in SEK, array[nP] 



T6_observable = h .* dP;

end

