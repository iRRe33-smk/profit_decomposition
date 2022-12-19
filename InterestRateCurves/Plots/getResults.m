currencies = ["AED", "AUD", "BHD", "CAD", "CHF", "CNY", "CZK", "DKK", ...
              "EUR", "GBP", "HKD", "HUF", "IDR", "ILS", "INR", "ISK", ...
              "JPY", "KES", "KRW", "KWD", "MXN", "MYR", "NOK", "NZD", ...
              "PHP", "PKR", "PLN", "QAR", "RON", "RUB", "SAR", "SEK", ...
              "SGD", "THB", "TRY", "TWD", "UGX", "USD", "ZAR"]';
deviationCur = zeros(39,1);
for i = 1:length(currencies)

    curve = matfile('\\ad.liu.se\home\adaen534\Desktop\profit_decomposition\InterestRateCurves\120daysCurves\' + currencies(i) + '.mat');
    curve = curve.f;
    curve = 100*curve;
    deviation = matfile('\\ad.liu.se\home\adaen534\Desktop\profit_decomposition\InterestRateCurves\120PriceDeviations\' + currencies(i) + 'dev.mat');
    deviation = deviation.z;
    %T = [30,60,90,180,270,365,455,545,635,730,820,910,1000,1095,1185,1275,1365,1460,1550,1640,1730,1825,1915,2005,2095,2190,2280,2370,2460,2555,2645,2735,2825,2920,3010,3100,3190,3285,3375,3465,3555,3650]./365;
    dates = matfile('\\ad.liu.se\home\adaen534\Desktop\profit_decomposition\InterestRateCurves\CurveDates\' + currencies(i) + 'Dates.mat');
    dates = dates.dates;
    dates = dates(1:120, 1);
    dates = datetime(dates{:,1});
    days = linspace(1,10,3650);
    dev = mean(mean(abs(deviation),2));
    deviationCur(i) = dev;
end