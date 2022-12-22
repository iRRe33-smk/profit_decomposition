function [risk_factors,spot_rates,AE] = dPsetup(currVec)

if ispc
   addpath("PriceEquation\")
elseif ismac
    addpath("PriceEquation/")
end

if (~exist('forward_rates','var'))
    forward_rates = getForwardRate();
    disp("forward rates found")
else
    disp("forward rates already exist")
end

[risk_factors, spot_rates, AE] = getPCAdata(forward_rates,currVec);

end