
function [timeStepTotal,timeStepRiskFactors, timeStepProducts, timeStepError] = PAM_timestep(h_p, h_c, xs_s, xs_b, P, dP, R, f, df, deltaT, D, numProducts, numCurrencies)

%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

T1 = term1(h_c, R, f);

T2 = term2(h_c,R, df);

T3 = term3(h_p, D, df);

T4 = term4(xs_b,f);

T5 = term5(xs_s, xs_b, f);

T6 = term6(h_p,dP,f);

T7 = term7(h_p,P,D,f, df);

error_f = termError(dP, df);

timeStepTotal = T1 +T2 + sum(T3) + T4 + T5 + sum(T6,"all") + sum(T7) + sum(error_f,"all");

timeStepRiskFactors = sum(T6,1) + sum(T7,1);

timeStepProducts = T3 + sum(6,2) + T7 + sum(error_f, 2);

timeStepError = sum(error_f,"all");

timeStepTerms = [sum(T1,"all"), sum(T2,"all"), sum(T3,"all"), sum(T4,"all"), sum(T5,"all"), sum(T6,"all"), sum(T7,"all"), timeStepError];

end