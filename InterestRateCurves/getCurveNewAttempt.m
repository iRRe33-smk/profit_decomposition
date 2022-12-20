

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

path = '\\ad.liu.se\home\adaen534\Desktop';
days = 3650;
n_f = days;
dt = 1/365;
W = getW(n_f, 10, 2, 4);
C = getC(W, dt, n_f);
curN = length(currencies);

for i = 19:curN
    i
    nDates = 252*10 + 1;
    
    df = matfile(string([path, '\profit_decomposition\InterestRateCurves\Data\MatLab\DiscountFactors\']) + currencies(i) + 'dF.mat');
    discountFactors = df.discountFactors;
    t = matfile(string([path, '\profit_decomposition\InterestRateCurves\Data\MatLab\T\']) + currencies(i) + 'T.mat');
    T = t.T;
    T = T(T <= n_f);
    Tbef = size(T, 2);
    T = T(T >= 30);
    Taft = size(T, 2);
    discountFactors = discountFactors(Tbef-Taft + 1:end, :);
    d = matfile(string([path, '\profit_decomposition\InterestRateCurves\Data\MatLab\Dates\']) + currencies(i) + 'Dates.mat');
    dates = d.dates; 
    if height(dates) < nDates
        nDates = height(dates);
    else
        dates = dates{1:nDates-1, 1};
    end
    f = zeros(n_f, nDates-1);
    z = zeros(length(T), nDates);
    tic;
    it = 1;
    block = 0;
    blockL = 0;
    [newT, n_r, newdiscountFactors] = getDayData(T, discountFactors(:, it));  
    oldT = newT;
    start = 1;
    while (it <= nDates)
        while true
            [newT, n_r, ~] = getDayData(T, discountFactors(:, it));  
            if (size(newT) == size(oldT)) 
                if (it >= nDates)
                    break
                end
                if newT == oldT
                    blockL = blockL + 1;
                    it = it + 1;
                    oldT = newT;
                end
            else
               [newT, n_r, ~] = getDayData(T, discountFactors(:, it-1)); 
               break
            end 
        end
        [A_s, B_s, C_s] = matrixGeneration(deviationPunishment(i), newT , n_f, n_r, dt, C);
        for day = start:start + blockL - 1
            [~, n_r, newdiscountFactors] = getDayData(T, discountFactors(:, day));  
            logDiscountFactors = -log(newdiscountFactors)';
            f(:,day) = A_s*logDiscountFactors;
            z(1:n_r,day) = 10000*(B_s*(f(:,day)) + C_s*logDiscountFactors);
        end
        start = start + blockL;
        blockL = 0;
        block = block + 1;
        [oldT, n_r, newdiscountFactors] = getDayData(T, discountFactors(:, it));  
        if start >= nDates
            break
        end
    end
    save(string([path, '\profit_decomposition\InterestRateCurves\10year\ForwardCurves\']) + currencies(i) + '.mat', 'f');
    save(string([path, '\profit_decomposition\InterestRateCurves\10year\Deviations\']) + currencies(i) + 'dev.mat', 'z');
    save(string([path, '\profit_decomposition\InterestRateCurves\10year\Dates\']) + currencies(i) + 'dates.mat', 'dates');
end
    



