addpath termFunctions\
printRes = true;
%These are valid in a single timestep

[h, x_s, x_b, s_s, s_b, P, dP, R, f, df, dT, D, numProducts, numCurrencies] = initializeDatastructures();

%currency_codes = ["AFA", "ALL", "DZD", "AOA", "ARS", "AMD", "AWG", "AUD", "AZN", "BSD", "BHD", "BDT", "BBD", "BYR", "BEF", "BZD", "BMD", "BTN", "BTC", "BOB", "BAM", "BWP", "BRL", "GBP", "BND", "BGN", "BIF", "KHR", "CAD", "CVE", "KYD", "XOF", "XAF", "XPF", "CLP", "CNY", "COP", "KMF", "CDF", "CRC", "HRK", "CUC", "CZK", "DKK", "DJF", "DOP", "XCD", "EGP", "ERN", "EEK", "ETB", "EUR", "FKP", "FJD", "GMD", "GEL", "DEM", "GHS", "GIP", "GRD", "GTQ", "GNF", "GYD", "HTG", "HNL", "HKD", "HUF", "ISK", "INR", "IDR", "IRR", "IQD", "ILS", "ITL", "JMD", "JPY", "JOD", "KZT", "KES", "KWD", "KGS", "LAK", "LVL", "LBP", "LSL", "LRD", "LYD", "LTL", "MOP", "MKD", "MGA", "MWK", "MYR", "MVR", "MRO", "MUR", "MXN", "MDL", "MNT", "MAD", "MZM", "MMK", "NAD", "NPR", "ANG", "TWD", "NZD", "NIO", "NGN", "KPW", "NOK", "OMR", "PKR", "PAB", "PGK", "PYG", "PEN", "PHP", "PLN", "QAR", "RON", "RUB", "RWF", "SVC", "WST", "SAR", "RSD", "SCR", "SLL", "SGD", "SKK", "SBD", "SOS", "ZAR", "KRW", "XDR", "LKR", "SHP", "SDG", "SRD", "SZL", "SEK", "CHF", "SYP", "STD", "TJS", "TZS", "THB", "TOP", "TTD", "TND", "TRY", "TMT", "UGX", "UAH", "AED", "UYU", "USD", "UZS", "VUV", "VEF", "VND", "YER", "ZMK"];
%currencyIDs = currency_codes(1:numCurrencies);
%productIDs = convertStringsToChars(int2str(randi(10000, numProducts, 1)));


baseCurrInd = 1;
results = zeros(numProducts , numCurrencies);
T1 = term1(h(1:numCurrencies,1),R, f);

T2 = term2(h(1:numCurrencies,1),R, df);

T3 = term3(h, D, df);

T4 = term4(s_b(1:numCurrencies), x_b(1:numCurrencies),f);

T5 = term5(s_s, x_s, s_b, x_b, f);

T6 = term6(h,dP,f);

T7 = term7(h,P,D,f, df);

error_f = termError(dP, df);

results(1,:) = T1' + T2'; %product independent 
results(:,1) = results(:,1) + T5 + T7 + error_f; %in base currency
results = results + T3 + T6;


if printRes

    disp(T1) %per Curr
    disp(T2) %per Curr
    disp(T3) %per Prod x Curr
    disp(T4) %per Curr x Curr
    disp(T5) %per Prod
    disp(T6) %per Prod x Curr
    disp(T7) %per Prod
    disp(error_f) %per Prod
    
    resultsTable = table(results);
   

    disp(resultsTable)
end

