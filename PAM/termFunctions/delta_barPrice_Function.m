function [delta_barPrice] = delta_barPrice_Function(gradient,Hessian,delta_xi,xi_tilde)

% N= N assets
%T = t timesteps
%delta_barPrice = delta_priceT + 1'delta_priceXI + 1'_deltaPriceQ*1 + epsP
%+ epsA + epsI. The equation is implemented down below:
%% deltapriceT = "Passage of Time":
for t = 1:T
    for i = 1:N 
    passage_of_time = theoretical_price(xi_tilde(t-1,i)) - (theoretical_price(xi_tilde(t-1,i))...
        - sum_currencies_of_dividends(t-1,i)); %sista termen behöver vi summera dividends med currencies.
    end
end


%% delta_PriceXI = "Change in price with respect to risfactors"

for t = 1:T
    for i = 1:N
    delta_price_xi(t,i) = diag(delta_xi(t))*gradient_price(t,i);
    end
end



%% delta_price_Q = "quadratic term of the bar_price"

for t = 1:T
    for i = 1:N
        delta_price_q = (1/2)*diag(delta_xi(t))*hessian_price(t,i)*diag(delta_xi(t));
    end
end

%% Error terms:

%Pricing error epsilon_P, where we attain a matrix of delta epsilons with
%respect to time and specific asset i.
for t = 1:T
    for i = 1:N 
    epsilon_P(t,i) = bar_Price(t,i)- theoretical_Price(t,i);
    end
end

%the change in pricing error delta_epsilon_P:
for t = 1:T
    for i = 1:N
        delta_epsilon_P(t,i) = epsilon_P(t,i)-epsilon_P(t-1,i);
    end
end





end