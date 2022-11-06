clear
syms f0 f1 f2 f3 f4 w1 w2 w3 d1 d2 d3 dt e positive
syms z1 z2 z3 LD1 LD2 LD3 real

f = [f0 f1 f2 f3 f4]';
z = [z1 z2 z3]';
x = [f; z];
E = [e 0 0; 0 e 0; 0 0 e];
A = (1/dt)*[1 0 0 0 0 1 0 0;
            1 1 1 0 0 0 3 0;
            1 1 1 1 1 0 0 5];
B = [-log(d1); -log(d2); -log(d3)];
obj = w1*((f2 - 2*f1 + f0)/1^2)^2 + ...
      w2*((f3 - 2*f2 + f1)/1^2)^2 + ...
      w3*((f4 - 2*f3 + f2)/1^2)^2 + ...
      z'*E*z;
con = A*x - B;
conScalar = -LD1*gradient(con(1), x) - LD2*gradient(con(2), x) - LD3*gradient(con(3), x);
objGrad = gradient(obj, x);
eq1 = objGrad + conScalar == 0;
eq2 = con == 0;
[A,B] = equationsToMatrix([eq1', eq2'], [x', LD1, LD2, LD3])


eq2 = g(2) == 0;
eq3 = g(3) == 0;
eq4 = g(4) == 0;
eq5 = g(5) == 0;
eq6 = g(6) == 0;
eq7 = g(7) == 0;
eq8 = g(8) == 0;
eq9 = g(9) == 0;
eq10 = g(10) == 0;
eq11 = g(11) == 0;

[A, B] = equationsToMatrix([eq1, eq2, eq3, eq4, eq5, eq6, eq7, eq8, eq9, eq10, eq11], [LD1 LD2 LD3])

[eq1, eq2, eq3, eq4, eq5, eq6, eq7, eq8, eq9, eq10, eq11]
