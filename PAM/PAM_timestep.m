
function [timeStepTotal,timeStepRiskFactors, timeStepProducts, timeStepError] = ... 
    PAM_timestep(h_p_finished, h_p_raw, h_c, xsProd_s, xsProd_b, xsCurr_b, P_finished, dP_finished, P_raw, dP_raw, R, f, df, deltaT, D, numProducts, numCurrencies)

%h_p = [h_p_raw ; h_p_finished];
T1 = term1(h_c, R, f);

T2 = term2(h_c,R, df);

T3 = term3(h_p_finished, D, df);

T4 = term4(xsCurr_b,f);

T5 = term5(xsProd_s, xsProd_b, f);

%splits equation 6 into 2 parts. One for unObserved Prices, one with
%observwd prices.
[T6_riskFactors, T6_unObs_allSources] = term6_unObservable(h_p_finished,dP_finished,f);
T6_observable = term6_observable(h_p_raw,dP_raw);

T6_allSources = [T6_observable ; T6_unObs_allSources];


T7 = term7(h_p_finished,P_finished,D,f, df);

error_f = termError(dP_finished, df, numProducts);

timeStepTotal = T1 +T2 + sum(T3) + T4 + T5 + sum(T6_allSources,"all") + sum(T7) + sum(error_f,"all");

timeStepRiskFactors = sum(T6_riskFactors,1);%

disp(size(T3))
disp(size(sum(T6_allSources,2)))
disp(size(T7))
disp(size(sum(error_f, 2)))
timeStepProducts = sum(T6_allSources,2) + sum(error_f,2);
timeStepProducts(end-1:end,1) = T3 + T7;
%timeStepProducts = T3 + sum(T6_allSources,2) + T7 + sum(error_f, 2);

timeStepError = sum(error_f,"all");

timeStepTerms = [sum(T1,"all"), sum(T2,"all"), sum(T3,"all"), sum(T4,"all"), sum(T5,"all"), sum(T6_allSources,"all"), sum(T7,"all"), timeStepError];

end