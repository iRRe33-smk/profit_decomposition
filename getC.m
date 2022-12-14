 function [C] = getC(W, dt, n_f)
        dtSq = 1/(dt^3);
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