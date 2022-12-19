function [newSalesIndex] = newSales(D, prevD)
    diffrence = D - prevD;
    [r,c,v] = ind2sub(size(diffrence),find(diffrence ~= 0));
    newSalesIndex = [r,c,v];
end