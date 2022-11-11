syms f0 f1 f2 f3 f4 f5 f6 t w1 w2 w3 w4 w5 z1 z2 z3 r1 r2 r3 deltaT e1 e2 e3 real
z = [z1;z2;z3];
E = [e1 0 0; 0 e2 0; 0 0 e3];
r = [r1;r2;r3];
f = z'*E*z + w1*((f2 - 2*f1 + f0)/t^2)^2 + w2*((f3 - 2*f2 + f1)/t^2)^2 + w3*((f4 - 2*f3 + f2)/t^2)^2 + w4*((f5 - 2*f4 + f3)/t^2)^2 + w5*((f6 - 2*f5 + f4)/t^2)^2;
f = 0.5*f;
fow = [f0; f1; f2; f3; f4; f5; f6; z] ;
%[A] = getA([1,0,1,0,0,0,1], 7, 3,deltaT);
%con = A*fow
%A'
w = [w1 w2 w3 w4 w5];
W = diag(w);

hessian(f, [f0,f1,f2,f3,f4,f5,f6, z1, z2, z3])
grad = gradient(f, [f0,f1,f2,f3,f4,f5,f6,z1,z2,z3])
%grad - (A_n'*W*A_n)'*fow(1:7)

%gradcon = [gradient(con(1,:), [f0,f1,f2,f3,f4,f5,f6, z1, z2, z3]) gradient(con(2,:), [f0,f1,f2,f3,f4,f5,f6, z1, z2, z3]) gradient(con(3,:), [f0,f1,f2,f3,f4,f5,f6, z1, z2, z3])]
A_n = getA_n(t, 7);
%Hess = getHess(0, 0, t, w,7 , 3, E);



function A_n = getA_n(deltaT, n_f)
    deltaTsq = 1/(deltaT^2);
    A_n = sym('A_n', [n_f - 2, n_f ]);
    for i = 1:n_f-2
        A_n(i, :) = [zeros(1,i-1), deltaTsq, -2*deltaTsq, deltaTsq, zeros(1,n_f-2-i)];
    end
end


function Hess = getHess(~, ~, t, w, n_f, n_r, E)
    Hess = sym('H', [n_f + n_r, n_f + n_r]);
    t = 1/(t^4);
    Hess(1,:) = [2*w(1)*t, -4*w(1)*t, 2*w(1)*t, zeros(1,n_f + n_r - 3)];
    Hess(2,:) = [-4*w(1)*t,  (8*w(1)*t + 2*w(2)*t), (-4*w(1)*t -4*w(2)*t), 2*w(2)*t, zeros(1,n_f + n_r - 4)];
    for row = 3:n_f-2
       Hess(row, :) = [(zeros(1,row-3)) ...
                       (2*w(row-2)*t) ...
                       (-4*w(row-2)*t -4*w(row-1)*t) ...
                       (2*w(row-2)*t +8*w(row-1)*t + 2*w(row)*t) ...
                       (-4*w(row-1)*t -4*w(row)*t) ...
                       (2*w(row)*t) ...
                       (zeros(1,n_f + n_r - 2 - row)) ...
                       ];
    end
    Hess(n_f-1,:) = [zeros(1,n_f - 4), 2*w(n_f-3)*t,  (-4*w(n_f-3)*t -4*w(n_f-2)*t), (2*w(n_f-3)*t + 8*w(n_f-2)*t), -4*w(n_f-2)*t, zeros(1,n_r)];
    Hess(n_f,:) = [zeros(1,n_f - 3), 2*w(n_f-2)*t, -4*w(n_f-2)*t, 2*w(n_f-2)*t, zeros(1,n_r)];
    count = 1;
    for row = n_f+1:n_f + n_r
        Hess(row, row) = 2*E(count,count);
        count = count + 1;
    end


end

function [A] = getA(marketPriceIndeces, n_f, n_r, deltaT)
    A = zeros(n_r, n_f + n_r);
    for row = 1:n_r
        for column = 1:n_f
            if marketPriceIndeces(column) == 1
                A(row, 1:column) = 1/365;
                A(row, n_f + row) = column*1/365;
                marketPriceIndeces(column) = 0;
                break;
            end
        end
    end
end