addpath termFunctions\

%These are valid in a single timestep
for t=1:10
    [h_p, h_c, xs_s, xs_b, P, dP, R, f, df, deltaT, D, numProducts, numCurrencies] = initializeDatastructures();
    [timeStepTotal,timeStepRiskFactors, timeStepProducts, timeStepError] = PAM_timestep(h_p, h_c, xs_s, xs_b, P, dP, R, f, df, deltaT, D, numProducts, numCurrencies);
    disp(timeStepTotal);
end








%%old stuff, to be discarded
%printRes = true;

%currency_codes = ["AFA", "ALL", "DZD", "AOA", "ARS", "AMD", "AWG", "AUD", "AZN", "BSD", "BHD", "BDT", "BBD", "BYR", "BEF", "BZD", "BMD", "BTN", "BTC", "BOB", "BAM", "BWP", "BRL", "GBP", "BND", "BGN", "BIF", "KHR", "CAD", "CVE", "KYD", "XOF", "XAF", "XPF", "CLP", "CNY", "COP", "KMF", "CDF", "CRC", "HRK", "CUC", "CZK", "DKK", "DJF", "DOP", "XCD", "EGP", "ERN", "EEK", "ETB", "EUR", "FKP", "FJD", "GMD", "GEL", "DEM", "GHS", "GIP", "GRD", "GTQ", "GNF", "GYD", "HTG", "HNL", "HKD", "HUF", "ISK", "INR", "IDR", "IRR", "IQD", "ILS", "ITL", "JMD", "JPY", "JOD", "KZT", "KES", "KWD", "KGS", "LAK", "LVL", "LBP", "LSL", "LRD", "LYD", "LTL", "MOP", "MKD", "MGA", "MWK", "MYR", "MVR", "MRO", "MUR", "MXN", "MDL", "MNT", "MAD", "MZM", "MMK", "NAD", "NPR", "ANG", "TWD", "NZD", "NIO", "NGN", "KPW", "NOK", "OMR", "PKR", "PAB", "PGK", "PYG", "PEN", "PHP", "PLN", "QAR", "RON", "RUB", "RWF", "SVC", "WST", "SAR", "RSD", "SCR", "SLL", "SGD", "SKK", "SBD", "SOS", "ZAR", "KRW", "XDR", "LKR", "SHP", "SDG", "SRD", "SZL", "SEK", "CHF", "SYP", "STD", "TJS", "TZS", "THB", "TOP", "TTD", "TND", "TRY", "TMT", "UGX", "UAH", "AED", "UYU", "USD", "UZS", "VUV", "VEF", "VND", "YER", "ZMK"];
%currencyIDs = currency_codes(1:numCurrencies);
%productIDs = convertStringsToChars(int2str(randi(10000, numProducts, 1)));
%{
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

if printRes

    disp(T1) %scalar
    disp(T2) %scalar
    disp(T3) %per Prod
    disp(T4) %scalar
    disp(T5) %scalar
    disp(T6) %per Prod x riskFactor
    disp(T7) %per Prod
    disp(error_f) %per Prod x riskFactor
    
    disp(timeStepTotal)
    disp(timeStepRiskFactors)
end
%}

