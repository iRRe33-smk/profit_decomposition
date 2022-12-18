V = 10; rho = 2; phi = 4;
[W] = getW(8, V, rho, phi);
A_n = getA_n(0.6, 8);
A_n'*W*A_n
getC(W, 0.6, 8)






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
    end    