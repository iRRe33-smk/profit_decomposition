

currencies = ["AED", "AUD", "BHD", "CAD", "CHF", "CNY", "CZK", "DKK", ...
              "EUR", "GBP", "HKD", "HUF", "IDR", "ILS", "INR", "ISK", ...
              "JPY", "KES", "KRW", "KWD", "MXN", "MYR", "NOK", "NZD", ...
              "PHP", "PKR", "PLN", "QAR", "RON", "RUB", "SAR", "SEK", ...
              "SGD", "THB", "TRY", "TWD", "UGX", "USD", "ZAR"]';
deviationPunishment = ...
             [100,    100,    10,    100,    100,    100,    100,    100, ...
              1000,    1000,    100,    100,    100,    100,    1000,    100, ...
              1000,    10,    100,    100,    100,    100,    1000,    100, ...
              100,    10,    100,    10,    10,    1000,    100,    1000, ...
              100,    100,    10,    100,    10,    1000,    10];


days = 3650;
n_f = days;
dt = 1/365;
W = getW(n_f, 10, 2, 4);
C = getC(W, dt, n_f);
nDates = 3000;
curN = length(currencies);
for i = 18:18
    i
    format = "Current currency is number %d of 39, %s, which is %.2f percent done! \n Estimated time left %.2f minutes, estimated total time left %.2f hours!";
    str1 = currencies(i);
    df = matfile('\\ad.liu.se\home\adaen534\Desktop\profit_decomposition\InterestRateCurves\CurveDiscountFactors\' + currencies(i) + 'dF.mat');
    discountFactors = df.discountFactors;
    t = matfile('\\ad.liu.se\home\adaen534\Desktop\profit_decomposition\InterestRateCurves\CurveT\' + currencies(i) + 'T.mat');
    T = t.T;
    T = T(T <= n_f);
    T = T(T >= 30);
    d = matfile('\\ad.liu.se\home\adaen534\Desktop\profit_decomposition\InterestRateCurves\CurveDates\' + currencies(i) + 'Dates.mat');
    dates = d.dates; 
    
    %for day = 1:numel(dates)
    
    %E = deviationPunishment(i)*eye(n_r);
    nDates = size(discountFactors, 2);
    f1 = zeros(n_f, nDates);
    z = zeros(length(T), nDates);
    tic;
    it = 1;
    block = 0;
    blockL = 0;
    [newT, n_r, newdiscountFactors] = getDayData(T, discountFactors(:, it));  
    oldNR = n_r;
    start = 1;
    while true
        while it < nDates
            [newT, n_r, ~] = getDayData(T, discountFactors(:, it));  
            if n_r == oldNR 
                blockL = blockL + 1;
                it = it + 1;
                oldNR = n_r;
            else
               [newT, n_r, ~] = getDayData(T, discountFactors(:, it-1)); 
               break
            end 
        end
        [A_s, B_s, C_s] = matrixGeneration(deviationPunishment(i), newT , n_f, n_r, dt, C);
        for day = start:start + blockL - 1
            [~, n_r, newdiscountFactors] = getDayData(T, discountFactors(:, day));  
            logDiscountFactors = -log(newdiscountFactors)';
            f1(:,day) = A_s*logDiscountFactors;
            z(1:n_r,day) = 10000*(B_s*(f1(:,day)) + C_s*logDiscountFactors);
        end
        start = start + blockL;
        blockL = 0;
        block = block + 1;
        [newT, oldNR, newdiscountFactors] = getDayData(T, discountFactors(:, it));  
        if start >= nDates
            break
        end
    end
    %save('\\ad.liu.se\home\adaen534\Desktop\profit_decomposition\InterestRateCurves\120daysCurves\' + currencies(i) + '.mat', 'f');
    %save('\\ad.liu.se\home\adaen534\Desktop\profit_decomposition\InterestRateCurves\120PriceDeviations\' + currencies(i) + 'dev.mat', 'z');
    block
    
end
    



