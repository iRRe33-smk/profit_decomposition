function [forward_rates]=getForwardRate()
%%
path = pwd;
path = path(1:end-4);
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

          
for i = 1:length(currencies)
    if ~(exist(string([path, '\PAM\PriceEquation\ForwardCurves\']) + currencies(i) + '.mat', 'file'))
        [f] = getCurves(currencies(i), deviationPunishment(i), 2520, path);
        save(string([path, '\PAM\PriceEquation\ForwardCurves\']) + currencies(i) + '.mat', 'f');
    end
end
   %% 
          
if ispc
    cd("PriceEquation\")
    myDir = ".\ForwardCurves\";
elseif ismac
    cd("PriceEquation/")
    myDir = "./ForwardCurves/";
end
%myDir = "\\ad.liu.se\home\einei581\Documents\CDIO\profit_decomposition-main (1)\profit_decomposition-main\PAM\termFunctions\3MonthCurves\";
%myDir = ".\3MonthCurves\";
myFiles = dir(fullfile(myDir,'*.mat'));
%disp(myFiles)
for k = 1:length(myFiles)
    baseFileName = myFiles(k).name;
    currency_temp =erase(baseFileName, ".mat");
    fullFileName = fullfile(myDir,baseFileName);
    forward_rate_temp = load(fullFileName);
    forward_rates(k,:) = {currency_temp;forward_rate_temp.f'};

end
%go back to PAM-dir

cd("..")

end