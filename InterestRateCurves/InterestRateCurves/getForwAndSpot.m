function [forwardRates, spotRates, T,daysInBtw] = getForwAndSpot()
    discountFactors = readmatrix("Data/DiscountCurves.xlsx","Range","C3:AC125", "Sheet", "Curves");
    x = [1 2 7 14 30 60 90 180 270 360 720 1080 1440 1800 2160 2520 2880 3240 3600 3960 4320 4680 5040 5400 7200 9000 10800];
    sN = size(discountFactors);
    n_datapoints = sN(2);
    n_dates = sN(1);
    T = x(:, 1:end-1);
    daysInBtw = circshift(T, -1) -T;
    daysInBtw = daysInBtw(1:end-1);
    %Spot-räntor
    spotRates = zeros(size(discountFactors));
    for day = 1:n_dates
        for i = 1:n_datapoints
            spotRates(day, i) = -log(discountFactors(day,i))/(x(i)/365); 
        end
    end
    %Forward-räntor
    forwardRates = zeros(size(discountFactors));
    for day = 1:n_dates
        for i = 1:n_datapoints-1
            forwardRates(day, i) = (log(discountFactors(day,i)) - log(discountFactors(day,i+1)))/(((x(i+1)/365)) -((x(i)/365)));

        end
    end
    spotRates = spotRates(:, 1:end-1);
    forwardRates = forwardRates(:, 1:end-1);
end