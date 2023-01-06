function [risk_factors,spot_rates,AE,forward_dates] = dPsetup(currVec,T_max)

if ispc
   addpath("PAM\PriceEquation\")
elseif ismac
    addpath("PAM/PriceEquation/")
end

if (~exist('forward_rates','var'))
    [forward_rates, forward_dates] = getForwardRate();
    disp("forward rates found")
else
    disp("forward rates already exist")
end

[risk_factors, spot_rates, AE] = getPCAdata(forward_rates,forward_dates,currVec,T_max);
% risk_factors =1;
% spot_rates=1;
% AE = 1;
end