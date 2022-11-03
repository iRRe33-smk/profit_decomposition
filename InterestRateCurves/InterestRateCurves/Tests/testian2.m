syms f0 f1 f2 f3 f4 f5 f6 w1 w2 w3 w4 w5 z1 z2 z3 r1 r2 r3 deltaT e1 e2 e3 d1 d2 d3 real
x = [f0 f1 f2 f3 f4 f5 f6 z1 z2 z3]';
marketPriceIndeces = [1 0 0 1 0 0 1];
A = getA(marketPriceIndeces, 7, 3, 365);
B = -[log(d1); log(d2); log(d3)];
A*x 
B

function A = getA(marketPriceIndeces, n_f, n_r, deltaT)
    A = sym('A_n', [n_r, n_r + n_f ]);
    A = A*0;
    for row = 1:n_r
        for column = 1:n_f
            if marketPriceIndeces(column) == 1
                A(row, 1:column) = 1/deltaT;
                A(row, n_f + row) = column/deltaT;
                marketPriceIndeces(column) = 0;
                break;
            end
        end
    end
end