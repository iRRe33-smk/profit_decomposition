
function [h_p_finished,h_p_raw, h_c, xsProd_s, xsProd_b, xsCurr_b,  P_raw, dP_raw, R, f, df, deltaT, numProducts, numCurrencies] = initializeDatastructures(numProductsFinished,numProductsRaw, numCurrencies)

numProducts = numProductsFinished + numProductsRaw;
%numCurrencies = length(currencies);

h_p_finished = rand(numProductsFinished,1);
h_p_raw = rand(numProductsRaw,1);
h_c = rand(numCurrencies, 1);


xsProd_b = rand(numCurrencies,1);
xsProd_s = rand(numCurrencies,1);

xsCurr_b = rand(numCurrencies,1);

R = rand(numCurrencies,1);
deltaT = rand(numCurrencies,1);
f = rand(numCurrencies,1);
df = rand(numCurrencies,1);

%D = rand(numProducts,numCurrencies); % dividends in this timestep
P_raw = rand(numProducts, numCurrencies); % match with currency

dP_raw = ones(numProductsRaw,1) * (1/365); %daily Price Differences for Observed Prices all expressed in SEK
end



