function [forwardRates, marketPriceIndeces, daysInBtw] = padForwardRates(forwardRates, marketPriceIndeces, daysInBtw, nEvenInBtw)
    daysInBtw = daysInBtw + 1;
    if ~mod(daysInBtw,2); adding = nEvenInBtw + 1; else; adding = nEvenInBtw; end
    if daysInBtw == 1
        forwardRates = [forwardRates(1) 0 forwardRates(2:end)];
        marketPriceIndeces = [marketPriceIndeces(1) 0 marketPriceIndeces(2:end)];
        for day = 2:(daysInBtw + 1):max(size(forwardRates)) + adding
            forwardRates = [forwardRates(1:day+1) 0 forwardRates(day + 2:end)];
            marketPriceIndeces = [marketPriceIndeces(1:day+1) 0 marketPriceIndeces(day + 2:end)];
        end
    else
        forwardRates = [forwardRates(1:daysInBtw) 0 forwardRates(daysInBtw + 1:end)];  
        marketPriceIndeces = [marketPriceIndeces(1:daysInBtw) 0 marketPriceIndeces(daysInBtw + 1:end)];  
        for day = (daysInBtw + 2):(daysInBtw + 1):max(size(forwardRates)) + adding
            forwardRates = [forwardRates(1:day+1) 0 forwardRates(day + 2:end)];
            marketPriceIndeces = [marketPriceIndeces(1:day+1) 0 marketPriceIndeces(day + 2:end)];
        end
    end

end

