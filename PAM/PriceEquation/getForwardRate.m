function [forward_rates, forward_dates]=getForwardRate()
%%
path = pwd;


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

if ispc
    path1 = '\PAM\PriceEquation\ForwardCurves\';
    path2 = '\PAM\PriceEquation\ForwardDates\';
end
if ismac
    path1 = '/PAM/PriceEquation/ForwardCurves/';
    path2 = '/PAM/PriceEquation/ForwardDates/';
end
          
if ~(exist(string([path, path1]), 'dir'))
    mkdir(string([path, path1]));
end

if ~(exist(string([path, path2]), 'dir'))
    mkdir(string([path, path2]));
end

addpath(genpath("PAM"))
          
for i = 1:length(currencies)
    if ~(exist(string([path, path1]) + currencies(i) + '.mat', 'file')) || ~(exist(string([path, path2]) + currencies(i) + 'Dates.mat', 'file')) 
        [f, dates] = getCurves(currencies(i), deviationPunishment(i), 2520, path);
        save(string([path, path1]) + currencies(i) + '.mat', 'f');
        save(string([path, path2]) + currencies(i) + 'Dates.mat', 'dates');
    end
end
%% 
          

myDir = string([path, path1]);

myFiles = dir(fullfile(myDir,'*.mat'));

for k = 1:length(myFiles)
    baseFileName = myFiles(k).name;
    currency_temp =erase(baseFileName, ".mat");
    fullFileName = fullfile(myDir,baseFileName);
    forward_rate_temp = load(fullFileName);
    forward_rates(k,:) = {currency_temp;forward_rate_temp.f'};
end
%%
myDir = string([path, path2]);

myFiles = dir(fullfile(myDir,'*.mat'));

for k = 1:length(myFiles)
    baseFileName = myFiles(k).name;
    currency_temp =erase(baseFileName, ".mat");
    fullFileName = fullfile(myDir,baseFileName);
    forward_date_temp = load(fullFileName);
    forward_dates(k,:) = {currency_temp;forward_date_temp.dates};
end
end