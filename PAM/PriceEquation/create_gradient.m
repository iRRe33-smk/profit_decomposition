function gradient = create_gradient(c,tau,AE,spot_rates,N,currency,t,Nc)

gradient = zeros(6*Nc,N);
sum = zeros(6*Nc,1);
    for i=1:N
        for j=1:size(c,2)
            tau_temp = cell2mat(tau(1,i));
             if (c(i,j)~=0  && (round(tau_temp(j,1)*365) > 0))
                index = find(strcmp(string(spot_rates(1,:)),currency(i,j)));
                spot_rate_temp = cell2mat(spot_rates(2,index));
                AE_temp = cell2mat(AE(2,index));
                
                sum(index*6-5:index*6,1) = sum(index*6-5:index*6,1) - AE_temp(round(tau_temp(j,1)*365),:)'*tau_temp(j,2)*c(i,j)*exp(-spot_rate_temp(t-1,round(tau_temp(j,1)*365))*tau_temp(j,2));

            %gradient(i,:) = gradient(i,:) + -AE(round(tau(j,i)*365),:)*tau(j,i)*c(j)*exp(-(spot_rates(i,round(tau(j,i)*365))*tau(j,i)));
             end
        end
        gradient(:,i) = sum;
        sum = zeros(6*Nc,1);
    end
end