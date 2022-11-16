


currencies = ["AED", "AUD", "BHD", "CAD", "CHF", "CNY", "CZK", "DKK", ...
              "EUR", "GBP", "HKD", "HUF", "IDR", "ILS", "INR", "ISK", ...
              "JPY", "KES", "KRW", "KWD", "MXN", "MYR", "NOK", "NZD", ...
              "PHP", "PKR", "PLN", "QAR", "RON", "RUB", "SAR", "SEK", ...
              "SGD", "THB", "TRY", "TWD", "UGX", "USD", "ZAR"]';
deviationPunishment = ...
             [10,    10,    10,    10,    10,    10,    10,    10, ...
              10,    10,    10,    10,    10,    10,    10,    10, ...
              10,    10,    10,    10,    10,    10,    10,    10, ...
              10,    10,    10,    10,    10,    10,    10,    10, ...
              10,    10,    10,    10,    10,    10,    10];

          
saveInWorkspace = true;
saveToFile = true;

days = 90;
if saveInWorkspace
    C = cell(length(currencies), 3);
end
for i = 1:length(currencies)
    data = readtable("discountFactors.xlsx", "Sheet", currencies(i), 'VariableNamingRule', 'preserve');
    size_data = size(data);
    dates = data(5:days + 4,1);
    T = table2array(data(3, 2:size_data(2)));
    discountFactors = table2array(data(5:days+4, 2:size_data(2)));
    discountFactors = discountFactors';
    size_discount = size(discountFactors);
   
    [f, z] = curveGeneration(discountFactors, T, deviationPunishment(i));
    if saveToFile
        save('C:\Users\adame\Desktop\profit_decomposition\InterestRateCurves\3MonthCurves\' + currencies(i) + '.mat', 'f');
    end
    if saveInWorkspace
        C{i,1} = currencies(i);
        C{i,2} = f;
        C{i,3} = z;
    end
end









