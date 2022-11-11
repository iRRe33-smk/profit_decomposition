function [F0, F1] = fxSwapRates(miBase, t, fxID, onID, tnID, fxSwapID)
tradeDate = floor(t);

[timeDataFx, dataFx] = mexPortfolio('getValues', fxID, t, miBase.currencyTimeZone, {'BID', 'ASK'});
if (sum(isnan(dataFx))>0)
  error('Zero exchange rate');
end

[timeData, data] = mexPortfolio('getValues', fxSwapID, t, miBase.currencyTimeZone, {'BID', 'ASK'});
if (timeData < t-1) % More than 24 hours old, do not use
  data = [NaN ; NaN];
end
if (fxSwapID == onID) % Bid and ask prices switch order for ON
  settlementDate = mexPortfolio('settlementDate', fxID, tradeDate);
  onMaturityDate = mexPortfolio('maturityDate', fxSwapID, tradeDate);
  if (onMaturityDate < settlementDate) % Need to add rate for TN      
    [timeData, dataTN] = mexPortfolio('getValues', tnID, t, miBase.currencyTimeZone, {'BID', 'ASK'});
    if (timeData < t-1) % More than 24 hours old, do not use
      dataTN = [NaN ; NaN];
    end
  else % Already at settlement date, no TN
    dataTN = [0 ; 0];        
  end
  F0 = dataFx - dataTN(2:-1:1);
  F1 = dataFx - data(2:-1:1) - dataTN(2:-1:1);
elseif (fxSwapID == tnID) % Bid and ask prices switch order for TN
  F0 = dataFx;
  F1 = dataFx - data(2:-1:1);
else
  F0 = dataFx;
  F1 = dataFx + data;
end
