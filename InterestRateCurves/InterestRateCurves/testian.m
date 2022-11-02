syms f0 f1 f2 f3 f4 f5 f6 t w1 w2 w3 w4 w5
f = w1*((f2 - 2*f1 + f0)/t^2)^2 + w2*((f3 - 2*f2 + f1)/t^2)^2 + w3*((f4 - 2*f3 + f2)/t^2)^2 + w4*((f5 - 2*f4 + f3)/t^2)^2 + w5*((f6 - 2*f5 + f4)/t^2)^2;

hessian(f, [f0,f1,f2,f3,f4,f5,f6])