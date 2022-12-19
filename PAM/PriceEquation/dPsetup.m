function [risk_factors,spot_rates,AE,salesMatrix] = dPsetup(currVec)

if ispc
   addpath("PriceEquation\")
elseif ismac
    addpath("PriceEquation/")
end

%[currVec,salesMatrix]=testExcelToMatlab();
%[currVec,salesMatrix] = testExcelToMatlab();

%c(assets, size)
% maxCashFlows = 2; %TODO: calculate max cashflows
% c=zeros(size(salesMatrix,1),maxCashFlows);
% T_cashFlow = zeros(size(salesMatrix,1),maxCashFlows);
% currency = strings([size(salesMatrix,1),maxCashFlows]);
% n=1;
% for i=1:size(salesMatrix,1)
%     for t=1:size(salesMatrix,3)
%         for j=1:size(salesMatrix,2)
%             if salesMatrix(i,j,t) ~= 0
%                 c(i,n)=salesMatrix(i,j,t);
%                 currency(i,n)=currVec(j);
%                 T_cashFlow(i,n) = t;
%                 n=n+1;
%             end
%         end
%     end
%     n=1;
% end

if (~exist('forward_rates','var'))
    forward_rates = getForwardRate();
    disp("forward rates found")
else
    disp("forward rates already exist")
end

[risk_factors, spot_rates, AE] = getPCAdata(forward_rates,currVec);

end