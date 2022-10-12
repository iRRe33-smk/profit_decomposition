function [h, x_s, x_b, P, R, f, deltaT, S,  Dividends] = initializeDatastructures()




N = 1000; %max number of holdings

numProducts = length(assetIDN);
numCurrencies = length(currencies);

h = zeros(N,2); 

x_b = zeros(numProducts,numCurrencies); %ReadData
x_s = zeros(numProducts,numCurrencies); %ReadData
s_s = zeros(numProducts,numCurrencies); %PriceList[typeID ,PriceListID]
s_b = zeros(numProducts,numCurrencies); %PriceList[typeID ,PriceListID]

BOM = eye(numProducts); % zeroes if bought/sold product, relation between input and output if manufacture ex (3 bolt, 1 plate -> borrig)

R = zeros(numCurrencies,1);
deltaT = zeros(numCurrencies,1);
f = zeros(numCurrencies,1);

Dividends = zeros(N,1,numCurrencies); % middle index:T = time until dividend
P = zeros(N,1); % match with currency

end



