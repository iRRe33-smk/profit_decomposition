function hessian = create_hessian(c,tau,AE,spot_rates)
    hessian = cell (size(tau,2),1);
    for i=1:size(tau,2)
        temp=zeros(width(AE));
        for j=1:size(c)
            temp = temp + AE(round(tau(j,i)*365),:)'*AE(round(tau(j,i)*365),:)*(tau(j,i)^2)*c(j)*exp(-(spot_rates(i,round(tau(j,i)*365))*tau(j,i)));
        end
        hessian{i,1}=temp;
    end
end