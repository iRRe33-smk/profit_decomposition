function T6_observable = term6_observable(h,dP,f)
%TERM6 sixth term of PAM -> array[numRawProducts]
%   h = holdings, array[nP]
%   dP = daily changes in market prices observed in SEK, array[nP] 
%   f = currency Exchange rates


T6_observable_old = h .* (dP * f);
T6_observable = ((h*f') .* dP);

[nP, nC] = size(dP);
T6_observable = zeros(nP,nC);

for p = 1:nP
    for c = 1:nC
        T6_observable(p,c) = T6_observable(p,c) + h(p) * dP(p,c) * f(c);
    end

end
disp("max difference is T6 ")
disp(norm(T6_observable - T6_observable_old, "inf"))


end

