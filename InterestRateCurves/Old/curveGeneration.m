function [f, z] = curveGeneration(discountFactors, T, e)
    dim = size(discountFactors);
    n_r = length(T);
    n_curves = dim(2);
    n_f = T(end);
    dt = 1/365;
    logDiscountFactors = -log(discountFactors);
    logDiscountFactors = logDiscountFactors(1:n_r, :);
    if n_r ~= length(T)
        error('The number of maturities must match the number of given market prices')
    end
    [A_s, B_s, C_s] = matrixGeneration(e, T , n_f, n_r, dt);
    f = zeros(n_f, n_curves);
    z = zeros(n_r, n_curves);
    for i = 1:n_curves
        f(:,i) = A_s*logDiscountFactors(:, i);
        z(:,i) = 10000*(B_s*(f(:,i)) + C_s*logDiscountFactors(:, i));
    end
end