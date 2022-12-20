currencies = ["AED", "AUD", "BHD", "CAD", "CHF", "CNY", "CZK", "DKK", ...
              "EUR", "GBP", "HKD", "HUF", "IDR", "ILS", "INR", "ISK", ...
              "JPY", "KES", "KRW", "KWD", "MXN", "MYR", "NOK", "NZD", ...
              "PHP", "PKR", "PLN", "QAR", "RON", "RUB", "SAR", "SEK", ...
              "SGD", "THB", "TRY", "TWD", "UGX", "USD", "ZAR"]';


          
path = '\\ad.liu.se\home\adaen534\Desktop';
nCurrencies = length(currencies);
C = cell(nCurrencies, 3);
sheets = cell(nCurrencies, 1);
for i = 13:13
    sheets{i} = readtable(string([path, '\profit_decomposition\InterestRateCurves\Data\Excel\discountFactors.xlsx']), "Sheet", currencies(i), 'PreserveVariableNames', 1);
end



for i = 13:13
    data = sheets{i};
    size_data = size(data);
    dates = data(5:end,1);
    T = table2array(data(3, 2:size_data(2)));
    discountFactors = table2array(data(5:end, 2:size_data(2)));
    discountFactors = discountFactors';
    save(string([path, '\profit_decomposition\InterestRateCurves\Data\MatLab\DiscountFactors\']) + currencies(i) + 'dF.mat', 'discountFactors');
    save(string([path, '\profit_decomposition\InterestRateCurves\Data\MatLab\T\']) + currencies(i) + 'T.mat', 'T');
    save(string([path, '\profit_decomposition\InterestRateCurves\Data\MatLab\Dates\']) + currencies(i) + 'Dates.mat', 'dates');
end