%% Run setup

clear
%cd("PAM")
addpath("termFunctions\")
addpath("PriceEquation\")


[risk_factors,spot_rates,AE,c,currency,currVec,salesMatrix,T_cashFlow] = dPsetup();

[numProdFinished, numCurr, T_max] = size(salesMatrix);
%disp([numProdFinished, numCurr, T_max])
numProdRaw = 5; % remove when read excel finished
numRf = 6;

%% Run simulation

%Variables to save results from the terms
deltaNPV = zeros(T_max,1);
deltaNPVterms = zeros(T_max,8); %eight terms, incl error
deltaNPVrf = zeros(T_max,numRf); %riskfactors
deltaNPVp = zeros(T_max,numProdRaw + numProdFinished); %products

for t = 2:T_max
    % creates placeholder until readExcel has been completed
    [h_p_finished,h_p_raw, h_c, xsProd_s, xsProd_b, xsCurr_b,  P_raw, dP_raw, R, f, df, deltaT, numProducts, numCurrencies] = ...
           initializeDatastructures(numProdFinished,numProdRaw,numCurr);
    
    %gets delta P from priceEquations
    [dP_finished,P_finished] = getDP(risk_factors,spot_rates,AE,t,c,currency,currVec,T_cashFlow,salesMatrix);
    D = squeeze(salesMatrix(:,:,t));
    
    %calculating results from each timestep 
    [timeStepTotal,timeStepRiskFactors, timeStepProducts, timeStepTerms] = ... 
         PAM_timestep(h_p_finished, h_p_raw, h_c, xsProd_s, xsProd_b, xsCurr_b, P_finished, dP_finished, P_raw, dP_raw, R, f, df, deltaT, D, numProducts, numCurrencies);
    
    %saves results in each timestep
    deltaNPV(t) = timeStepTotal;
    deltaNPVp(t,:) = timeStepProducts';
    deltaNPVrf(t,:) = timeStepRiskFactors';
    deltaNPVterms(t,:) = timeStepTerms';
end

%% Make Plots
dates = 1:T_max;

figure("Name","deltaNPV terms")
plot(dates, cumsum(deltaNPV), "-",  ...
    dates,cumsum(sum(deltaNPVterms,2)),"-", ...
    dates,cumsum(deltaNPVterms(:,2),1),"--", ...
    dates,cumsum(deltaNPVterms(:,1),1),"--", ...
    dates,cumsum(deltaNPVterms(:,3),1),"--", ...
    dates,cumsum(deltaNPVterms(:,4),1),"--", ...
    dates,cumsum(deltaNPVterms(:,5),1),"--", ...
    dates,cumsum(deltaNPVterms(:,6),1),"--", ...
    dates,cumsum(deltaNPVterms(:,7),1),"--", ...
    dates,cumsum(deltaNPVterms(:,8),1),"--")
legend({"cumm deltaNPV","cumm. deltaNPV Terms", "term1", "term2", "term3", "term4", "term5", "term6", "term7", "termError"},"Location", "northwest" )



figure("Name","deltaNPV RiskFactors")
plot(dates,cumsum(sum(deltaNPVrf,2)),"-", ...
    dates,cumsum(deltaNPVrf(:,1),1),"--", ...
    dates,cumsum(deltaNPVrf(:,2),1),"--", ...
    dates,cumsum(deltaNPVrf(:,3),1),"--", ...
    dates,cumsum(deltaNPVrf(:,4),1),"--", ...
    dates,cumsum(deltaNPVrf(:,5),1),"--", ...
    dates,cumsum(deltaNPVrf(:,6),1),"--")
legend( {"cumm. deltaNPV RF", "shift", "twist", "butterfly", "RiskFactor4", "RiskFactor5", "RiskFactor6"}, "Location", "northwest")



[~, sortedIDX] = sort(sum(abs(deltaNPVp(end,:)),1),"descend");
prodNames = round(rand(1,25)*1000);
numPlotted = 5;
figure("Name", "deltaNPV Products"); 
hold on
plot(dates,cumsum(sum(deltaNPVp,2))); 
for i=sortedIDX(1:numPlotted)
    plot(dates,cumsum(deltaNPVp(:,i),1), "--");

end
legend(["Total- Products", prodNames(sortedIDX(1:numPlotted))], "Location", "northwest")
hold off;


%{
figure("Name", "deltaNPV Products")
plot(dates, cumsum(deltaNPVp),"-"...
    dates, cumsum(deltaNPVp(:,1),1), "--",...
    dates, cumsum(deltaNPVp(:,1),1), "--",...
    dates, cumsum(deltaNPVp(:,1),1), "--",...
    dates, cumsum(deltaNPVp(:,1),1), "--",...
    dates, cumsum(deltaNPVp(:,1),1), "--",...
    dates, cumsum(deltaNPVp(:,1),1), "--",...
    dates, cumsum(deltaNPVp(:,1),1), "--",...);
%}