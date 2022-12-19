
function [h_p_finished,h_p_raw, h_c, xsProd_s, xsProd_b, xsCurr_b,  P_raw,dP_raw, R, f, df, ...
     deltaT, numProducts, numCurrencies] = ...
    initializeDatastructures(numProductsFinished,numProductsRaw, numCurrencies,timestep,...
    h_p_finished_matrix, h_p_raw_matrix,h_c_matrix, xsProd_b_matrix, xsProd_s_matrix,...
    xsCurr_b_matrix, FXMatrix, dFMatrix, P_raw_matrix,dP_raw_matrix)

numProducts = numProductsFinished + numProductsRaw;
%numCurrencies = length(currencies);

h_p_finished = h_p_finished_matrix(timestep,:)';
h_p_raw = h_p_raw_matrix(timestep,:)';
h_c = h_c_matrix(timestep,:)';


xsProd_b = xsProd_b_matrix(timestep,:)';
xsProd_s = xsProd_s_matrix(timestep,:)';

xsCurr_b = xsCurr_b_matrix(timestep,:)';

R = ones(numCurrencies,1) * 1.0002;
deltaT = ones(numCurrencies,1) / 365;
f = FXMatrix(timestep,:)';
df = dFMatrix(timestep,:)';

%D = rand(numProducts,numCurrencies); % dividends in this timestep
P_raw = P_raw_matrix(timestep,:)'; % match with currency

dP_raw = squeesze(dP_raw_matrix(:,:,timestep)); %daily Price Differences for Observed Prices all expressed in SEK
end



