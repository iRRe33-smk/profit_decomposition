clear
syms f0 f1 f2 f3 f4 w1 w2 w3 d1 d2 d3 dt e real
syms z1 z2 z3 LD1 LD2 LD3 real

f = [f0 f1 f2 f3 f4]';
W = [w1 0 0; 0 w2 0; 0 0 w3];
E = [e 0 0; 0 e 0; 0 0 e];
z = [z1 z2 z3]';

A_n = getA_n(dt, 5);

h = 0.5*f'*A_n'*W*A_n*f + 0.5*z'*E*z ;

hess = hessian(h, [f' z'])
A_n'*W*A_n


function A_n = getA_n(deltaT, n_f)
        deltaTsq = 1/(deltaT^2);
        A_n = sym('A_n',   [n_f-2, n_f]);
        for i = 1:n_f-2
            A_n(i, :) = [zeros(1,i-1), deltaTsq, -2*deltaTsq, deltaTsq, zeros(1,n_f-2-i)];
        end
end
