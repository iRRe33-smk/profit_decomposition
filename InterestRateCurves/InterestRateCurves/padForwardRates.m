function [forwardRates, marketPriceIndeces, daysInBtw] = padForwardRates(forwardRates, marketPriceIndeces, daysInBtw);
    daysInBtw = daysInBtw + 1;
    if daysInBtw == 1
        
    for day = 1:max(size(forwardRates))-1
        forwardRates = [forwardRates(1:daysInBtw*day) 0 forwardRates(daysInBtw*day+daysInBtw:end)];
    end
    
end

