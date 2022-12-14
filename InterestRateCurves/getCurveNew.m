

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


days = 3650;
n_f = days;
dt = 1/365;
W = getW(n_f, 10, 2, 4);
C = getC(W, dt, n_f);
curN = length(currencies);
for i = 6:curN
    format = "Current currency is number %d of 39, %s, which is %.2f percent done! \n Estimated time left %.2f minutes, estimated total time left %.2f hours!";
    str1 = currencies(i);
    df = matfile('\\ad.liu.se\home\adaen534\Downloads\profit_decomposition-main\InterestRateCurves\3MonthDiscountFactors\' + currencies(i) + 'dF.mat');
    discountFactors = df.discountFactors;
    t = matfile('\\ad.liu.se\home\adaen534\Downloads\profit_decomposition-main\InterestRateCurves\3MonthT\' + currencies(i) + 'T.mat');
    T = t.T;
    T = T(T <= n_f);
    %d = matfile('\\ad.liu.se\home\adaen534\Downloads\profit_decomposition-main\InterestRateCurves\3MonthDates\' + currencies(i) + 'Dates.mat');
    %dates = d.dates; 
    %for day = 1:numel(dates)
    f = zeros(n_f, 120);
    %E = deviationPunishment(i)*eye(n_r);
    dfN = size(discountFactors, 2);
    tic;
    for day = 1:dfN
        dig2 = round((day/dfN)*100, 2);
        [newT, n_r, newdiscountFactors] = getDayData(T, discountFactors(:, day));  
        logDiscountFactors = -log(newdiscountFactors)';
        [A_s, B_s, C_s] = matrixGeneration(deviationPunishment(i), newT , n_f, n_r, dt, C);
        f(:,day) = A_s*logDiscountFactors;
        endLoop = toc;           
        estimateTimeLeft = ((endLoop/day)*(dfN - day))/60;
        estTotalTimeLeft = ((estimateTimeLeft/(1 - (dig2/100)))*(curN - i))/60;
        sprintf(format, i, str1, dig2, estimateTimeLeft, estTotalTimeLeft)
        
    end
    save('\\ad.liu.se\home\adaen534\Downloads\profit_decomposition-main\InterestRateCurves\FullCurves\' + currencies(i) + '.mat', 'f');
    
end
    



