function [A_s, B_s, C_s] = matrixGeneration(e, T , n_f, n_r, dt)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %    Calculate constant expressions   %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    marketPriceIndeces = zeros(n_f, 1);
    for i = 1:length(T)
        marketPriceIndeces(T(i)) = 1;
    end
    V = 10; rho = 2; phi = 4;
    W = getW(n_f, V, rho, phi);
    E = e*eye(n_r);
    [A, F] = getAandF(marketPriceIndeces, n_f, n_r, dt);
    C = getC(W, dt, n_f);
    %A_n = getA_n(dt, n_f);
    %C = A_n'*W*A_n;
    K = C + A'*E*A;
    U = A'*E;
    R = chol(K);
    A_s = R\(R'\(U));
    %A_s = K\U;
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
    
    
    function [C] = getC(W, dt, n_f)
        dtSq = 1/(dt^2);
        w = diag(W);
        C = zeros(n_f, n_f);
        C(1, :) = [w(1)*dtSq, -(2*w(1)*dtSq), w(1)*dtSq, zeros(1, n_f-3)];
        C(2, :) = [-2*w(1)*dtSq, 4*w(1)*dtSq + w(2)*dtSq, (-2*w(1)*dtSq -2*w(2)*dtSq), w(2)*dtSq, zeros(1, n_f-4)];
        for row = 3:n_f-2
            C(row, :) = [ zeros(1, row-3) ...  
                         (w(row-2)*dtSq)...
                         (-2*w(row-2)*dtSq -2*w(row-1)*dtSq)...
                         (w(row-2)*dtSq + (4*w(row-1))*dtSq + w(row)*dtSq)...
                         (-2*w(row-1)*dtSq -2*w(row)*dtSq)...
                         (w(row)*dtSq)...
                          zeros(1, n_f - row - 2)];
        end
        C(n_f-1, :) = [zeros(1, n_f-4), w(n_f-3)*dtSq, (-2*w(n_f-3)*dtSq -2*w(n_f-2)*dtSq) , (w(n_f-3)*dtSq + 4*w(n_f-2)*dtSq), -2*w(n_f-2)*dtSq];  
        C(n_f, :)   = [zeros(1, n_f-3), w(n_f-2)*dtSq, -(2*w(n_f-2)*dtSq), w(n_f-2)*dtSq];
        
        
        %C = C./dt;
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