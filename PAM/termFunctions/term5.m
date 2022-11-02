function [T5] = term5(s_s,  x_s, s_b, x_b, f)
%TERM5 fifth term of PAM -> array[nP], this then has to be summed over
%indicies belonging to each department
%   s_s , s_b = transaction costs per unit matrix[nP, nC]
%   x_s , x_b = number of traded units matrix[nP, nC]
%   FX-rates = forex rates of currenciies array[nC]

   T5 =  (s_s .* x_s + s_b .* x_b ) * f;

end

