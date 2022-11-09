
function [delta_barPrice] = delta_barPrice_Function(gradient_price,hessian_price,delta_xi,xi_tilde)

% N= N assets
%T = t timesteps
%delta_barPrice = delta_priceT + 1'delta_priceXI + 1'_deltaPriceQ*1 + epsP
%+ epsA + epsI. The equation is implemented down below:
% the numbers,i.e (514) refers to equation numbers from paper
% interestRateInstruments.pdf
%% (514) deltapriceT = "Passage of Time":
for t = 1:T
    for i = 1:N 
    passage_of_time(i,t) = theoretical_price(xi_tilde(t-1,i)) - (theoretical_price(xi_tilde(t-1,i))...
        - sum_currencies_of_dividends(t-1,i)); %sista termen behöver vi summera dividends med currencies.
    end
end


%% (515) delta_PriceXI = "Change in price with respect to risfactors"

for t = 1:T
    for i = 1:N
    delta_price_xi(i,t) = diag(delta_xi(t))*gradient_price(i,t); % gradient from PCA.
    end
end



%% (516)delta_price_Q = "quadratic term of the bar_price"

for t = 1:T
    for i = 1:N
        delta_price_q(i,t) = (1/2)*diag(delta_xi(t))*hessian_price(i,t)*diag(delta_xi(t)); %hessian from PCA
    end
end

%% (517) delta_price_A = "the approximation that does not take into considiration for error terms:

[rowP_xi,col_P_xi] = size(delta_price_xi);
[rowP_q, col_P_q] = size(delta_price_q); % ska vara samma storlek som P_xi antagligen.
onevec_xi = ones(rowP_xi);
onevec_q = ones(rowP_q);

delta_price_a = passage_of_time + transpose(onevec_xi)*delta_price_xi + transpose(onevec_q)*delta_price_q*onevec_q;


%% (510)-(511) Error terms:

%Pricing error epsilon_P, where we attain a matrix of delta epsilons with
%respect to time and specific asset i.
for t = 1:T
    for i = 1:N 
    epsilon_p(i,t) = bar_Price(i,t) - theoretical_Price(i,t);
    end
end

%the change in pricing error delta_epsilon_P:
for t = 1:T
    for i = 1:N
        delta_epsilon_p(i,t) = epsilon_p(i,t)-epsilon_p(i,t-1);
    end
end

%(513)
delta_epsilon_i = theoretical_price-theoretical_price_s;

%(518)
delta_theoretical_price = theoretical_price; % dividend transponat och f, hur görs?


delta_epsilon_a = delta_theoretical_price - delta_price_a - delta_epsilon_i;


%% Complete un-observed pricechange equation;

delta_barPrice = delta_price_a + delta_epsilon_p + delta_epsilon_a + delta_epsilon_i; 




end
