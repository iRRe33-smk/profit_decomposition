
function theoretical_price_xi_tilde = create_theoretical_price_xi_tilde(c,tau,spot_rates,N,t,currency)
%theoretical_price_xi_tilde = zeros(nP,nC,nRF);
%nP = N;
%nC = length(currVec);
%nRF = 6;
sum = 0;
theoretical_price_xi_tilde = zeros(N,1);
%for k = 1:nRF
    for i = 1:N % (c,1) dvs. mängden assets
        for j = 1:size(c,2)
            tau_temp = cell2mat(tau(1,i));
            if (c(i,j)~=0 && (round(tau_temp(j,t-1)*365) > 0))
                index = find(strcmp(string(spot_rates(1,:)),currency(i,j)));
                spot_rate_temp = cell2mat(spot_rates(2,index));
                
               
                sum = sum + c(i,j)*exp(-spot_rate_temp(t-1,round(tau_temp(j,t-1)*365))*tau_temp(j,t));
            end
        end
        theoretical_price_xi_tilde(i) = sum;
        sum = 0; %nollställd
    end

end