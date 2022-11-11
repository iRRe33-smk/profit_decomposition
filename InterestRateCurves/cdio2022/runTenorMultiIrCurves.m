measurementPath = 'C:\Users\Hugo\Downloads\cdio2022\measurement';
% measurementPath = '/home/jorbl45/axel/jorbl45/prog/XiFinPortfolio/matlab/measurement';

addpath(measurementPath)

p = 100;

% currency = 'CHF'; 
currency = 'EUR'; 
% currency = 'GBP'; 
% currency = 'JPY'; 
% currency = 'KRW'; 
% currency = 'SEK'; 
% currency = 'USD'; 

mi = marketInfo(currency);

% fileName = currency;
fileName = 'EUR_ICAP';
% fileName = 'EUR_EONIA';

% pp = gcp;
% parfor ix = 1:pp.NumWorkers % Ensure that mexPortfolio is started and loaded with data on each worker
%   [pl, times, ric, assetID, assetType, assetTenor, currencies] = populatePortfolioWithData(fileName, mi.currency, mi.currencyTimeZone, mi.iborTimeZone);
% end
[pl, times, ric, assetID, assetType, assetTenor, currencies] = populatePortfolioWithData(fileName, mi.currency, mi.currencyTimeZone, mi.iborTimeZone);

indOIS = find(strcmp(mi.onTenor, assetTenor) &  pl.atOISG == assetType);
indFRA = find(strcmp(mi.iborTenor, assetTenor) &  pl.atFRAG == assetType);
indIRS = find(strcmp(mi.iborTenor, assetTenor) &  pl.atIRSG == assetType);
indIBORON = find(strcmp(mi.onTenor, assetTenor) & pl.atIBOR == assetType);
% indIBORON = [];
indIBORTenor = find(strcmp(mi.iborTenor, assetTenor) & pl.atIBOR == assetType);
% indIBOR = find(strcmp(iborTenor, iborTenor));

isHoliday = mexPortfolio('isHoliday', mi.onCal, floor(times), floor(times)); % Note that projected holidays may change over time (holidays are added and removed, hence the date when the calendar is defined is important)
times(isHoliday==1) = []; % Removes all holidays

[timeData, data] = mexPortfolio('getValues', assetID(indIBORTenor), times(end), mi.iborTimeZone, 'LAST');
if (floor(timeData) ~= floor(times(end)))
  times(end) = []; % Remove last day, as the IBOR rate do not exist for this
end

if (currency == 'EUR')
%   nY = 10; % Number of years the curves span
  nY = 2; % Number of years the curves span
  times = times(times>= datenum(2005,08,15));
%   indOIS = indOIS(1:22+5); % Only keep up to five years (currently to slow solver)
%   indIRS = indIRS(1:6+5);    % Only keep up to five years (currently to slow solver)
elseif (currency == 'SEK')
  nY = 10; % Number of years the curves span
  times = times(times>= datenum(2012,10,22)); % OIS 2-10Y start on this date
%   indOIS = indOIS(1:14); % Only keep up to two years (currently to slow solver)
%   indIRS = indIRS(1:2);    % Only keep up to two years (currently to slow solver)
elseif (currency == 'USD')
%   nY = 2.1; % Number of years the curves span
  nY = 10; % Number of years the curves span
  times = times(times>= datenum(2012,03,30)); % OIS 3-10Y start on this date
%   indOIS = indOIS(1:16); % Only keep up to two years (currently to slow solver)
%   indIRS = indIRS(1);    % Only keep up to two years (currently to slow solver)
end

nD = nY*365+10;

% % Small test example
% indOIS = indOIS(3); 
% indFRA = [];
% indIRS = [];

accountName = 'Cash';
cashDCC = 'MMA0';
cashFrq = '1D';
cashEom = 'S';
cashBDC = 'F';
irStartDate = datenum(2010,1,1);
cashID = mexPortfolio('createCash', currency, accountName, cashDCC, cashFrq, cashEom, cashBDC, mi.cal, irStartDate);

indAll = [indIBORON ; indOIS ; indIBORTenor ; indFRA ; indIRS];
ricAll = [ric(indIBORON) ric(indOIS) ric(indIBORTenor) ric(indFRA) ric(indIRS)];
assetTypeAll = [assetType(indIBORON) ; assetType(indOIS) ; assetType(indIBORTenor) ; assetType(indFRA) ; assetType(indIRS)];

fH = ones(length(times), ceil(nY*365)+20)*inf;
piH = ones(length(times), ceil(nY*365)+20)*inf;
zH = ones(length(times), length(indAll))*inf;
theoreticalPriceH = ones(length(times), length(indAll))*inf;
marketQuotePriceBidH = ones(length(times), length(indAll))*inf;
marketQuotePriceAskH = ones(length(times), length(indAll))*inf;
marketQuotePriceMidH = ones(length(times), length(indAll))*inf;
theoreticalMarketQuotePriceH = ones(length(times), length(indAll))*inf;
lastInterestDatesH = ones(length(times), length(indAll))*inf;
yieldH = ones(length(times), length(indAll))*inf;
firstDates = ones(length(times), 1)*inf;
lastDates = ones(length(times), 1)*inf;
indKeep = true(length(times),1);


% for k=length(times):length(times)
% fprintf('Need to debug for k = 3754 for EUR with new OIS structure\n\n');
% parfor k=1:length(times)
for k=1:length(times)
% for k=4300:length(times)

  % These vectors are used to be able to run parfor
  fHvec = ones(1, ceil(nY*365)+20)*inf;
  piHvec = ones(1, ceil(nY*365)+20)*inf;
  zHvec = ones(1, length(indAll))*inf;
  theoreticalPriceHvec = ones(1, length(indAll))*inf;
  marketQuotePriceBidHvec = ones(1, length(indAll))*inf;
  marketQuotePriceAskHvec = ones(1, length(indAll))*inf;
  marketQuotePriceMidHvec = ones(1, length(indAll))*inf;
  theoreticalMarketQuotePriceHvec = ones(1, length(indAll))*inf;
  lastInterestDatesHvec = ones(1, length(indAll))*inf;
  yieldHvec = ones(1, length(indAll))*inf;

  tradeDate = floor(times(k));
%   datestr(tradeDate)
  
  % IBOR ON
  if (~isempty(indIBORON))
    % Retrieve data
    [timeData, data] = mexPortfolio('getValues', assetID(indIBORON), times(k), mi.iborTimeZone, 'LAST');
    if (timeData < times(k)-1) % More than 24 hours old, do not use
      iborOnPrices = [NaN ; NaN ; Inf];
    else
      iborOnPrices = [data ; data ; Inf];
    end
    % Create IBOR
    [iborOnID] = mexPortfolio('initFromGenericInterest', assetID(indIBORON), 1, data, tradeDate, 0);
    iborOnMarketQuoteP = data;
  else
    iborOnPrices = zeros(3,0);
    iborOnID = [];
    iborOnMarketQuoteP = [];
  end

  oisID = zeros(size(indOIS));
  oisPrices = ones(3,length(indOIS))*Inf;
  oisMarketQuoteP = ones(1,length(indOIS))*Inf; 
  for j=1:length(indOIS)
    % Retrieve data
    [timeData, data] = mexPortfolio('getValues', assetID(indOIS(j)), times(k), mi.currencyTimeZone, {'BID', 'ASK'});
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

  % IBOR Tenor
  % Retrieve data
  [timeData, data] = mexPortfolio('getValues', assetID(indIBORTenor), times(k), mi.iborTimeZone, 'LAST');

  if (timeData < times(k)-1) % More than 24 hours old, do not use
    iborTenorPrices = [NaN ; NaN ; Inf];
    iborTenorMarketQuoteP = [NaN];
  else
    iborTenorPrices = [data ; data ; Inf];
    iborTenorMarketQuoteP = data;
  end
  % Create IBOR
  [iborTenorID] = mexPortfolio('initFromGenericInterest', assetID(indIBORTenor), 1, data, tradeDate, 0);
%   iborTenorID = 1E19; % Removes asset in createInstrumentsClasses
  
  % FRA
  fraID = zeros(size(indFRA));
  fraPrices = ones(3,length(indFRA))*Inf;
  fraMarketQuoteP = ones(1,length(indFRA))*Inf; 
  for j=1:length(indFRA)
    % Retrieve data
    [timeData, data] = mexPortfolio('getValues', assetID(indFRA(j)), times(k), mi.currencyTimeZone, {'BID', 'ASK'});
    if (timeData < times(k)-1) % More than 24 hours old, do not use
      data = [NaN ; NaN];
    end
    maturityDate = mexPortfolio('maturityDate', assetID(indFRA(j)), tradeDate);
    if (maturityDate-tradeDate > nD) % Too long time to maturity, skip asset
      data = [NaN ; NaN];
    end
    fraPrices(1:2,j) = data;
    if (sum(isnan(data))==0)
      mid = mean(data);
      % Create FRA
      [fraID(j)] = mexPortfolio('initFromGenericInterest', assetID(indFRA(j)), 1, mid, tradeDate, 1);
    else
      mid = 0;
      fraID(j) = 1E19; % Removes asset in createInstrumentsClasses
    end
    fraMarketQuoteP(j) = mid;
  end
  % IRS
  irsID = zeros(size(indIRS));
  irsPrices = ones(3,length(indIRS))*Inf;
  irsMarketQuoteP = ones(1,length(indIRS))*Inf;
  for j=1:length(indIRS)
    % Retrieve data
    [timeData, data] = mexPortfolio('getValues', assetID(indIRS(j)), times(k), mi.currencyTimeZone, {'BID', 'ASK'});
    if (timeData < times(k)-1) % More than 24 hours old, do not use
      data = [NaN ; NaN];
    end
    maturityDate = mexPortfolio('maturityDate', assetID(indIRS(j)), tradeDate);
    if (maturityDate-tradeDate > nD) % Too long time to maturity, skip asset
      data = [NaN ; NaN];
    end
    irsPrices(1:2,j) = data;
    if (sum(isnan(data))==0)
      mid = mean(data);
      % Create IRS
      [irsID(j)] = mexPortfolio('initFromGenericInterest', assetID(indIRS(j)), 1, mid, tradeDate, 1);
    else
      mid = 0;
      irsID(j) = 1E19; % Removes asset in createInstrumentsClasses
    end
    irsMarketQuoteP(j) = mid;
  end
  instrID = [iborOnID ; oisID ; iborTenorID ; fraID ; irsID];
  prices = [iborOnPrices oisPrices iborTenorPrices fraPrices irsPrices];
  marketQuoteP = [iborOnMarketQuoteP oisMarketQuoteP iborTenorMarketQuoteP fraMarketQuoteP irsMarketQuoteP];
  ricInstr = [ric(indIBORON) ric(indOIS) ric(indIBORTenor) ric(indFRA) ric(indIRS)];
  indInstr = 1:length(instrID);

%   conTransf = []; % If this is not set, then the standard setting will be applied in computeForwardRates
  conType = ones(size(instrID))*6; % Unique mid price
%   useEF = zeros(size(instrID)); % No deviation from market prices
  [instr,removeAsset,flg] = createInstrumentsClasses(pl, tradeDate, ricInstr, instrID, prices, conType);

  instrID(removeAsset) = [];
  marketQuoteP(removeAsset) = [];
  indInstr(removeAsset) = [];
  indGeneric = indAll(~removeAsset);
  
%   if (~isempty(conTransf))
%     conTransf(removeAsset) = [];
%   end
%   if (~isempty(useEF))
%     useEF(removeAsset) = [];
%   end

  for j=1:length(instrID)
    lastInterestDatesHvec(indInstr(j)) = mexPortfolio('lastDate', instrID(j));
  end
  
  lastDate = mexPortfolio('lastDate', instrID);
  nF = lastDate-tradeDate;
  fDates = tradeDate:lastDate;
  f = ones(nF,1)*0.05;
  piSpread = ones(nF,1)*0.01;
  
%   if (nF >= 5*365+100)
%     error('Currently limitation in the time horizon for solver, change indOIS and indIRS which are set manually')
%   end
  
  mexPortfolio('initMarketState', times(k), mi.currencyTimeZone);
  fCurveID = mexPortfolio('setMarketStateTermStructureDiscreteForward', times(k), mi.currencyTimeZone, mi.currency, 'Interbank', 'ON', 'Forward', fDates, f);
  piCurveID = mexPortfolio('setMarketStateTermStructureDiscreteForward', times(k), mi.currencyTimeZone, mi.currency, 'Interbank', mi.iborTenor, 'SpreadRelative', fDates, piSpread);
  iborCurveID = mexPortfolio('setMarketStateTermStructureRelative', times(k), mi.currencyTimeZone, fCurveID, piCurveID, mi.currency, 'Interbank', mi.iborTenor, 'Forward');
  curveIDs = [fCurveID ; piCurveID];
  
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
% 
  for i=1:length(curveIDs)
    if (curveIDs(i) == fCurveID)
      mexPortfolio('setParamBlomvallNdengo', curveIDs(i), 'ul', -ones(nF,1));
    else
      mexPortfolio('setParamBlomvallNdengo', curveIDs(i), 'ul', zeros(nF,1));      
    end
%     mexPortfolio('setParamBlomvallNdengo', curveIDs(i), 'uu', ones(nF,1)*inf);
    mexPortfolio('setParamBlomvallNdengo', curveIDs(i), 'uu', ones(nF,1)*2); % Fix for k = 3754 for EUR with new OIS structure

    T = (fDates-fDates(1))/365;
    knowledgeHorizon = 2; % After knowledge horizon second order derivative have equal weight
    informationDecrease = 2; % How much information decrease in one year
    cb = ones(nF-1,1);
    cb(1:min(round(knowledgeHorizon*365),length(cb))) = exp((T(1:min(round(knowledgeHorizon*365),length(cb)))-knowledgeHorizon)*log(informationDecrease^2));
    cb(1) = 0;

    if (true && curveIDs(i) == fCurveID) % Example where a step for one specific day is allowed
      stepDate = find(datenum(2022, 07, 27) == fDates);
      if (~isempty(stepDate))        
        cp = zeros(nF-1,1);
        cb(max(stepDate-1,1):stepDate) = 0; 
        cp(stepDate-2) = 1;
        cp(stepDate) = 1;
        mexPortfolio('setParamBlomvallNdengo', curveIDs(i), 'cp', cp); % First order derivative
      end

    end
    
    if (curveIDs(i) == piCurveID) % Ensure that curve is flat in the beginning, when there are no instruments
      if (strcmp(mi.iborTenor, '3M'))
        nFirstDer = 91;
      elseif (strcmp(mi.iborTenor, '6M'))
        nFirstDer = 182;
      else
        error('Unknown IBOR tenor');
      end
      cb = 10*ones(nF-1,1);
      cb(1) = 0;
      cp = zeros(nF-1,1);
      cp(1:nFirstDer) = 100 * (nFirstDer-(1:nFirstDer))/nFirstDer;
      mexPortfolio('setParamBlomvallNdengo', curveIDs(i), 'cp', cp); % First order derivative
    end
    
    
    mexPortfolio('setParamBlomvallNdengo', curveIDs(i), 'cb', cb); % Second order derivative
  end
  
  zType = ones(size(instrID))*2; % Type of z-variable (price error): 0 = None, 1 = Price, 2 = Parallel shift of forward rates or spread from forward rates
  E = ones(size(instrID))*p;     % Objective function coefficient for z-variables
  F = ones(size(instrID));       % Scaling of z-variable in constraint

  [u, P, z, theoreticalP, theoreticalMarketQuoteP] = mexPortfolio('solveBlomvallNdengo', instrID, zType, E, F);

 
  f = u(1:nF);
  pi = u(nF+1:end);

  fHvec(1:nF) = f;
  piHvec(1:nF) = pi;
  zHvec(indInstr) = z;
  theoreticalPriceHvec(indInstr) = theoreticalP;
  theoreticalMarketQuotePriceHvec(indInstr) = theoreticalMarketQuoteP;
  for j=1:length(instrID)
    yieldHvec(indInstr(j)) = instr.data{j}.price(3);
    marketQuotePriceBidHvec(indInstr(j)) = prices(1,j);
    marketQuotePriceAskHvec(indInstr(j)) = prices(2,j);
    marketQuotePriceMidHvec(indInstr(j)) = marketQuoteP(j);
  end
  
  lastInterestDatesH(k,:) = lastInterestDatesHvec;
  fH(k,:) = fHvec;
  piH(k,:) = piHvec;
  zH(k,:) = zHvec;
  theoreticalPriceH(k,:) = theoreticalPriceHvec;
  theoreticalMarketQuotePriceH(k,:) = theoreticalMarketQuotePriceHvec;
  yieldH(k,:) = yieldHvec;
  marketQuotePriceBidH(k,:) = marketQuotePriceBidHvec;
  marketQuotePriceAskH(k,:) = marketQuotePriceAskHvec;
  marketQuotePriceMidH(k,:) = marketQuotePriceMidHvec;
  
  
  firstDates(k) = tradeDate;
  lastDates(k) = lastDate;

  
  
  
  instrT = zeros(size(z));
  instrf = zeros(size(z));
  iC = zeros(size(z));
  
  for i=1:length(instrID)
    at = assetType(indGeneric(i));
    n = instr.maturityDate(i)-tradeDate;
    instrT(i) = T(n);
    if (at == pl.atOISG || (at == pl.atIBOR && strcmp(assetTenor(indGeneric(i)),'ON')))
      instrf(i) = f(n);
      iC(i) = 1;
    elseif (at == pl.atIBOR || at == pl.atFRAG || at == pl.atIRSG)      
      instrf(i) = pi(n);      
      iC(i) = 2;
    end
  end
  
  instrf = instrf+z;
  plot(T(1:end-1), f, T(1:end-1), pi, instrT(iC==1), instrf(iC==1), 'bo', instrT(iC==2), instrf(iC==2), 'ro');
  [~, eInd] = sort(abs(z), 1, 'descend');
  for j = 1:min(3,length(eInd))
    text(instrT(eInd(j))+0.1, instrf(eInd(j)), instr.assetRIC(eInd(j)));
  end  
  title(datestr(times(k)));
  legend('f', '\pi', 'Location', 'north')
  if (false)
    h = figure(1);
    set(h,'Units','Inches');
    pos = get(h,'Position');
    set(h,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3),pos(4)]);
    saveas(gcf,'fig/mulitEUR20220531.pdf')
  end
  for j=1:length(instrID)
%     [timeData, data] = mexPortfolio('getValues', instrID(j), times(k), currencyTermTimeZone, {'BID', 'ASK'});
    fprintf('%3d %18s %12s %9f %9.2f %9f %9f %9f\n',j,instr.assetRIC{j}, datestr(instr.maturityDate(j)), instr.data{j}.price(3)*100, z(j)*10000, theoreticalP(j), theoreticalMarketQuoteP(j)*100, (instr.data{j}.price(3) - theoreticalMarketQuoteP(j))*10000);
  end
  
% fraValueDate = instr.data{36}.valueDate;
% fraMaturityDate = instr.data{36}.maturityDate;
% dtFra = instr.data{36}.dt;
% tot = fHvec+piHvec;
% d1 = exp(-sum(tot(1:fraValueDate-tradeDate))/365);
% d2 = exp(-sum(tot(1:fraMaturityDate-tradeDate))/365);
% (d1/d2-1)/dtFra*100
  pause(0.01);
end

% Find dates when many instruments are missing and remove these
nQuotes = sum(~isinf(marketQuotePriceMidH'));
medQuotes = median(nQuotes);
indKeep(nQuotes < 0.9*medQuotes) = false;


times = times(indKeep);
fH = fH(indKeep,:);
piH = piH(indKeep,:);
zH = zH(indKeep,:);
yieldH = yieldH(indKeep,:);
theoreticalPriceH = theoreticalPriceH(indKeep,:);
theoreticalMarketQuotePriceH = theoreticalMarketQuotePriceH(indKeep,:);
marketQuotePriceBidH = marketQuotePriceBidH(indKeep,:);
marketQuotePriceAskH = marketQuotePriceAskH(indKeep,:);
marketQuotePriceMidH = marketQuotePriceMidH(indKeep,:);
firstDates = firstDates(indKeep);
lastDates = lastDates(indKeep);


strTemp=[fileName int2str(p) '.mat'];
save(strTemp,'times', 'firstDates', 'lastDates', 'fH', 'piH', 'ricAll', 'pl', 'assetTypeAll', 'yieldH', 'zH', 'theoreticalPriceH', 'theoreticalMarketQuotePriceH', 'marketQuotePriceBidH', 'marketQuotePriceAskH', 'marketQuotePriceMidH', 'lastInterestDatesH')

rmpath(measurementPath)



