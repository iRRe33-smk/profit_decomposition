currencies = ["AED", "AUD", "BHD", "CAD", "CHF", "CNY", "CZK", "DKK", ...
              "EUR", "GBP", "HKD", "HUF", "IDR", "ILS", "INR", "ISK", ...
              "JPY", "KES", "KRW", "KWD", "MXN", "MYR", "NOK", "NZD", ...
              "PHP", "PKR", "PLN", "QAR", "RON", "RUB", "SAR", "SEK", ...
              "SGD", "THB", "TRY", "TWD", "UGX", "USD", "ZAR"]';
          

C = cell(length(currencies), 3);
sheets = cell(length(currencies), 1);
for i = 1:2
    i
    sheets{i} = readtable("discountFactors.xlsx", "Sheet", currencies(i), 'PreserveVariableNames', 1);
end



for i = 1:2
    i
    %data = readtable("discountFactors.xlsx", "Sheet", currencies(i), 'VariableNamingRule', 'preserve');
    data = sheets{i};
    size_data = size(data);
    dates = data(5:end,1);
    T = table2array(data(3, 2:size_data(2)));
    discountFactors = table2array(data(5:end, 2:size_data(2)));
    discountFactors = discountFactors';
    save('\\ad.liu.se\home\adaen534\Desktop\profit_decomposition\InterestRateCurves\CurveDiscountFactors\' + currencies(i) + 'dF.mat', 'discountFactors');
    save('\\ad.liu.se\home\adaen534\Desktop\profit_decomposition\InterestRateCurves\CurveT\' + currencies(i) + 'T.mat', 'T');
    save('\\ad.liu.se\home\adaen534\Desktop\profit_decomposition\InterestRateCurves\CurveDates\' + currencies(i) + 'Dates.mat', 'dates');
end