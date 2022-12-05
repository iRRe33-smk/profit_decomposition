function gradient = create_gradient(c,tau,AE,spot_rates,N,currency,t)

gradient = zeros(6,N);
sum = zeros(6,1);
    for i=1:N
        for j=1:size(c,2)
            tau_temp = cell2mat(tau(1,i));
             if (c(i,j)~=0  && (round(tau_temp(j,t-1)*365) > 0))
                index = find(strcmp(string(spot_rates(1,:)),currency(i,j)));
                spot_rate_temp = cell2mat(spot_rates(2,index));
                AE_temp = cell2mat(AE(2,index));
                

                sum = sum - AE_temp(round(tau_temp(j,t-1)*365),:)'*tau_temp(j,t)*c(i,j)*exp(-spot_rate_temp(t-1,round(tau_temp(j,t-1)*365))*tau_temp(j,t));

            %gradient(i,:) = gradient(i,:) + -AE(round(tau(j,i)*365),:)*tau(j,i)*c(j)*exp(-(spot_rates(i,round(tau(j,i)*365))*tau(j,i)));
             end
        end
        gradient(:,i) = sum;
        sum = zeros(6,1);
    end
end