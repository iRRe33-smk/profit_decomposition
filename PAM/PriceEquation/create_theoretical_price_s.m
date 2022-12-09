function [theoretical_price_s] =create_theoretical_price_s(c,tau,AE,spot_rates,N,currency,t,risk_factor,Nc)
theoretical_price_s = zeros(N,Nc);
sum = zeros(1,Nc);

    for i=1:N
        for j=1:size(c,2)
                tau_temp = cell2mat(tau(1,i));
             if (c(i,j)~=0  && (round(tau_temp(j,1)*365) > 0))
                index = find(strcmp(string(spot_rates(1,:)),currency(i,j)));
                spot_rate_temp = cell2mat(spot_rates(2,index));
                AE_temp = cell2mat(AE(2,index));
               

                sum(index) = sum(index) + c(i,j)*exp(-(spot_rate_temp(t-1,round(tau_temp(j,1)*365))+AE_temp(round(tau_temp(j,1)*365),:)*risk_factor(index*6-5:index*6,1))*tau_temp(j,2));

            %gradient(i,:) = gradient(i,:) + -AE(round(tau(j,i)*365),:)*tau(j,i)*c(j)*exp(-(spot_rates(i,round(tau(j,i)*365))*tau(j,i)));
             end
        end
        theoretical_price_s(i,:) = sum;
        sum = zeros(1,Nc);
    end

end