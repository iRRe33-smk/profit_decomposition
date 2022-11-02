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
%     h = array[] int
%     deltaT = array[numCurrencies] float
%     S = matrix(numProducts x numCurrencies) float
%     f = array[1 + numCurrencies] första index är 1 ty ingen enhet för assets
%     R = matrix(numCurrencies x numTimesteps) float
%     P = array[] float, samma längd som h
%     x_s = array[] float, samma längd som h
%     x_b = array[] float, samma längd som h

%N = 1000 %max number of holdings

%numProducts = length(assetIDN);
%numCurrencies = length(currencies);

% h = zeros(numProducts,numCurrencies);
% hc = diag(h(1:numCurrencies, 1:numCurrencies))
% 
% x_b = zeros(numProducts,numCurrencies); %ReadData
% x_s = zeros(numProducts,numCurrencies); %ReadData
% s_s = zeros(numProducts,numCurrencies); %PriceList[typeID ,PriceListID]
% s_b = zeros(numProducts,numCurrencies); %PriceList[typeID ,PriceListID]
% 
% BOM = eye(numProducts); % zeroes if bought/sold product, relation between input and output if manufacture ex (3 bolt, 1 plate -> borrig)
% 
% R = zeros(numCurrencies,1);
% deltaT = zeros(numCurrencies,1);
% f = zeros(numCurrencies,1);
% 
% Dividends = zeros(numProducts,1,numCurrencies); % middle index:T = time until dividend
% P = zeros(numProducts,1); 
% dP = zeros(numProducts,1);



%  P och dP är uttryckt i basvaluta



end

%T1
%(nP, nC) *(R - 1) *(nC,1) % Ta ut ur h, de index som avser valutor,
%h[currIndex] * (R-1) * f - > (Nc,1) * (Nc,1) 


%T2
% (nP,nC) * (nC,1) * (nC,1), samma igen

%T3
% (nP,1,nC) *(nC,1) -> (nP,1)

%T4
% (nP, nC) .* (nP , nC) *(nC,1), enligt förra

%T5
%s*X + s*x  -> [(nP ,nC) + (nP ,nC)]  * (nC,1) -> (nP,1) 

%T6
% (nP,nC) .* (nP,1) .* (nC,1), ta ut antal ur h = N(:,1)

%T7
%  Det blir körigt men vi tror att det går fint
%  mellanterm = (nP,1) - (nP,nC) * (nC,1) -> (nP,1) - (nP,1) ok!
%  (nP,nC) .* (nP,1) .* (nC,1)

%error
% (N,1) * t((nC,1)) -> ( N,1) * (1,NC) -> (N,NC) -> sum_NC ->(N,1)



