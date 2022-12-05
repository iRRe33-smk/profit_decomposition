
function [timeStepTotal,timeStepRiskFactors, timeStepProducts, timeStepError] = PAM_timestep(h_p_finished, h_p_raw, h_c, xs_s, xs_b, P, dP_finished, dP_raw, R, f, df, deltaT, D, numProducts, numCurrencies)

%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

h_p = [h_p_finished ; h_p_raw];
T1 = term1(h_c, R, f);

T2 = term2(h_c,R, df);

T3 = term3(h_p, D, df);

T4 = term4(xs_b,f);

T5 = term5(xs_s, xs_b, f);

%splits equation 6 into 2 parts. One for unObserved Prices, one with
%observwd prices.
[T6_riskFactors, T6_unObs_allSources] = term6_unObservable(h_p_finished,dP_finished,f);
T6_observable = term6_observable(h_p_raw,dP_raw, f);

T6_allSources = [T6_unObs_allSources ; T6_observable];


T7 = term7(h_p,P,D,f, df);

error_f = termError(dP_finished, df, numProducts);

timeStepTotal = T1 +T2 + sum(T3) + T4 + T5 + sum(T6_allSources,"all") + sum(T7) + sum(error_f,"all");

timeStepRiskFactors = sum(T6_riskFactors,1);%

timeStepProducts = T3 + sum(T6_allSources,2) + T7 + sum(error_f, 2);

timeStepError = sum(error_f,"all");

timeStepTerms = [sum(T1,"all"), sum(T2,"all"), sum(T3,"all"), sum(T4,"all"), sum(T5,"all"), sum(T6_allSources,"all"), sum(T7,"all"), timeStepError];

end