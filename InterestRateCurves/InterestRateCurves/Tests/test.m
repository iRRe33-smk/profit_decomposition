syms f0 f1 f2 f3 z1 z2 lam1 lam2 dt real

f = f0^2 - 4*f1^2 + f2 + 3*f3 -z1^2 + 4*z2;
g1 = f0 + f1 + z1 - 3 ;
g2 = f2 + f3 + z2 - 2 ;
x = [f0 f1 f2 f3 z1 z2]';
lagrangian = f - lam1*g1 - lam2*g2;
lagrangianGrad = gradient(lagrangian, [x ; lam1; lam2])

[A,B] = equationsToMatrix(lagrangianGrad, [x ; lam1; lam2])
hessian(lagrangian, x)