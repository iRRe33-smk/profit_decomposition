

currencies = ["AED", "AUD", "BHD", "CAD", "CHF", "CNY", "CZK", "DKK", ...
              "EUR", "GBP", "HKD", "HUF", "IDR", "ILS", "INR", "ISK", ...
              "JPY", "KES", "KRW", "KWD", "MXN", "MYR", "NOK", "NZD", ...
              "PHP", "PKR", "PLN", "QAR", "RON", "RUB", "SAR", "SEK", ...
              "SGD", "THB", "TRY", "TWD", "UGX", "USD", "ZAR"]';
deviationPunishment = ...
             [100,    100,    100,    100,    100,    100,    100,    100, ...
              100,    100,    100,    100,    100,    100,    100,    100, ...
              100,    100,    100,    100,    100,    100,    100,    100, ...
              100,    100,    100,    100,    100,    100,    100,    100, ...
              100,    100,    100,    100,    100,    100,    100];

          
saveInWorkspace = true;
readFromWorkspace = false;
addToWorkspace = false;
saveToFile = false;
readFromFile = true;
addToFile = false;
days = 90;

if addToWorkspace
    C = cell(length(currencies), 3);
    sheets = cell(length(currencies), 1);
    for i = 1:length(currencies)
        sheets{i} = readtable("discountFactors.xlsx", "Sheet", currencies(i), 'VariableNamingRule', 'preserve');
    end
end

if addToFile
    for i = 1:length(currencies)
        %data = readtable("discountFactors.xlsx", "Sheet", currencies(i), 'VariableNamingRule', 'preserve');
        data = sheets{i};
        size_data = size(data);
        dates = data(5:days + 4,1);
        T = table2array(data(3, 2:size_data(2)));
        discountFactors = table2array(data(5:days+4, 2:size_data(2)));
        discountFactors = discountFactors';
        save('C:\Users\adame\Desktop\profit_decomposition\InterestRateCurves\3MonthDiscountFactors\' + currencies(i) + 'dF.mat', 'discountFactors');
        save('C:\Users\adame\Desktop\profit_decomposition\InterestRateCurves\3MonthT\' + currencies(i) + 'T.mat', 'T');
        save('C:\Users\adame\Desktop\profit_decomposition\InterestRateCurves\3MonthDates\' + currencies(i) + 'Dates.mat', 'dates');
    end
    
end

if saveInWorkspace
    C = cell(length(currencies), 3);
end
for i = 1:length(currencies)
    if readFromWorkspace
        data = sheets{i};
        size_data = size(data);
        dates = data(5:days + 4,1);
        T = table2array(data(3, 2:size_data(2)));
        discountFactors = table2array(data(5:days+4, 2:size_data(2)));
        discountFactors = discountFactors';
        size_discount = size(discountFactors);
    end
    if readFromFile
        df = matfile('C:\Users\adame\Desktop\profit_decomposition\InterestRateCurves\3MonthDiscountFactors\' + currencies(i) + 'dF.mat');
        discountFactors = df.discountFactors;
        t = matfile('C:\Users\adame\Desktop\profit_decomposition\InterestRateCurves\3MonthT\' + currencies(i) + 'T.mat');
        T = t.T;
        d = matfile('C:\Users\adame\Desktop\profit_decomposition\InterestRateCurves\3MonthDates\' + currencies(i) + 'Dates.mat');
        dates = d.dates;
    end
    [f, z] = curveGeneration(discountFactors, T, deviationPunishment(i));
    if saveToFile
        save('C:\Users\adame\Desktop\profit_decomposition\InterestRateCurves\3MonthCurves\' + currencies(i) + '.mat', 'f');
    end
    if saveInWorkspace
        C{i,1} = currencies(i);
        C{i,2} = f;
        C{i,3} = z;
    end
    disp(i)
end









