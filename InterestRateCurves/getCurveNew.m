

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
nDates = 120;
curN = length(currencies);
for i = 32:32
    format = "Current currency is number %d of 39, %s, which is %.2f percent done! \n Estimated time left %.2f minutes, estimated total time left %.2f hours!";
    str1 = currencies(i);
    df = matfile('C:\Users\adame\Desktop\profit_decomposition\InterestRateCurves\CurveDiscountFactors\' + currencies(i) + 'dF.mat');
    discountFactors = df.discountFactors;
    t = matfile('C:\Users\adame\Desktop\profit_decomposition\InterestRateCurves\CurveT\' + currencies(i) + 'T.mat');
    T = t.T;
    T = T(T <= n_f);
    T = T(T >= 30);
    d = matfile('C:\Users\adame\Desktop\profit_decomposition\InterestRateCurves\CurveDates\' + currencies(i) + 'Dates.mat');
    dates = d.dates; 
    %for day = 1:numel(dates)
    f = zeros(n_f, nDates);
    z = zeros(length(T), nDates);
    %E = deviationPunishment(i)*eye(n_r);
    %nDates = size(discountFactors, 2);
    tic;
    for day = 1:nDates
        dig2 = round((day/nDates)*100, 2);
        [newT, n_r, newdiscountFactors] = getDayData(T, discountFactors(:, day));  
        logDiscountFactors = -log(newdiscountFactors)';
        [A_s, B_s, C_s] = matrixGeneration(deviationPunishment(i), newT , n_f, n_r, dt, C);
        f(:,day) = A_s*logDiscountFactors;
        z(1:n_r,day) = 10000*(B_s*(f(:,day)) + C_s*logDiscountFactors);
        endLoop = toc;           
        estimateTimeLeft = ((endLoop/day)*(nDates - day))/60;
        estTotalTimeLeft = ((estimateTimeLeft/(1 - (dig2/100)))*(curN - i))/60;
        sprintf(format, i, str1, dig2, estimateTimeLeft, estTotalTimeLeft)
        
    end
    save('C:\Users\adame\Desktop\profit_decomposition\InterestRateCurves\120daysCurves\' + currencies(i) + '.mat', 'f');
    save('C:\Users\adame\Desktop\profit_decomposition\InterestRateCurves\120PriceDeviations\' + currencies(i) + 'dev.mat', 'z');
    
    
end
    



