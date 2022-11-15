


currencies = ['AED', 'AUD', 'BHD', 'CAD', 'CHF', 'CNY', 'CZK', 'DKK', ...
              'EUR', 'GBP', 'HKD', 'HUF', 'IDR', 'ILS', 'INR', 'ISK', ...
              'JPY', 'KES', 'KRW', 'KWD', 'MXN', 'MYR', 'NOK', 'NZD', ...
              'PHP', 'PKR', 'PLN', 'QAR', 'RON', 'RUB', 'SAR', 'SEK', ...
              'SGD', 'THB', 'TRY', 'TWD', 'UGX', 'USD', 'ZAR'];

% [forwardRates, spotRates, discountFactors, ~,daysInBtw, dates] = getForwAndSpot();
% T = [1 2 7 14 30 60 90 180 270 1*365 2*365 3*365 4*365 5*365 6*365 7*365 ...
%          8*365 9*365 10*365 11*365 12*365 13*365 14*365 15*365 20*365 25*365 30*365];
% discountFactors = discountFactors';
% e = 100;
% [f, z] = curveGeneration(discountFactors, T, e);


T = readtable('discountFactors.xlsx', 'Sheet', 'AED');
