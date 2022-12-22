function [T7] = term7(h, P, D, f, df, t, T_max)
%TERM7 seventh term of PAM -> array[nP]
%   TODO error-termen tas ej med här. Gör separat funktion för den.
%   Antar att vi vill hålla den separat för att kunna bdöma felet.
%   h = holding, array[nP]
%   P = price of products in h, matrix[nP,nC]
%   Dt = dividends paid out in this timestep, matrix[nP, nC]
%   f = FX-rates, array[nC]
%   df = daily change in FX-rates, array[nC]




%T7 = h .* ((P - Dt) * df);
%h = min(h,1);
%Dsum = sum(D(:,:,t:T_max),3);

T7 = term6_observable(h,(P-D(:,:,t)),df)';

%T7 = term6_observable(h,(P-D),df)';



end

