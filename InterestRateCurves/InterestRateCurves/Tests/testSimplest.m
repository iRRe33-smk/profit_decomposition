clear

syms  f1 f2 f3 f4 z1 z2 real
x = [f1 f2 f3 f4 z1 z2]';
f = x(1:4);
z = x(5:6);
A_1 = [1 1 0 0 ; 
       1 1 1 0];
A_2 = [1 0; 
       0 1];

constraint = @(x) A_1*x(1:4) + A_2*x(5:6);
grad = gradient( A_1*f + A_2*z, x')
   

