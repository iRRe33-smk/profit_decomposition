addpath("termFunctions\")
addpath("priceEquation\")

numProd = 10;
numCurr = 4;
numRf = 6;

T_max = 10;

%Variables to save results from the terms
deltaNPV = zeros(T_max,1);
deltaNPVterms = zeros(T_max,8);
deltaNPVrf = zeros(T_max,numRf); %riskfactors
deltaNPVp = zeros(T_max,numProd); %products

% Retrivering the data from Excel
[numProductsRaw, numProductsFinished, numCurrencies, D, h_p_finished_matrix, h_p_raw_matrix,...
    h_c_matrix, xsProd_b_matrix, xsProd_s_matrix, xsCurr_b_matrix, FXMatrix, dFMatrix, P_raw_matrix, ...
    dP_raw_matrix, T_max] = excelToMatlab();

%[salesMatrix, TimeIndex, Rates] = dPSetUp(.. .. .. )


for t = 1:T_max
    %initializing random data of the right sizes
    [h_p_finished,h_p_raw, h_c, xsProd_s, xsProd_b, xsCurr_b,  P_raw,dP_raw, R, f, df, ...
     deltaT, numProducts, numCurrencies] = ...
    initializeDatastructures(numProductsFinished,numProductsRaw, numCurrencies,timestep,...
    h_p_finished_matrix, h_p_raw_matrix,h_c_matrix, xsProd_b_matrix, xsProd_s_matrix,...
    xsCurr_b_matrix, FXMatrix, dFMatrix, P_raw_matrix,dP_raw_matrix);
    
    %dP = getDP(t,salesMatrix, rates)
    dP_finished = rand(size(h_p_finished,1), numCurr, numRf+1);

    %calculating results from each timestep 
    [timeStepTotal,timeStepRiskFactors, timeStepProducts, timeStepTerms] = ... 
        PAM_timestep(h_p_finished,h_p_raw, h_c, xs_s, xs_b, P, dP_finished, dP_raw, R, f, df, deltaT, D, numProducts, numCurrencies);
    
    deltaNPV(t) = timeStepTotal;
    deltaNPVp(t,:) = timeStepProducts';
    deltaNPVrf(t,:) = timeStepRiskFactors';
    deltaNPVterms(t,:) = timeStepTerms';
end


dates = 1:T_max;

figure("Name","deltaNPV terms")
plot(dates,cumsum(deltaNPV),"-", ...
    dates,cumsum(deltaNPVterms(:,1),1),"--", ...
    dates,cumsum(deltaNPVterms(:,2),1),"--", ...
    dates,cumsum(deltaNPVterms(:,3),1),"--", ...
    dates,cumsum(deltaNPVterms(:,4),1),"--", ...
    dates,cumsum(deltaNPVterms(:,5),1),"--", ...
    dates,cumsum(deltaNPVterms(:,6),1),"--", ...
    dates,cumsum(deltaNPVterms(:,7),1),"--", ...
    dates,cumsum(deltaNPVterms(:,8),1),"--")
legend({"cumm. deltaNPV", "term1", "term2", "term3", "term4", "term5", "term6", "term7", "termError"},"Location", "northwest" )



figure("Name","deltaNPV RiskFactors")
plot(dates,cumsum(deltaNPV),"-", ...
    dates,cumsum(deltaNPVrf(:,1),1),"--", ...
    dates,cumsum(deltaNPVrf(:,2),1),"--", ...
    dates,cumsum(deltaNPVrf(:,3),1),"--", ...
    dates,cumsum(deltaNPVrf(:,4),1),"--", ...
    dates,cumsum(deltaNPVrf(:,5),1),"--", ...
    dates,cumsum(deltaNPVrf(:,6),1),"--")
legend( {"cumm. deltaNPV", "shift", "twist", "butterfly", "RiskFactor4", "RiskFactor5", "RiskFactor6"}, "Location", "northwest")






