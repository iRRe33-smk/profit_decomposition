function [T, n_r, discountFactors] = getDayData(T, discountFactors)
    count = 1;
    for i = 1:numel(T)
        if isnan(discountFactors(i)) || discountFactors(i) == 0 || isinf(discountFactors(i))
            continue;
        else
            newT(count) = T(i);
            newDiscountFactors(count) = discountFactors(i);
            count = count + 1;
        end
    end
    n_r = numel(newT);
    discountFactors = newDiscountFactors;
    T = newT;
end