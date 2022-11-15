
function theoretical_price_xi_tilde = create_theoretical_price_xi_tilde(c,tau,spot_rates,N)
T = size(spot_rates,1);
theoretical_price_xi_tilde = zeros(N,T);
sum = 0;

for t = 1:T
    for i = 1:N
        for j = 1:size(c,2)
sum = sum + c(i,j)*exp(-spot_rates(j,t)*tau(i,j,t));
        end
theoretical_price_xi_tilde(i,t) = sum;
sum = 0; %nollställd
    end
end
end