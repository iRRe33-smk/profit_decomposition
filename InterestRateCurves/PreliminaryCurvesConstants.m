
function [discountFactors, dates, maturity, n_size, n_dates, n_datapoints, x, x_tick, maturity_tick] = PreliminaryCurvesConstants()
    discountFactors = readmatrix("Data/DiscountCurves.xlsx","Range","C3:AC125", "Sheet", "Curves");
    dates = readtable("Data/DiscountCurves.xlsx","Range","B3:B125", "Sheet", "Curves");
    maturity = ["ON" "TN" "1W" "2W" "1M" "2M" "3M" "6M" "9M" "1Y" "2Y" "3Y" "4Y" "5Y" "6Y" "7Y" "8Y" "9Y" "10Y" "11Y" "12Y" "13Y" "14Y" "15Y" "20Y" "25Y"];
    n_size = size(discountFactors);
    n_dates = n_size(1);
    n_datapoints = n_size(2);
    x = [1 2 7 14 30 60 90 180 270 360 720 1080 1440 1800 2160 2520 2880 3240 3600 3960 4320 4680 5040 5400 7200 9000 10800];
    x_tick = [1 180 360 720 1080 1440 1800 2160 2520 2880 3240 3600 3960 4320 4680 5040 5400 7200 9000];
    maturity_tick = ["ON"  "6M"  "1Y" "2Y" "3Y" "4Y" "5Y" "6Y" "7Y" "8Y" "9Y" "10Y" "11Y" "12Y" "13Y" "14Y" "15Y" "20Y" "25Y"];
end