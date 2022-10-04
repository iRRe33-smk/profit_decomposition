function [A_n, n_f] = createA_nMatrix(deltaT)
    n_f = max(size(deltaT)) + 1;
    A_n = zeros(n_f - 2, n_f);
    for i = 1:n_f - 2
        A_n(i, i:i+2) = [(2/((deltaT(i) + deltaT(i+1))*deltaT(i))) (-(2/(deltaT(i) + deltaT(i+1)))*((1/deltaT(i)) + (1/deltaT(i+1)))) (2/((deltaT(i) + deltaT(i+1))*deltaT(i)))];
    end
    
end

