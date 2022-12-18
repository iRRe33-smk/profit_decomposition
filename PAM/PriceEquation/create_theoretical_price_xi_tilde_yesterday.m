function theoretical_price_xi_tilde = create_theoretical_price_xi_tilde_yesterday(c,tau,spot_rates,N,t,currency,Nc,T_cashFlow)
%theoretical_price_xi_tilde = zeros(nP,nC,nRF);
%nP = N;
%nC = length(currVec);
%nRF = 6;
sum = zeros(1,Nc);
theoretical_price_xi_tilde = zeros(N,Nc);
%for k = 1:nRF
    for i = 1:N % (c,1) dvs. mängden assets
        for j = 1:size(c,2)
            if T_cashFlow(i,j)>(t-1)
            tau_temp = cell2mat(tau(1,i));
                
                    index = find(strcmp(string(spot_rates(1,:)),currency(i,j)));
                    spot_rate_temp = cell2mat(spot_rates(2,index));
                if (c(i,j)~=0  && (round(tau_temp(j,1)*365) > 0))
                    sum(index) = sum(index) + c(i,j)*exp(-spot_rate_temp(t-1,round(tau_temp(j,1)*365))*(tau_temp(j,2)+ (1/365)));
                elseif (c(i,j)~=0  && (round(tau_temp(j,1)*365) == 0))
                    sum(index) = sum(index) + c(i,j);
                end
            end
        end
        theoretical_price_xi_tilde(i,:) = sum;
        sum = zeros(1,Nc); %nollställd
    end

end