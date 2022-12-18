
function theoretical_price_xi_tilde = create_theoretical_price_xi_tilde(c,tau,spot_rates,N,t,currency,Nc,T_cashFlow)
%theoretical_price_xi_tilde = zeros(nP,nC,nRF);
%nP = N;
%nC = length(currVec);
%nRF = 6;
sum = zeros(1,Nc);
theoretical_price_xi_tilde = zeros(N,Nc);
%for k = 1:nRF
    for i = 1:N % (c,1) dvs. mängden assets
        for j = 1:size(c,2)
            if T_cashFlow(i,j)>t
            tau_temp = cell2mat(tau(1,i));
                if (c(i,j)~=0 && (round(tau_temp(j,1)*365) > 0))
                    index = find(strcmp(string(spot_rates(1,:)),currency(i,j)));
                    spot_rate_temp = cell2mat(spot_rates(2,index));


                    sum(index) = sum(index) + c(i,j)*exp(-spot_rate_temp(t-1,round(tau_temp(j,1)*365))*tau_temp(j,2));
                end
            end
        end
        theoretical_price_xi_tilde(i,:) = sum;
        sum = zeros(1,Nc); %nollställd
    end

end