measurementPath = 'Z:\prog\XiFinPortfolio\matlab\measurement';
% measurementPath = '/home/jorbl45/axel/jorbl45/prog/XiFinPortfolio/matlab/measurement';

addpath(measurementPath)

% currencyTerm = 'SEK'; currencyBase = 'USD'; p = 10;
% currencyTerm = 'SEK'; currencyBase = 'EUR'; p = 100;
% currencyTerm = 'USD'; currencyBase = 'EUR'; p = 100;
% currencyTerm = 'USD'; currencyBase = 'GBP'; p = 10;
% currencyTerm = 'USD'; currencyBase = 'AUD'; p = 10;
currencyTerm = 'CAD'; currencyBase = 'USD'; p = 10;
% currencyTerm = 'CHF'; currencyBase = 'USD'; p = 10;
% currencyTerm = 'JPY'; currencyBase = 'USD'; p = 10;

miTerm = marketInfo(currencyTerm);
miBase = marketInfo(currencyBase);

fileName = strcat(currencyBase, currencyTerm);

[pl, times, ric, assetID, assetType, assetTenor, currencies] = populatePortfolioWithData(fileName, miTerm.currency, miBase.currencyTimeZone, miBase.onTimeZone);

% [fxSwapID] = mexPortfolio('initFromGenericFxSwap', assetID(66), 1, 1, 0.01, datenum(2007,7,2)+12/24, 1);
% [tradeDate, currencyBase, currencyTerm, settlementDate, settlementBase, settlementTerm, maturityDate, maturityBase, maturityTerm] = mexPortfolio('cashFlowsFxSwap', fxSwapID);
% fprintf('%s %s %s\n', datestr(tradeDate), datestr(settlementDate), datestr(maturityDate))

currencyBaseID = mexPortfolio('currencyCode', miBase.currency);
currencyTermID = mexPortfolio('currencyCode', miTerm.currency);

% indOIS = find(strcmp(onTenor, assetTenor));
% indIBOR = find(strcmp(iborTenor, iborTenor));


iborTimeZone = {miBase.iborTimeZone miTerm.iborTimeZone};
indIBORON = [find(currencies(:,1) == currencyBaseID & strcmp(miBase.onTenor, assetTenor) & pl.atIBOR == assetType) ; find(currencies(:,1) == currencyTermID & strcmp(miTerm.onTenor, assetTenor) & pl.atIBOR == assetType)];
indOIS = find(assetType == pl.atOISG);
indFx = find(assetType == pl.atFX);
indFxSwap = find(assetType == pl.atFxSwapG);

tmp = [assetID((assetType == pl.atOISG) & (currencies(:,1) == currencyBaseID)) ; assetID((assetType == pl.atOISG) & (currencies(:,1) == currencyTermID))];
if (~isempty(find(diff(tmp)<0)))
  error('OIS for base currency has to be first in excel file')
end
% % Small test example
% indOIS = indOIS([33 1]); 
% indFxSwap = indFxSwap(7);

% accountName = 'Cash';
% cashDCC = 'MMA0';
% cashFrq = '1D';
% cashEom = 'S';
% cashBDC = 'F';
% irStartDate = datenum(2010,1,1);
% cashID = mexPortfolio('createCash', currency, accountName, cashDCC, cashFrq, cashEom, cashBDC, cal, irStartDate);

onID = -1;
tnID = -1;
for i=1:length(indFxSwap)
  tmp = ric{indFxSwap(i)};
  j = strfind(tmp, '=');
  tmp = extractBetween(tmp, j-2, j-1);
  if (length(tmp{1}) == 2)
    if (strcmp(tmp, 'ON'))
      onID = mexPortfolio('addRIC', ric{indFxSwap(i)}, floor(times(1)));
    elseif (strcmp(tmp, 'TN'))
      tnID = mexPortfolio('addRIC', ric{indFxSwap(i)}, floor(times(1)));
    end
  end
end

isHolidayBase = mexPortfolio('isHoliday', miBase.onCal, floor(times), floor(times)); % Note that projected holidays may change over time (holidays are added and removed, hence the date when the calendar is defined is important)
isHolidayTerm = mexPortfolio('isHoliday', miTerm.onCal, floor(times), floor(times)); % Note that projected holidays may change over time (holidays are added and removed, hence the date when the calendar is defined is important)
times((isHolidayBase==1) | (isHolidayTerm==1)) = []; % Removes dates when there is a holiday in at least one country

if (currencyTerm == 'CAD' & currencyBase == 'USD')
  nY = 2; % Number of years the curves span
  times = times(times>= datenum(2013,04,30));
elseif (currencyTerm == 'USD' & currencyBase == 'EUR')
  nY = 2; % Number of years the curves span
  times = times(times>= datenum(2005,08,15));
elseif (currencyTerm == 'USD' & currencyBase == 'GBP')
  nY = 2; % Number of years the curves span
  times = times(times>= datenum(2005,08,15));
elseif (currencyTerm == 'SEK')
  nY = 2; % Number of years the curves span
  times = times(times>= datenum(2012,10,22)); % OIS 2-10Y start on this date
elseif (currencyTerm == 'USD' & currencyBase == 'AUD')
  nY = 2; % Number of years the curves span
  times = times(times>= datenum(2014,09,04)); % OIS 2Y start on this date
end
nD = round(nY*365+10);

indAll = [indOIS ; indIBORON ; indFxSwap];
ricAll = [ric(indOIS) ric(indIBORON) ric(indFxSwap)];
assetTypeAll = [assetType(indOIS) ; assetType(indIBORON) ; assetType(indFxSwap)];

exchangeRateH = ones(length(times), 1)*inf;
fBaseH = ones(length(times), nD+20)*inf;
fTermH = ones(length(times), nD+20)*inf;
piH = ones(length(times), nD+20)*inf;
zH = ones(length(times), length(indAll))*inf;
maturityDateH = ones(length(times), length(indAll))*inf;
theoreticalPriceH = ones(length(times), length(indAll))*inf;
marketQuotePriceBidH = ones(length(times), length(indAll))*inf;
marketQuotePriceAskH = ones(length(times), length(indAll))*inf;
marketQuotePriceMidH = ones(length(times), length(indAll))*inf;
theoreticalMarketQuotePriceH = ones(length(times), length(indAll))*inf;
yieldH = ones(length(times), length(indAll))*inf;
firstDates = ones(length(times), 1)*inf;
lastDates = ones(length(times), 1)*inf;
indKeep = true(length(times),1);

% for k=length(times)-1:length(times)
% for k=2547:length(times)
% for k=2699:length(times)
for k=1:length(times)
  tradeDate = floor(times(k));
%   datestr(tradeDate)

  oisID = zeros(size(indOIS));
  oisPrices = ones(3,length(indOIS))*Inf;
  oisMarketQuoteP = ones(1,length(indOIS))*Inf; 
  for j=1:length(indOIS)
    % Retrieve data
    [timeData, data] = mexPortfolio('getValues', assetID(indOIS(j)), times(k), miBase.currencyTimeZone, {'BID', 'ASK'});
    if (timeData < times(k)-1) % More than 24 hours old, do not use
      data = [NaN ; NaN];
    end
    maturityDate = mexPortfolio('maturityDate', assetID(indOIS(j)), tradeDate);
    if (maturityDate-tradeDate > nD) % Too long time to maturity, skip asset
      data = [NaN ; NaN];
    end
    oisPrices(1:2,j) = data;
    if (sum(isnan(data))==0)
      mid = mean(data);
      % Create OIS
      [oisID(j)] = mexPortfolio('initFromGenericInterest', assetID(indOIS(j)), 1, mid, tradeDate, 1);
    else
      mid = 0;
      oisID(j) = 1E19; % Removes asset in createInstrumentsClasses
    end
    oisMarketQuoteP(j) = mid;
  end

  iborID = zeros(size(indIBORON));
  iborPrices = ones(3,length(indIBORON))*Inf;
  iborMarketQuoteP = ones(1,length(indIBORON))*Inf; 
  for j=1:length(indIBORON)
    % IBOR
    % Retrieve data
    [timeData, data] = mexPortfolio('getValues', assetID(indIBORON(j)), times(k), iborTimeZone{j}, 'LAST');
    if (timeData < times(k)-1) % More than 24 hours old, do not use
      data = [NaN ; NaN];
    else
      data = [data ; data];
    end
    iborPrices(1:2,j) = data;
    if (sum(isnan(data))==0)
      mid = mean(data);
      % Create IBOR
      [iborID(j)] = mexPortfolio('initFromGenericInterest', assetID(indIBORON(j)), 1, mid, tradeDate, 0);
    else
      mid = 0;
      iborID(j) = 1E19; % Removes asset in createInstrumentsClasses
    end
    iborMarketQuoteP(j) = mid;
  end
  
  % FxSwap
  [timeDataFx, dataFx] = mexPortfolio('getValues', assetID(indFx(1)), times(k), miBase.currencyTimeZone, {'BID', 'ASK'});
  if (sum(isnan(dataFx))==0)
    exchangeRate = mean(dataFx);
  else
    error('Zero exchange rate');
  end
  settlementDate = mexPortfolio('settlementDate', assetID(indFx(1)), tradeDate);

  fxSwapID = zeros(size(indFxSwap));
  fxSwapPrices = ones(3,length(indFxSwap))*Inf;
  fxSwapMarketQuoteP = ones(1,length(indFxSwap))*Inf;
  for j=1:length(indFxSwap)
    % Retrieve data
    [timeData, data] = mexPortfolio('getValues', assetID(indFxSwap(j)), times(k), miBase.currencyTimeZone, {'BID', 'ASK'});
    if (timeData < times(k)-1) % More than 24 hours old, do not use
      data = [NaN ; NaN];
    end
    exchangeRateMod = exchangeRate;
    if (assetID(indFxSwap(j)) == onID) % Bid and ask prices switch order for ON
      onSettlementDate = mexPortfolio('settlementDate', assetID(indFxSwap(j)), tradeDate);
      onMaturityDate = mexPortfolio('maturityDate', assetID(indFxSwap(j)), tradeDate);
      if (onMaturityDate < settlementDate) % Need to add rate for TN      
        [timeData, dataTN] = mexPortfolio('getValues', tnID, times(k), miBase.currencyTimeZone, {'BID', 'ASK'});
        if (timeData < times(k)-1) % More than 24 hours old, do not use
          dataTN = [NaN ; NaN];
        end
      else % Already at settlement date, no TN
        dataTN = [0 ; 0];        
      end
      fxSwapPrices(1:2,j) = dataFx - data(2:-1:1) - dataTN(2:-1:1);
      exchangeRateMod = mean(dataFx - dataTN(2:-1:1)); % Transaction on farDate is made to TN rate
%       fxSwapPrices(1:2,j) = [NaN ; NaN];
    elseif (assetID(indFxSwap(j)) == tnID) % Bid and ask prices switch order for TN
      fxSwapPrices(1:2,j) = dataFx - data(2:-1:1);
%       fxSwapPrices(1:2,j) = [NaN ; NaN];
    else
      fxSwapPrices(1:2,j) = dataFx + data;
    end
    [F0, F1] = fxSwapRates(miBase, times(k), assetID(indFx(1)), onID, tnID, assetID(indFxSwap(j)));
    if (isempty(isnan(F1)))
      if (sum(abs(fxSwapPrices(1:2,j) - F1)) > 1E-12)
        error
      end
    end
    
    maturityDate = mexPortfolio('maturityDate', assetID(indFxSwap(j)), tradeDate);
    if (maturityDate-tradeDate > nD) % Too long time to maturity, skip asset
      fxSwapPrices(1:2,j) = [NaN ; NaN];
    end
    
    if (sum(isnan(fxSwapPrices(1:2,j)))==0)
      mid = mean(fxSwapPrices(1:2,j));
      % Create FxSwap
      [fxSwapID(j)] = mexPortfolio('initFromGenericFxSwap', assetID(indFxSwap(j)), 1, exchangeRateMod, mid, tradeDate, 1);
    else
      mid = 0;
      fxSwapID(j) = 1E19; % Removes asset in createInstrumentsClasses
    end
    fxSwapMarketQuoteP(j) = mean(data);
  end
%   instrID = [oisID ; iborID ; fxSwapID];
%   prices = [oisPrices iborPrices fxSwapPrices];
%   ricInstr = [ric{1}(indOIS) ric{3}(indIBOR) ric{1}(indFxSwap)];

  instrID = [oisID ; iborID ; fxSwapID];
  prices = [oisPrices iborPrices fxSwapPrices];
  marketQuoteP = [oisMarketQuoteP iborMarketQuoteP fxSwapMarketQuoteP];
  ricInstr = [ric(indOIS) ric(indIBORON) ric(indFxSwap)];
  indInstr = 1:length(instrID);
  
  
%   conTransf = []; % If this is not set, then the standard setting will be applied in computeForwardRates
  conType = ones(size(instrID))*6; % Unique mid price
%   useEF = zeros(size(instrID)); % No deviation from market prices
  [instr,removeAsset,flg] = createInstrumentsClasses(pl, tradeDate, ricInstr, instrID, prices, conType);
  instrID(removeAsset) = [];
  prices(:,removeAsset) = [];
  marketQuoteP(removeAsset) = [];
  indInstr(removeAsset) = [];
  indGeneric = indAll(~removeAsset);

%   if (~isempty(conTransf))
%     conTransf(removeAsset) = [];
%   end
%   if (~isempty(useEF))
%     useEF(removeAsset) = [];
%   end

  skipDate = false;
  
  isUsed = false(size(assetType));
  isUsed(indGeneric) = true;
  isOIS = (assetType == pl.atOISG);
  if (length(unique(currencies(isOIS & isUsed,1)))<=1)
    skipDate = true;  % OIS is missing for at least one currency
  end
  
  if (skipDate)
    indKeep(k) = false;
    continue;
  end
  
  lastDate = mexPortfolio('lastDate', instrID);
  nF = lastDate-tradeDate;
  fDates = tradeDate:lastDate;
  f = ones(nF,1)*0.05;
  piSpread = ones(nF,1)*0.01;

  if (nF >= 5*365+100)
    error('Currently limitation in the time horizon for solver, change indOIS and indIRS which are set manually')
  end
  
  snapTime = tradeDate + 0.5; % Sets time of snapshot to 12:00 in local time
  mexPortfolio('initMarketState', snapTime, miBase.currencyTimeZone);
  fxRateID = mexPortfolio('setMarketStateExchangeRate', snapTime, miBase.currencyTimeZone, miBase.currency, miTerm.currency, exchangeRate, settlementDate);
  fBaseCurveID = mexPortfolio('setMarketStateTermStructureDiscreteForward', snapTime, miBase.currencyTimeZone, miBase.currency, 'Interbank', 'ON', 'Forward', fDates, f);
  fTermCurveID = mexPortfolio('setMarketStateTermStructureDiscreteForward', snapTime, miBase.currencyTimeZone, miTerm.currency, 'Interbank', 'ON', 'Forward', fDates, f);
  piCurveID = mexPortfolio('setMarketStateCurrencyDiscreteForward', snapTime, miBase.currencyTimeZone, miBase.currency, miTerm.currency, 'SpreadRelative', fDates, piSpread);
  fxCurveID = mexPortfolio('setMarketStateCurrencyRelative', snapTime, miBase.currencyTimeZone, fBaseCurveID, fTermCurveID, piCurveID, miBase.currency, miTerm.currency, 'Forward');
  curveIDs = [fBaseCurveID ; fTermCurveID ; piCurveID];
  
	mu = 1.0;
	nIterations = 200;
  iterationPrint = 1; %true;
	checkKKT = 1; %true;
	precision = 1E-6;
	precisionEq = 1E-10;
	precisionKKT = 1E-10;
	muDecrease = 0.1;
	maxRelStep = 0.99;
  mexPortfolio('initBlomvallNdengo', mu, nIterations, iterationPrint, checkKKT, precision, precisionEq, precisionKKT, muDecrease, maxRelStep, curveIDs);

  for i=1:length(curveIDs)
    mexPortfolio('setParamBlomvallNdengo', curveIDs(i), 'ul', -1*ones(nF,1));
    mexPortfolio('setParamBlomvallNdengo', curveIDs(i), 'uu', ones(nF,1)*inf);

    T = (fDates-fDates(1))/365;
    if (curveIDs(i) ~= piCurveID)
      knowledgeHorizon = 2; % After knowledge horizon second order derivative have equal weight
      informationDecrease = 2; % How much information decrease in one year
    else
%       knowledgeHorizon = 2; % After knowledge horizon second order derivative have equal weight
%       informationDecrease = 2; % How much information decrease in one year     
      knowledgeHorizon = 0.5; % After knowledge horizon second order derivative have equal weight
      informationDecrease = 2000; % How much information decrease in one year     
    end
    cb = ones(nF-1,1);
    cb(1:min(round(knowledgeHorizon*365),length(cb))) = exp((T(1:min(round(knowledgeHorizon*365),length(cb)))-knowledgeHorizon)*log(informationDecrease^2));
    cb(1) = 0;

    if (curveIDs(i) ~= piCurveID) % Permit jumps for first day for ON in OIS curve
%       cb(2) = 0;      
    else
%       cb = cb/100;
    end
    
%     if (curveIDs(i) == piCurveID) % Permit jumps for first two days (ON and TN)
%       cpL = zeros(nF-1,1);
%       cpL(1) = 0;
%       cb(2) = 0; cb(3) = 0;
%       cpL(jumpDate) = 100;
%       mexPortfolio('setParamBlomvallNdengo', curveIDs(i), 'cpL', cpL); % First order derivative, with middle removed (central difference)
%     end
    if (curveIDs(i) == piCurveID) % Example where a jump for one specific day is allowed
      jumpDate = find(datenum(year(times(k)), 12, 31) == fDates);
      if (month(times(k)) >= 12 && ~isempty(jumpDate))        
        cpL = zeros(nF-1,1);
        cpL(1) = 0;
        cb(max(jumpDate-1,1):jumpDate+1) = 0; 
        cpL(jumpDate) = 100;
        mexPortfolio('setParamBlomvallNdengo', curveIDs(i), 'cpL', cpL); % First order derivative, with middle removed (central difference)
      end
    end
    mexPortfolio('setParamBlomvallNdengo', curveIDs(i), 'cb', cb); % Second order derivative
  end
  
  zType = ones(size(instrID))*2; % Type of z-variable (price error): 0 = None, 1 = Price, 2 = Parallel shift of forward rates or spread from forward rates
  E = ones(size(instrID))*p;     % Objective function coefficient for z-variables
  F = ones(size(instrID));       % Scaling of z-variable in constraint

%   E(assetType(indGeneric) == pl.atIBOR) = p*100;
%   E(assetType(indGeneric) == pl.atOISG) = p*1000;
%   E(assetType(indGeneric) == pl.atFxSwapG) = p/100;
  
  [u, P, z, theoreticalP, theoreticalMarketQuoteP] = mexPortfolio('solveBlomvallNdengo', instrID, zType, E, F);

  
  fBase = u(1:nF);
  fTerm = u(nF+1:2*nF);
  pi = u(2*nF+1:end);
  exchangeRateH(k) = exchangeRate;
  fBaseH(k,1:nF) = fBase;
  fTermH(k,1:nF) = fTerm;
  piH(k,1:nF) = pi;
  zH(k,indInstr) = z;
  theoreticalPriceH(k,indInstr) = theoreticalP;
  theoreticalMarketQuotePriceH(k,indInstr) = theoreticalMarketQuoteP;
  for j=1:length(instrID)
    maturityDateH(k,indInstr(j)) = instr.maturityDate(j);
    yieldH(k,indInstr(j)) = instr.data{j}.price(3);
    marketQuotePriceBidH(k,indInstr(j)) = prices(1,j);
    marketQuotePriceAskH(k,indInstr(j)) = prices(2,j);
    marketQuotePriceMidH(k,indInstr(j)) = marketQuoteP(j);
  end
  firstDates(k) = tradeDate;
  lastDates(k) = lastDate;

  instrT = zeros(size(z));
  instrf = zeros(size(z));
  iC = zeros(size(z));
  for i=1:length(instrID)
    at = assetType(indGeneric(i));
    n = instr.maturityDate(i)-tradeDate;
    instrT(i) = T(n);
    if (at == pl.atOISG || at == pl.atIBOR)
      curr = currencies(indGeneric(i),1);
      if (curr == currencyBaseID)
        instrf(i) = fBase(n);
        iC(i) = 1;
      elseif (curr == currencyTermID)
        instrf(i) = fTerm(n);
        iC(i) = 2;
      else
        error('Incorrect currency')
      end
    elseif (at == pl.atFxSwapG)      
      instrf(i) = pi(n);      
      iC(i) = 3;
    end
  end


  instrf = instrf+z;
  plot(T(1:end-1), fBase, T(1:end-1), fTerm, T(1:end-1), pi, 'm', instrT(iC==1), instrf(iC==1), 'bo', instrT(iC==2), instrf(iC==2), 'ro', instrT(iC==3), instrf(iC==3), 'mo');
  [~, eInd] = sort(abs(z), 1, 'descend');
  for j = 1:min(3,length(eInd))
    text(instrT(eInd(j))+0.1, instrf(eInd(j)), instr.assetRIC(eInd(j)));
  end
  title(datestr(times(k)));
  legend(strcat('f_{', currencyBase, '}'), strcat('f_{', currencyTerm, '}'), '\pi', 'Location', 'north')
  

  priority = (iC-1)*100 + instrT; % Put them in order f_Base, f_Term and Pi sorted after maturity
  [~, ind] = sort(priority);
  fprintf('%3s %18s %12s %9s %9s %9s %9s %9s %9s %9s\n','j','RIC', 'Maturity', 'Price', 'Spread bp','z', 'Theo.P.', 'Quot.P.', 'Theo.Q', 'Diff Q');
  for i=1:length(instrID)
    j = ind(i);
    if (iC(j) ~= 3) % OIS
      fprintf('%3d %18s %12s %9f %9.3f %9.3f %9f %9.3f %9.3f %9f\n',j,instr.assetRIC{j}, datestr(instr.maturityDate(j)), instr.data{j}.price(3)*100, (prices(2,j)-prices(1,j))*10000,z(j)*10000, theoreticalP(j), marketQuoteP(j)*100, theoreticalMarketQuoteP(j)*100, (marketQuoteP(j)-theoreticalMarketQuoteP(j))*10000);
    else % FxSwap
      fprintf('%3d %18s %12s %9f %9.3f %9.3f %9f %9.3f %9.3f %9f\n',j,instr.assetRIC{j}, datestr(instr.maturityDate(j)), instr.data{j}.price(3), (prices(2,j)-prices(1,j))*10000,z(j)*10000, theoreticalP(j), marketQuoteP(j)*10000, theoreticalMarketQuoteP(j)*10000, (marketQuoteP(j)-theoreticalMarketQuoteP(j))*10000);
    end
  end
 
  pause(0.01);
end

rmpath(measurementPath)

% Find dates when many instruments are missing and remove these
nQuotes = sum(~isinf(marketQuotePriceMidH'));
medQuotes = median(nQuotes);
indKeep(nQuotes < 0.9*medQuotes) = false;

times = times(indKeep);
exchangeRateH = exchangeRateH(indKeep);
fBaseH = fBaseH(indKeep,:);
fTermH = fTermH(indKeep,:);
piH = piH(indKeep,:);
zH = zH(indKeep,:);
maturityDateH = maturityDateH(indKeep,:);
yieldH = yieldH(indKeep,:);
theoreticalPriceH = theoreticalPriceH(indKeep,:);
theoreticalMarketQuotePriceH = theoreticalMarketQuotePriceH(indKeep,:);
marketQuotePriceBidH = marketQuotePriceBidH(indKeep,:);
marketQuotePriceAskH = marketQuotePriceAskH(indKeep,:);
marketQuotePriceMidH = marketQuotePriceMidH(indKeep,:);
firstDates = firstDates(indKeep);
lastDates = lastDates(indKeep);
strTemp=[currencyBase currencyTerm int2str(p) '.mat'];
save(strTemp,'times', 'firstDates', 'lastDates', 'exchangeRateH', 'fBaseH', 'fTermH', 'piH', 'ricAll', 'pl', 'assetTypeAll', 'currencies', 'indAll', 'currencyBaseID', 'currencyTermID', 'maturityDateH', 'yieldH', 'zH', 'theoreticalPriceH', 'theoreticalMarketQuotePriceH', 'marketQuotePriceBidH', 'marketQuotePriceAskH', 'marketQuotePriceMidH')

