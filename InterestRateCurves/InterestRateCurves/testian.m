syms f0 f1 f2 f3 f4 f5 f6 t w1 w2 w3 w4 w5 z1 z2 z3 r1 r2 r3
z = [z1;z2;z3];
E = [4 0 0; 0 4 0; 0 0 4];
r = [r1;r2;r3];
f = z'*E*z + w1*((f2 - 2*f1 + f0)/t^2)^2 + w2*((f3 - 2*f2 + f1)/t^2)^2 + w3*((f4 - 2*f3 + f2)/t^2)^2 + w4*((f5 - 2*f4 + f3)/t^2)^2 + w5*((f6 - 2*f5 + f4)/t^2)^2;
fow = [f0; f1; f2; f3; f4; f5; f6];
[A] = getA([1,0,1,0,1,0,1], 7, 3);
con = A*fow + z - r;
%A'

hessian(f, [f0,f1,f2,f3,f4,f5,f6, z1, z2, z3])
gradient(f, [f0,f1,f2,f3,f4,f5,f6, z1, z2, z3])
gradcon = [gradient(con(1,:), [f0,f1,f2,f3,f4,f5,f6, z1, z2, z3]) gradient(con(2,:), [f0,f1,f2,f3,f4,f5,f6, z1, z2, z3]) gradient(con(3,:), [f0,f1,f2,f3,f4,f5,f6, z1, z2, z3])]


function [A] = getA(marketPriceIndeces, n_f, n_r)
    A = zeros(n_r, n_f);
    for row = 1:n_r
        for column = 1:n_f
            if marketPriceIndeces(column) == 1
                A(row, column) = 1;
                marketPriceIndeces(column) = 0;
                break;
            end
        end
    end 
end