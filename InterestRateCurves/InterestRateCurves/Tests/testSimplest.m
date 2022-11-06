clear

syms  w1 e d1 d2 dt lambda1 lambda2 real
f = sym('f', [5, 1],'real');
z = sym('z', [2, 1], 'real');
A = [1 0 0 0 0 1 0;
     1 1 1 1 0 0 1];
dt = 1;
e = [2 0;
     0 1];
d1 = exp(1);
d2 = exp(1)^2;
w = [1 0 0;
     0 1 0;
     0 0 1];
x = [f;
     z];
A_n = getA_n(dt, 5);
h = f'*A_n'*w*A_n*f + z'*e*z;
b = [-log(d1); -log(d2)];
con = A*x - b;
lagrangian = h - lambda1*con(1) - lambda2*con(2);
[x', lambda1, lambda2]
gradLagrangian = gradient(lagrangian, [x', lambda1, lambda2]);
[A,B] = equationsToMatrix(gradLagrangian', [x' lambda1 lambda2])
hessian(lagrangian, [x'])
2*A_n'*w*A_n
function A_n = getA_n(deltaT, n_f)
        deltaTsq = 1/(deltaT^2);
        A_n = zeros(n_f-2, n_f);
        for i = 1:n_f-2
            A_n(i, :) = [zeros(1,i-1), deltaTsq, -2*deltaTsq, deltaTsq, zeros(1,n_f-2-i)];
        end
end
   

