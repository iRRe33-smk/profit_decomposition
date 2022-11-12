function [A_s, B_s, C_s] = eqSystemIRCcopy(e, T , n_f, n_r, dt)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %    Calculate constant expressions   %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    marketPriceIndeces = zeros(n_f, 1);
    for i = 1:length(T)
        marketPriceIndeces(T(i)) = 1;
    end
    A_n = getA_n(dt, n_f);
    V = 10; rho = 2; phi = 4;
    W = getW(n_f, V, rho, phi);
    E = e*eye(n_r);
    [A, F] = getAandF(marketPriceIndeces, n_f, n_r, dt);
    R = chol(A_n'*W*A_n + A'*pinv(F)*E*pinv(F)*A);
    A_s = R\(R'\(A'*pinv(F)*E*pinv(F)));
    B_s = -inv(F)*(A);
    C_s = inv(F);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %              Functions              %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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

    function [A_n] = getA_n(deltaT, n_f)
        deltaTsq = 1/(deltaT^2);
        A_n = zeros(n_f-2, n_f);
        for i = 1:n_f-2
            A_n(i, :) = [zeros(1,i-1), deltaTsq, -2*deltaTsq, deltaTsq, zeros(1,n_f-2-i)];
        end
        A_n = A_n*deltaT;
    end

    function [W] = getW(n_f, V, rho, phi)
       W = zeros(n_f-2,1);
       for t = 1:n_f-2
           if t <= 365
               W(t) = V*exp((t/365 - rho)*log(phi));
           else
               W(t) = V;
           end
       end
       W = diag(W);
    end
end