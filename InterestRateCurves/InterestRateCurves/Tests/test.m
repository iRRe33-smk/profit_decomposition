syms f0 f1 f2 f3 f4 f5 f6 z1 z2 lam1 lam2 dt w1 w2 w3 w4 w5 e1 e2 d1 d2 real

w = [w1 w2 w3 w4 w5];
W = diag(w);
b = [-d1 -d2]';
x = [f0 f1 f2 f3 z1 z2]';
f = [f0 f1 f2 f3 f4 f5 f6]';
z = [z1 z2]';
A = [dt 0 0 0;
     dt dt dt dt];
F = [dt 0;
     0 3*dt];
A_n = getA_n(dt, 7);
E = [e1 0; 0 e2];
fun = f'*A_n'*W*A_n*f + z'*E*z;
%constraints = A*f + F*z - b;
lambda = [lam1 lam2];
%lagrangian = fun - lambda*constraints;
C = A_n'*W*A_n;
% lagrangianGrad = gradient(lagrangian, [x; lambda'])
% 
% [A1,B1] = equationsToMatrix(lagrangianGrad(1:4), f)
% [A2,B2] = equationsToMatrix(lagrangianGrad(5:6), z)
% [A3,B3] = equationsToMatrix(lagrangianGrad(7:8), z)
% %hessian(lagrangian, x)
% 
% eq = C*f + A'*(inv(F)*inv(E)*inv(F)*(A*f-b))
% [A4,B4] = equationsToMatrix(eq, f)








function A_n = getA_n(deltaT, n_f)
        deltaTsq = 1/(deltaT^2);
        A_n =sym('A_n',[n_f-2, n_f]); 
        for i = 1:n_f-2
            A_n(i, :) = [zeros(1,i-1), deltaTsq, -2*deltaTsq, deltaTsq, zeros(1,n_f-2-i)];
        end
        A_n = A_n*deltaT;
    end