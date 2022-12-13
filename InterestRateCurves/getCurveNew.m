

currencies = ["AED", "AUD", "BHD", "CAD", "CHF", "CNY", "CZK", "DKK", ...
              "EUR", "GBP", "HKD", "HUF", "IDR", "ILS", "INR", "ISK", ...
              "JPY", "KES", "KRW", "KWD", "MXN", "MYR", "NOK", "NZD", ...
              "PHP", "PKR", "PLN", "QAR", "RON", "RUB", "SAR", "SEK", ...
              "SGD", "THB", "TRY", "TWD", "UGX", "USD", "ZAR"]';
deviationPunishment = ...
             0.1*[100,    100,    100,    100,    100,    100,    100,    100, ...
              100,    100,    100,    100,    100,    100,    100,    100, ...
              100,    100,    100,    100,    100,    100,    100,    100, ...
              100,    100,    100,    100,    100,    100,    100,    100, ...
              100,    100,    100,    100,    100,    100,    100];


days = 3650;
n_f = days;
dt = 1/365;
%C = getC(days);

for i = 1:1
    df = matfile('C:\Users\adame\Desktop\profit_decomposition\InterestRateCurves\3MonthDiscountFactors\' + currencies(i) + 'dF.mat');
    discountFactors = df.discountFactors;
    t = matfile('C:\Users\adame\Desktop\profit_decomposition\InterestRateCurves\3MonthT\' + currencies(i) + 'T.mat');
    T = t.T;
    d = matfile('C:\Users\adame\Desktop\profit_decomposition\InterestRateCurves\3MonthDates\' + currencies(i) + 'Dates.mat');
    dates = d.dates; 
    %for day = 1:numel(dates)
    f = zeros(n_f, 120);
    %E = deviationPunishment(i)*eye(n_r);
    for day = 1:120
        [newT, n_r, newdiscountFactors] = getDayData(T, discountFactors(:, day));  
        logDiscountFactors = -log(newdiscountFactors)';
        [A_s, B_s, C_s] = matrixGeneration(deviationPunishment(i), newT , n_f, n_r, dt);
        f(:,day) = A_s*logDiscountFactors;
    end
    save('C:\Users\adame\Desktop\profit_decomposition\InterestRateCurves\120daysCurves\' + currencies(i) + '.mat', 'f');
end
    



