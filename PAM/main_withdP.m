%% Run setup

clear
%cd("PAM")
if ispc
    addpath("termFunctions\")
    addpath("PriceEquation\")
elseif ismac
    addpath("termFunctions/")
    addpath("PriceEquation/")
end


% Retrivering the data from Excel
[numProductsRaw, numProductsFinished, numCurrencies, D, h_p_finished_matrix, h_p_raw_matrix,...
    h_c_matrix, xsProd_b_matrix, xsProd_s_matrix, xsCurr_b_matrix, FXMatrix, dFMatrix, P_raw_matrix, ...
    dP_raw_matrix, T_max, currVec] = excelToMatlab();
disp("Excel to Matlab done  ")
%% dP Setup

[risk_factors,spot_rates,AE,c,currency,currVec,salesMatrix,T_cashFlow] = dPsetup(currVec, D);




%% Run simulation

numRf = 6;
%Variables to save results from the terms
deltaNPV = zeros(T_max,1);
deltaNPVterms = zeros(T_max,8); %eight terms, incl error
deltaNPVrf = zeros(T_max,numRf); %riskfactors
deltaNPVp = zeros(T_max,numProductsRaw + numProductsFinished); %products



for t = 2:4%min(T_max,80)
    %disp(t)
    
    % Gets simulated data from dataset
    [h_p_finished,h_p_raw, h_c, xsProd_s, xsProd_b, xsCurr_b,  P_raw,dP_raw, R, f, df, ...
         deltaT, numProducts, numCurrencies] = initializeDatastructures( ... 
                numProductsFinished,numProductsRaw, numCurrencies,t,...
                h_p_finished_matrix, h_p_raw_matrix,h_c_matrix, xsProd_b_matrix, xsProd_s_matrix,...
                xsCurr_b_matrix, FXMatrix, dFMatrix, P_raw_matrix,dP_raw_matrix);
    
    %Adding ON interest  to currency holdings
    h_c_matrix(t+1:end, :) = h_c_matrix(t+1:end,:) + (h_c .* (R-1))'; 

    %gets delta P from priceEquations
    %[dP_finished,P_finished] 
    [passage_of_time,gradient_delta_risk_factor,hessian_delta_risk_factor,delta_epsilon_i,delta_epsilon_a,dP_finished,P_finished] = ...
        getDP(risk_factors,spot_rates,AE,t,c,currency,currVec,T_cashFlow,salesMatrix);
    
    D = squeeze(salesMatrix(:,:,t));
    
    %calculating results from each timestep 
    [timeStepTotal,timeStepRiskFactors, timeStepProducts, timeStepTerms] = ... 
         PAM_timestep(h_p_finished, h_p_raw, h_c, xsProd_s, xsProd_b, ... 
         xsCurr_b, P_finished, dP_finished, P_raw, dP_raw, R, f, df, deltaT, D, numProducts, numCurrencies);
    
    %saves results in each timestep
    deltaNPV(t) = timeStepTotal;
    deltaNPVp(t,:) = timeStepProducts;
    deltaNPVrf(t,:) = timeStepRiskFactors;
    deltaNPVterms(t,:) = timeStepTerms';
end

%% Make Plots
dates = 1:T_max;
figure("Name","Changes in NPV over time Period"); 
hold on
plot(dates, cumsum(deltaNPV),...
    "LineWidth",2)
bar(dates, deltaNPV)
legend( {"Cummulative", "Daily"}, "Location" , "northwest")
hold off


figure("Name","deltaNPV terms")
plot(dates,cumsum(sum(deltaNPVterms,2)),"-", ...
    dates,cumsum(deltaNPVterms(:,1),1),"--", ...
    dates,cumsum(deltaNPVterms(:,2),1),"--", ...
    dates,cumsum(deltaNPVterms(:,3),1),"--", ...
    dates,cumsum(deltaNPVterms(:,4),1),"--", ...
    dates,cumsum(deltaNPVterms(:,5),1),"--", ...
    dates,cumsum(deltaNPVterms(:,6),1),"--", ...
    dates,cumsum(deltaNPVterms(:,7),1),"--", ...
    dates,cumsum(deltaNPVterms(:,8),1),"--", ...
    "LineWidth",2)
legend({"All terms", "term1", "term2", "term3", "term4", "term5", "term6", "term7", "termError"},"Location", "northwest" )


figure("Name","deltaNPV RiskFactors")
plot(dates,cumsum(sum(deltaNPVrf,2)),"-", ...
    dates,cumsum(deltaNPVrf(:,1),1),"--", ...
    dates,cumsum(deltaNPVrf(:,2),1),"--", ...
    dates,cumsum(deltaNPVrf(:,3),1),"--", ...
    dates,cumsum(deltaNPVrf(:,4),1),"--", ...
    dates,cumsum(deltaNPVrf(:,5),1),"--", ...
    dates,cumsum(deltaNPVrf(:,6),1),"--", ...
    "LineWidth",2)
legend( {"cumm. deltaNPV RF", "shift", "twist", "butterfly", "RiskFactor4", "RiskFactor5", "RiskFactor6"}, "Location", "northwest")


% sort out most important products
figure("Name", "deltaNPV Products")
plot(dates, cumsum(sum(deltaNPVp(:,1:numProductsFinished),2)));
hold on;
prodNames = ["cumm. deltaNPV products", round(rand(1,numProductsFinished)*1000)];
for i = 1:numProductsFinished 
    plot(dates, cumsum(deltaNPVp(:,i)),"--")
        
end
legend( prodNames, "Location", "northwest")

%legend({"Total","Drilling Rig", "Drill Box", "Charging Station"}, "Location", "northwest");
