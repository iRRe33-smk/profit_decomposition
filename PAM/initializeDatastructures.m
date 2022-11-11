function [h, x_s, x_b, s_s, s_b, P, dP, R, f, df, deltaT, D, numProducts, numCurrencies] = initializeDatastructures()


%productTypes = ["mutter","skruv","plåt","borrig", "pump"];
%currencies = ["SEK", "USD", "EUR", "GBP"];



assetIDN = 1:7;
currencies = 1:2;

%N = 1000; %max number of holdings




numProducts = length(assetIDN);
numCurrencies = length(currencies);

h = rand(numProducts,1); 

x_b = rand(numProducts,numCurrencies); %ReadData
x_s = rand(numProducts,numCurrencies); %ReadData
s_s = rand(numProducts,numCurrencies); %PriceList[typeID ,PriceListID]
s_b = rand(numProducts,numCurrencies); %PriceList[typeID ,PriceListID]

BOM = randi(3,numProducts); % zeroes if bought/sold product, relation between input and output if manufacture ex (3 bolt, 1 plate -> borrig)

R = rand(numCurrencies,1);
deltaT = rand(numCurrencies,1);
f = rand(numCurrencies,1);
df = rand(numCurrencies,1);

D = rand(numProducts,numCurrencies); % dividends in this timestep
P = rand(numProducts, numCurrencies); % match with currency
dP = rand(numProducts, numCurrencies);
end



