function [A_s, B_s, C_s] = matrixGeneration(e, T , n_f, n_r, dt, C)
    %%% Generate all matrices described in tech. doc. and return what is
    %%% necessary to calculate the forward curve
    marketPriceIndeces = zeros(n_f, 1);
    for i = 1:length(T)
        marketPriceIndeces(T(i)) = 1;
    end
    E = e*eye(n_r);
    [A, F] = getAandF(marketPriceIndeces, n_f, n_r, dt);
    K = C + A'*E*A;
    U = A'*E;
    R = chol(K);
    A_s = R\(R'\(U));
    B_s = -F\A;
    C_s = inv(F);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %              Functions              %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function A_n = getA_n(deltaT, n_f)
        deltaTsq = 1/(deltaT);
        A_n = zeros(n_f-2, n_f);
        for i = 1:n_f-2
            A_n(i, :) = [zeros(1,i-1), deltaTsq, -2*deltaTsq, deltaTsq, zeros(1,n_f-2-i)];
        end
    end
    
    function [A, F] = getAandF(marketPriceIndeces, n_f, n_r, deltaT)
        A = zeros(n_r, n_f);
        F = zeros(n_r, n_r);
        A(:,1) = deltaT;
        for row = 1:n_r
            for column = 1:n_f
                if marketPriceIndeces(column) == 1
                    A(row, 1:column-1) = deltaT;
                    F(row, row) = deltaT*column;
                    marketPriceIndeces(column) = 0;
                    break;
                end
            end
        end
    end
end