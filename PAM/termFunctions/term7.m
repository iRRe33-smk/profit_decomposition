function [T7] = term7(h, P, D, f, df)
%TERM7 seventh term of PAM -> array[nP]
%   TODO error-termen tas ej med här. Gör separat funktion för den.
%   Antar att vi vill hålla den separat för att kunna bdöma felet.
%   h = holding
%   D = dividends
%   f = FX-rates
%   df = daily change in FX-rates
%

T7 = h .* ( P - D * f ) * df;


end

