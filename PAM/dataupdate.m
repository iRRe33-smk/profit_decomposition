%% Datauppdatering

function [h, x_s, x_b, P, R, f, deltaT, S,  Dividends] = dataupdate(h, x_s, x_b, P, R, f, deltaT, S,  Dividends,currencies)

% mängder:
%     assetIDN I
%     currencies C
%     timeSpan T
% 
% variabler:
%     numProducts = length(assetIDN)
%     numCurrencies = length(currencies)
%     numTimesteps = length(T)
%     
%     BOM: matrix(numProducts x numProducts)
%     ASSETS: { ID : int,
%             indicies : array[<numProdcuts],
%             currencyID : int}
%  h = array[] int
%     deltaT = array[numCurrencies] float
%     S = matrix(numProducts x numCurrencies) float
%     f = array[1 + numCurrencies] första index är 1 ty ingen enhet för assets
%     R = matrix(numCurrencies x numTimesteps) float
%     P = array[] float, samma längd som h
%     x_s = array[] float, samma längd som h
%     x_b = array[] float, samma längd som h
%     Dividends = matrix[length(h) x Timesteps] float, samma längd som h

N = 1000 %max number of holdings

numProducts = length(assetIDN);
numCurrencies = length(currencies);
h = zeros(N,2); %initilalize function

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

%T1
%(N,2) *(R - 1) *(nC,1) % Ta ut ur h, de index som avser valutor,
%h[currIndex] * (R-1) * f - > (Nc,1) * (Nc,1) 


%T2
% (N,2) * (nC,1) * (nC,1), samma igen

%T3
% (nP,nC) *(nC,1) -> (nP,1)

%T4
% (nP, nC) .* (nP , nC) *(nC,1), enligt förra

%T5
%s*X + s*x  -> (nP ,nC) * (nC,1) -> (nP,1) 

%T6
% (N,2) .* (N,1) .* (nC,1), ta ut antal ur h = N(:,1)

%T7
%  Det blir körigt men vi tror att det går fint

%error
% (N,1) * t((nC,1)) -> ( N,1) * (1,NC) -> (N,NC) -> sum_NC ->(N,1)



