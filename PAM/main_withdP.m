%% Run setup

%clear
%cd("PAM")
if ispc
    addpath("termFunctions\")
    addpath("PriceEquation\")
elseif ismac
    addpath("termFunctions/")
    addpath("PriceEquation/")
end

%Reading data from file
fileName = "Test_Case_Realistic.xlsx";

% Retrivering the data from Excel
[numProductsRaw, numProductsFinished, numCurrencies, h_p_finished_matrix, h_p_raw_matrix,...
    h_c_matrix, xsProd_b_matrix, xsProd_s_matrix, xsCurr_b_matrix, FXMatrix, dFMatrix, P_raw_matrix, ...
    dP_raw_matrix, row, currVec, salesExcel, datePeriod, itemVec, finalItemVec, T_max] = excelToMatlab(fileName);

disp("Excel to Matlab done  ")

%% dP Setup
[risk_factors,spot_rates,AE] = dPsetup(currVec);
disp("dPsetup done")

%% Run simulation
close all 

%initiating D for the first day
[D] = getDmatrix(salesExcel,datePeriod, 1, currVec, finalItemVec);
[c, currency, T_cashFlow] = dPsetup_update(currVec, D);


T_max = size(D,3);
numRf = 9;
%Variables to save results from the terms
deltaNPV = zeros(T_max,1);
deltaNPVterms = zeros(T_max,8); %eight terms, incl error
deltaNPVrf = zeros(T_max,numRf); %riskfactors
deltaNPVp = zeros(T_max,numProductsRaw + numProductsFinished); %products
deltaNPVc = zeros(T_max, numCurrencies);%Currencies
deltaNPVcDirect = zeros(T_max, numCurrencies);%Currencies, terms  1 and 2


loopMax = 80;%
%all_equal = ones(T_max,1);
for t = 2:loopMax
    disp(t)
    
    % Gets simulated data from dataset
    [h_p_finished,h_p_raw, h_c, xsProd_s, xsProd_b, xsCurr_b,  P_raw, dP_raw, R, f, df, ... 
         deltaT, numProducts, numCurrencies] = initializeDatastructures( ... 
                numProductsFinished,numProductsRaw, numCurrencies,t,...
                h_p_finished_matrix, h_p_raw_matrix,h_c_matrix, xsProd_b_matrix, xsProd_s_matrix,...
                xsCurr_b_matrix, FXMatrix, dFMatrix, P_raw_matrix,dP_raw_matrix);
    
    % Get relevant cashflows
    prevD = D;
    prevC = c;
    prevCurrency = currency;
    prevT_cashflow = T_cashFlow;
    [D] = getDmatrix(salesExcel,datePeriod, t, currVec, finalItemVec);
    
    % Output where new cashflows has been added: [finalItemIndex, currIndex, dayIndex]
    newSalesIndex = newSales(D, prevD);
    
    %Adding ON interest  to currency holdings
    h_c_matrix(t+1:end, :) = h_c_matrix(t+1:end,:) + (h_c .* (R-1) .* deltaT)'; 

    %gets delta P from priceEquations
    %[dP_finished,P_finished] 
    [c, currency, T_cashFlow] = dPsetup_update(currVec, D);

    [passage_of_time,gradient_delta_risk_factor,hessian_delta_risk_factor,delta_epsilon_i,delta_epsilon_a,dP_finished,P_finished,spot_rate_today, spot_rate_yesterday] = ...
        getDP(risk_factors,spot_rates,AE,t,c,currency,currVec,T_cashFlow,D,prevD,newSalesIndex,prevC,prevCurrency,prevT_cashflow);
    %dP_finished(:,38,10);
    %D = squeeze(D(:,:,t));
    
    %D = squeeze(salesMatrix(:,:,t));
    
    %calculating results from each timestep 
    [timeStepTotal,timeStepRiskFactors, timeStepProducts, timeStepTerms,timeStepCurrencies, timeStepCurrenciesDirect] = ... 
         PAM_timestep(h_p_finished, h_p_raw, h_c, -xsProd_s, -xsProd_b, ... 
         -xsCurr_b, P_finished, dP_finished, P_raw, dP_raw, R, f, df, deltaT, prevD, D, numProducts, numCurrencies, t, T_max);
    
    %saves results in each timestep
    deltaNPV(t) = timeStepTotal;
    deltaNPVp(t,:) = timeStepProducts;
    deltaNPVrf(t,:) = timeStepRiskFactors;
    deltaNPVterms(t,:) = timeStepTerms';
    deltaNPVc(t,:) = timeStepCurrencies;
    deltaNPVcDirect(t,:) = timeStepCurrenciesDirect;
end

%% Make Plots
close all % close all plots before creating new ones

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
hold on;
plot(dates,cumsum(sum(deltaNPVrf(1,1:6),2)),"-", ...
    dates,cumsum(deltaNPVrf(:,1),1),"--", ...
    dates,cumsum(deltaNPVrf(:,2),1),"--", ...
    dates,cumsum(deltaNPVrf(:,3),1),"--", ...
    dates,cumsum(deltaNPVrf(:,4),1),"--", ... 
    dates,cumsum(deltaNPVrf(:,5),1),"--", ...
    dates,cumsum(deltaNPVrf(:,6),1),"--", ...
    "LineWidth",2);
legend( {"cumm. deltaNPV RF", "shift", "twist", "butterfly", "RiskFactor4", "RiskFactor5", "RiskFactor6"}, "Location", "northwest")
hold off;

figure("Name","deltaNPV RiskFactors") 
hold on;
plot(dates,cumsum(sum(deltaNPVrf(:,1:6),2)),"-", ...
    dates,cumsum(deltaNPVrf(:,7),1),"--", ...
    dates,cumsum(deltaNPVrf(:,8),1),"--", ...
    dates,cumsum(deltaNPVrf(:,9),1),"--", ...
    "LineWidth",2);
legend( {"cumm. deltaNPV RF-errors", "Passage of Time (epsilon carry)","deltaEpsilon_a","deltaEpsilon_i"}, "Location", "northwest")
hold off;



% sort out most important products
figure("Name", "deltaNPV Finished Products")
plot(dates, cumsum(sum(deltaNPVp(:,end-numProductsFinished  : end),2)),"-", "LineWidth",2);
hold on;
%prodNames = ["cumm. deltaNPV Finished products", round(rand(1,numProductsFinished)*1000)];
prodNames = ["Cumm deltaNPV Finished Products" ; finalItemVec];
for i = 1:numProductsFinished
    plot(dates, cumsum(deltaNPVp(:,end-numProductsFinished +i)),"--", "LineWidth",2)
        
end
legend( prodNames, "Location", "northwest")

figure("Name", "deltaNPV Raw Products")
plot(dates, cumsum(sum(deltaNPVp(:,1:numProductsRaw ),2)),"-", "LineWidth",2);
hold on;
prodNames = ["cumm deltaNPV Finished Products" ; itemVec];
for i = 1:numProductsRaw
    plot(dates, cumsum(deltaNPVp(:,i)),"--", "LineWidth",2)
        
end
legend( prodNames, "Location", "northwest")



% sort out most important Currencies
figure("Name", "deltaNPV per currencies")
plot(dates, cumsum(sum(deltaNPVc(:,1:numCurrencies),2)),"-", "LineWidth",2);
hold on;
[vals,currIdx] = sort(sum(abs(deltaNPVc),1),"descend");
numCurrPlot = 5;
for i = 1:numCurrPlot 
    plot(dates, cumsum(deltaNPVc(:,currIdx(i))),"--", "LineWidth",2)
        
end
legend( ["Total cummulative";currVec(currIdx(1:numCurrPlot))], "Location", "northwest")


% sort out most important Currencies
figure("Name", "deltaNPV from currency holdings")
plot(dates, cumsum(sum(deltaNPVcDirect(:,1:numCurrencies),2)),"-", "LineWidth",2);
hold on;
[vals,currIdx] = sort(sum(abs(deltaNPVcDirect),1),"descend");
numCurrPlot = 5;
for i = 1:numCurrPlot 
    plot(dates, cumsum(deltaNPVcDirect(:,currIdx(i))),"--", "LineWidth",2)
        
end
legend( ["Total cummulative";currVec(currIdx(1:numCurrPlot))], "Location", "northwest")


%Finished vs unfinished products
%figure("Name","Finished vs Unifinisehd products")
%hold on;
%for pr 
%plot(dates, d)

