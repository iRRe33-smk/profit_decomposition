
function [timeStepTotal,timeStepRiskFactors, timeStepProducts, timeStepTerms, timeStepCurrencies] = ... 
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
T6_observable = term6_observable(h_p_raw,dP_raw, f);

T6_allSources = [T6_observable ; T6_unObs_allSources];


T7 = term7(h_p_finished,P_finished,D,f, df);

error_f = termError(dP_finished, df, numProducts);


%% print dimensions of all terms
if false
    disp("%%%%%%%%%%%%%%%%%")
    disp(size(T1)) %curr
    disp(size(T2)) %curr
    disp(size(T3)) % curr x finished
    disp(size(T4)) %curr
    disp(size(T5)) % curr
    disp(size(T6_allSources)) % curr x allProd
    disp(size(T7)) % curr x finished
    disp(size(error_f)) % allProd x rf

    disp(size(T6_riskFactors))
end





timeStepTotal = sum(T1, "all") + sum(T2, "all") + sum(T3, "all") + sum(T4, "all") + sum(T5, "all") + sum(T6_allSources, "all") + sum(T7, "all") + sum(error_f,"all");


rftemp = squeeze(sum(sum(T6_riskFactors,1),2));
timeStepRiskFactors  = rftemp(:);

timeStepProducts = sum(T6_allSources,2);% + sum(error_f,2); % contains info for all products

timeStepProducts(end-size(h_p_finished,1)+1:end,1) = sum(T3,1)' + sum(T7,1)'; %Adding values for finished products

timeStepError = [sum(error_f,"all") ; squeeze(sum(sum(T6_riskFactors(:,:,7:end)),2))];

timeStepTerms = [sum(T1,"all"), sum(T2,"all"), sum(T3,"all"), sum(T4,"all"), sum(T5,"all"), sum(T6_allSources,"all"), sum(T7,"all"), sum(timeStepError,"all")];

timeStepCurrencies = T1 + T2 + sum(T3,2) + T4 + T5 + sum(T6_allSources,1)' + sum(T7,2) ;
end