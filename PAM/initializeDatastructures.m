
function [h_p_finished,h_p_raw, h_c, xs_s, xs_b, P, dP_raw, R, f, df, deltaT, D, numProducts, numCurrencies] = initializeDatastructures(numProds, numCurrs, numRFs)

assetIDN = 1:numProds;
currencies = 1:numCurrs;

numProducts = length(assetIDN);
numProductsFinished = round(numProducts * .8);
numProductsRaw = numProducts - numProductsFinished;

numCurrencies = length(currencies);
%numRiskFactors = numRFs;



h_p_finished = rand(numProductsFinished,1);
h_p_raw = rand(numProductsRaw,1);
h_c = rand(numCurrencies, 1);


xs_b = rand(numCurrencies,1);
xs_s = rand(numCurrencies,1);

R = rand(numCurrencies,1);
deltaT = rand(numCurrencies,1);
f = rand(numCurrencies,1);
df = rand(numCurrencies,1);

D = rand(numProducts,numCurrencies); % dividends in this timestep
P = rand(numProducts, numCurrencies); % match with currency
dP_raw = rand(numProductsRaw, numCurrencies);
end



