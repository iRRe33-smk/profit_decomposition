[forwardRates, spotRates, T, daysInBtw] = getForwAndSpot();
forwardRates = forwardRates(1,:);
%marketPriceIndeces = ones(size(forwardRates));

[forwardRates, marketPriceIndeces, daysInBtw] = padForwardRates(forwardRates, [], 0);
forwardRates
[forwardRates, marketPriceIndeces, daysInBtw] = padForwardRates(forwardRates, [], 1);
forwardRates
%[Q] = createQMatrix(forwardRates, deltaT);


