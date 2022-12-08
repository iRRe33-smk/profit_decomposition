function [T5] = term5(xs_s, xs_b, f)
%TERM5 fifth term of PAM -> array[numCUrr], 
%   x_s , x_b = number of traded units matrix[nC]
%   FX-rates = forex rates of currenciies array[nC]

   T5 =  (xs_s +  xs_b ) .* f;

end

