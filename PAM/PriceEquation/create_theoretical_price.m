function theoretical_price = create_theoretical_price(c,tau,spot_rates,N,t,currency,Nc)
%theoretical_price_xi_tilde = zeros(nP,nC,nRF);
%nP = N;
%nC = length(currVec);
%nRF = 6;
sum = zeros(1,Nc);
theoretical_price = zeros(N,Nc);
%for k = 1:nRF
    for i = 1:N % (c,1) dvs. mängden assets
        for j = 1:size(c,2)
            tau_temp = cell2mat(tau(1,i));
            if (c(i,j)~=0  && (round(tau_temp(j,2)*365) > 0))
                index = find(strcmp(string(spot_rates(1,:)),currency(i,j)));
                spot_rate_temp = cell2mat(spot_rates(2,index));
                
               
                sum(index) = sum(index) + c(i,j)*exp(-spot_rate_temp(t,round(tau_temp(j,2)*365))*tau_temp(j,2));
            end
        end
        theoretical_price(i,:) = sum;
        sum = zeros(1,Nc); %nollställd
    end

end