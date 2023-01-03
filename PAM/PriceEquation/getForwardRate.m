function [forward_rates, forward_dates]=getForwardRate()
%%
path = pwd;
%path = path(1:end-4);
%path = 'C:\Users\adame\Desktop\2Jan\profit_decomposition'; %%% Path to profit_decomposition

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

if ~(exist(string([path, '\PAM\PriceEquation\ForwardCurves']), 'dir'))
    mkdir(string([path, '\PAM\PriceEquation\ForwardCurves']));
end

if ~(exist(string([path, '\PAM\PriceEquation\ForwardDates']), 'dir'))
    mkdir(string([path, '\PAM\PriceEquation\ForwardDates']));
end

          
for i = 1:length(currencies)
    if ~(exist(string([path, '\PAM\PriceEquation\ForwardCurves\']) + currencies(i) + '.mat', 'file')) || ~(exist(string([path, '\PAM\PriceEquation\ForwardDates\']) + currencies(i) + 'Dates.mat', 'file')) 
        [f, dates] = getCurves(currencies(i), deviationPunishment(i), 2520, path);
        save(string([path, '\PAM\PriceEquation\ForwardCurves\']) + currencies(i) + '.mat', 'f');
        save(string([path, '\PAM\PriceEquation\ForwardDates\']) + currencies(i) + 'Dates.mat', 'dates');
    end
end
   %% 
          
if ispc
%   cd("PriceEquation\")
    myDir = path+"\PAM\PriceEquation\ForwardCurves\";
elseif ismac
%    cd("PriceEquation/")
    myDir = path + "/PAM/PriceEquation/ForwardCurves/";
end
myFiles = dir(fullfile(myDir,'*.mat'));

for k = 1:length(myFiles)
    baseFileName = myFiles(k).name;
    currency_temp =erase(baseFileName, ".mat");
    fullFileName = fullfile(myDir,baseFileName);
    forward_rate_temp = load(fullFileName);
    forward_rates(k,:) = {currency_temp;forward_rate_temp.f'};

end
%go back to PAM-dir

if ispc
%   cd("PriceEquation\")
    myDir = path+"\PAM\PriceEquation\ForwardDates\";
elseif ismac
%    cd("PriceEquation/")
    myDir = path + "/PAM/PriceEquation/ForwardDates/";
end
myFiles = dir(fullfile(myDir,'*.mat'));
%disp(myFiles)
for k = 1:length(myFiles)
    baseFileName = myFiles(k).name;
    currency_temp =erase(baseFileName, ".mat");
    fullFileName = fullfile(myDir,baseFileName);
    forward_date_temp = load(fullFileName);
    forward_dates(k,:) = {currency_temp;forward_date_temp.dates};

end
%cd("..")

end