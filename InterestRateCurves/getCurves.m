function [f, dates] = getCurves(currency, punishment, Tdays, path)
%%% Check computer type
if ispc
    path1 = '\InterestRateCurves\Data\MatLab\DiscountFactors\';
    path2 = '\InterestRateCurves\Data\MatLab\T\';
    path3 = '\InterestRateCurves\Data\MatLab\Dates\';
end
if ismac
    path1 = '/InterestRateCurves/Data/MatLab/DiscountFactors/';
    path2 = '/InterestRateCurves/Data/MatLab/T/';
    path3 = '/InterestRateCurves/Data/MatLab/Dates/';
end

days = 3650; %%%Length of curves
n_f = days;
dt = 1/365; %%%Time between two points
W = getW(n_f, 10, 2, 4); %%% Get weighting matrix
C = getC(W, dt, n_f); %%%Get A_n'*W*A_n
nDates = Tdays + 1;
%%% Load discount factors and maturities in days
df = matfile(string([path, path1]) + currency + 'dF.mat');
discountFactors = df.discountFactors;
t = matfile(string([path, path2]) + currency + 'T.mat');
T = t.T;
%%% Remove any data for maturities longer than the curvelength and shorter
%%% than 30 days
T = T(T <= n_f);
Tbef = size(T, 2);
T = T(T >= 30);
Taft = size(T, 2);
discountFactors = discountFactors(Tbef-Taft + 1:end, :);
d = matfile(string([path, path3]) + currency + 'Dates.mat');
dates = d.dates; 
%%% If there are fewer historical dates than the request, use as many as
%%% possible
if height(dates) < nDates
    nDates = height(dates);
else
    dates = dates{1:nDates-1, 1};
end
fprintf('Currently generating curve for %s over %d days \n', currency, nDates-1)
%%% Preallocate matrices
f = zeros(n_f, nDates-1);
z = zeros(length(T), nDates);
tic;
it = 1;
block = 0;
blockL = 0;
%%% Create the forward curves.
[newT, n_r, ~] = getDayData(T, discountFactors(:, it));  
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
    [A_s, B_s, C_s] = matrixGeneration(punishment, newT , n_f, n_r, dt, C);
    for day = start:start + blockL - 1
        [~, n_r, newdiscountFactors] = getDayData(T, discountFactors(:, day));  
        logDiscountFactors = -log(newdiscountFactors)';
        f(:,day) = A_s*logDiscountFactors;
        z(1:n_r,day) = 10000*(B_s*(f(:,day)) + C_s*logDiscountFactors);
    end
    start = start + blockL;
    blockL = 0;
    block = block + 1;
    [oldT, n_r, ~] = getDayData(T, discountFactors(:, it));  
    if start >= nDates
        break
    end
end
end


