function [pl, times, ric, assetID, assetType, assetTenor, currencies] = populatePortfolioWithData(fileName, currency, currencyTimeZone, iborTimeZone)

% Load data which originates from the Excel file into mexPortfolio and
% generate generic instruments
% pl - Dictionary of instrument codes (asset types)
% times - Historical UTC (Coordinated Universal Time) times where yield have been observed and stored in mexPortfolio
% Data for generated instruments in mexPortfolio (vector indexed with j):
% ric - The Reuters Instrument Code for asset j
% assetID - The unique identifier for asset j in mexPortfolio
% assetType - The mexPortfolio asset type (see dictionary pl) for asset j 
% assetTenor - The floating rate tenor for asset j
% currencies - The mexPortfolio currency ID's for asset j 

mexPortfolio('clear')
mexPortfolio('init', currency)

% Create portfolio lexicon (pl) for constants in portfolio
pl.atFuture = mexPortfolio('assetTypeCode', 'FutureIR'); % Interest rate future
pl.atDeposit = mexPortfolio('assetTypeCode', 'Deposit'); % Deposit
pl.atIBOR = mexPortfolio('assetTypeCode', 'IBOR');       % IBOR - Generic instrument that stores price history and generates deposits
pl.atFRAG = mexPortfolio('assetTypeCode', 'FRAG');       % FRA - Generic instrument that stores price history and generates a traded FRA
pl.atFRA  = mexPortfolio('assetTypeCode', 'FRA');        % FRA - Instrument with a fixed rate and traded on a specific date
pl.atIRSG = mexPortfolio('assetTypeCode', 'IRSG');       % IRS - Generic instrument that stores price history and generates a traded IRS
pl.atIRS  = mexPortfolio('assetTypeCode', 'IRS');        % IRS - Instrument with a fixed rate and traded on a specific date
pl.atOISG = mexPortfolio('assetTypeCode', 'OISG');       % OIS - Generic instrument that stores price history and generates a traded OIS
pl.atOIS  = mexPortfolio('assetTypeCode', 'OIS');        % OIS - Instrument with a fixed rate and traded on a specific date
pl.atFxSwapG = mexPortfolio('assetTypeCode', 'FxSwapG'); % FxSwap - Generic instrument that stores price history and generates a traded FxSwap
pl.atFxSwap  = mexPortfolio('assetTypeCode', 'FxSwap');  % FxSwap - Instrument with a fixed rate and traded on a specific date
pl.atFX  = mexPortfolio('assetTypeCode', 'FX');          % FxSpot - Stores price history for the FX spot rate

load([fileName '.mat']); % File created by createMatFromExcel

ricExcel = ric;
ric = [ ricExcel{1} ricExcel{3}];
nAssets = length(ric);

for j=1:length(ricExcel{1})
  if (strcmp(ricExcel{1}(j), ricExcel{2}(j)) == 0)
    error('Assumes that BID/ASK exist for each asset');
  end
end

syncData = false;
if (length(dates{1}) ~= length(dates{2}))
  syncData = true;
elseif (sum(abs(dates{1}-dates{2})) > 0)
  syncData = true;
end  

if (syncData)
  % Need to synchronize data
  datesAll = unique([dates{1} ; dates{2}]);
  datesMin = datesAll(1);
  datesMax = datesAll(end);
  datesRangeN = datesMax-datesMin+1;
  ind = zeros(datesRangeN,1);
  ind(datesAll-datesMin+1) = 1:length(datesAll);
  for j=1:2
    tmp = data{j};
    data{j} = ones(length(datesAll), size(tmp,2))*NaN;
    data{j}(ind(dates{j}-datesMin+1),:) = tmp;
    dates{j} = datesAll;
  end
end

tmp = datevec(dates{1});
tmp(:,4) = 22; % Assumes that daily prices are set at 22:00:00 (ensures that IBOR has been set also in JPY)
times = datenum(datetime(tmp));


assetID = zeros(nAssets,1);
assetType = zeros(nAssets,1);
firstDate = min([dates{1}(1) dates{2}(1) dates{3}(1)]);
for j=1:nAssets
  [assetID(j), assetType(j)] = mexPortfolio('addRIC', ric{j}, firstDate);
end

assetTenor = cell(nAssets, 1);
currencies = ones(nAssets, 2)*inf;

for j=1:nAssets
  [iborID] = mexPortfolio('underlyingIBOR', assetID(j));
  if (~isempty(iborID))
    [assetTenor{j}] = mexPortfolio('tenorIBOR', iborID);
  else
    [assetTenor{j}] = '';    
  end
  [cur] = mexPortfolio('assetCurrency', assetID(j));
  if (length(cur) == 2)
    currencies(j,:) = cur;
  elseif (length(cur) == 1)
    currencies(j,1) = cur;
  else
    error('Missing currency for asset');
  end
  fprintf('%18s %3d %3d %3d %3s\n', ric{j}, assetID(j), assetType(j), iborID, assetTenor{j});
end

% Store IRS/FRA/OIS data

for j=1:length(ricExcel{1})
  if (assetType(j) == pl.atFxSwapG)
    v = [data{1}(:,j) data{2}(:,j)]/10000;
  elseif (assetType(j) == pl.atFX)
    v = [data{1}(:,j) data{2}(:,j)];
  else
    v = [data{1}(:,j) data{2}(:,j)]/100;
  end
  tmp = isnan(v);
  ind = tmp(:,1) & tmp(:,2);
  timesData = times;
  timesData(ind) = [];
  v(ind,:) = [];

%   if (strcmp(ric{j}, 'EUR='))
%     fprintf('Changing EUR\n');
%     v = ones(size(v));
%   end
  mexPortfolio('setHistory', assetID(j), timesData, currencyTimeZone, {'BID', 'ASK'}, v);
end

% Store IBOR data

tmp = datevec(dates{3});
tmp(:,4) = 11; % Assumes that IBORS are set at 11:00:00
timesIBOR = datenum(datetime(tmp));

offset = length(ricExcel{1});
for j=1:length(ricExcel{3})
  v = data{3}(:,j)/100;
  ind = isnan(v);
  timesData = timesIBOR;
  timesData(ind) = [];
  v(ind,:) = [];

% fprintf('Changing IR\n');
% v = zeros(size(v));
  
%   mexPortfolio('setHistory', assetID{3}(j), timesIBOR, iborTimeZone, 'LAST', v);
  mexPortfolio('setHistory', assetID(offset+j), timesData, iborTimeZone, 'LAST', v);
end

