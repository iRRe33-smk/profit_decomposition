function hessian = create_hessian(c,tau,AE,spot_rates,N,currency,t,Nc,T_cashFlow)
hessian = zeros(6*Nc,6*Nc,N);
sum = zeros(6*Nc,6*Nc);
    for i=1:N
        for j=1:size(c,2)
            if T_cashFlow(i,j)>t
                tau_temp = cell2mat(tau(1,i));
                 if (c(i,j)~=0  && (round(tau_temp(j,1)*365) > 0))
                    index = find(strcmp(string(spot_rates(1,:)),currency(i,j)));
                    spot_rate_temp = cell2mat(spot_rates(2,index));
                    AE_temp = cell2mat(AE(2,index));

                    sum(index*6-5:index*6,index*6-5:index*6) = sum(index*6-5:index*6,index*6-5:index*6) + AE_temp(round(tau_temp(j,1)*365),:)'*AE_temp(round(tau_temp(j,1)*365),:)*tau_temp(j,2)^2*c(i,j)*exp(-spot_rate_temp(t-1,round(tau_temp(j,1)*365))*tau_temp(j,2));
                 end
            end
        end
        hessian(:,:,i) = sum;
        sum = zeros(6*Nc,6*Nc);
    end
end





%{
    hessian = cell (size(tau,2),1);
    for i=1:size(tau,2)
        temp=zeros(width(AE));
        for j=1:size(c)
            temp = temp + AE(round(tau(j,i)*365),:)'*AE(round(tau(j,i)*365),:)*(tau(j,i)^2)*c(j)*exp(-(spot_rates(i,round(tau(j,i)*365))*tau(j,i)));
        end
        hessian{i,1}=temp;
    end
end
%}