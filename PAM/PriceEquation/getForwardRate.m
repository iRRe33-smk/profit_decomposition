function [forward_rates]=getForwardRate()
if ispc
    cd("PriceEquation\")
    myDir = ".\3MonthCurves\";
elseif ismac
    cd("PriceEquation/")
    myDir = "./3MonthCurves/";
end
%myDir = "\\ad.liu.se\home\einei581\Documents\CDIO\profit_decomposition-main (1)\profit_decomposition-main\PAM\termFunctions\3MonthCurves\";
%myDir = ".\3MonthCurves\";
myFiles = dir(fullfile(myDir,'*.mat'));
%disp(myFiles)
for k = 1:length(myFiles)/2
    baseFileName = myFiles(2*k-1).name;
    currency_temp =erase(baseFileName, ".mat");
    fullFileName = fullfile(myDir,baseFileName);
    forward_rate_temp = load(fullFileName);
    forward_rates(k,:) = {currency_temp;forward_rate_temp.f'};

end
%go back to PAM-dir
cd("..\")

end