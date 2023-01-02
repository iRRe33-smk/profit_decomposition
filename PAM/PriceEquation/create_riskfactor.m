function [risk_factors, eigen_values, eigen_vectors,C] = create_riskfactor(fAll,dates,T_max,index)
    C=cov(fAll);
    [eigen_vectors,eigen_values]=eigs(C,6);
    risk_factors_all = eigen_vectors'*fAll';
    size(risk_factors_all);
    j=1;
    for i = 1:index
        if i==1 
            risk_factors_temp(:,j) = risk_factors_all(:,end-index+1);
            j=j+1;

        else
            diff = daysact(dates(end-index+i-1),dates(end-index+i));
            for l = 1:diff-1
                risk_factors_temp(:,j)=risk_factors_temp(:,j-1);
                j=j+1;
            end
            risk_factors_temp(:,j)=risk_factors_all(:,end-index+i);
            j=j+1;
        end
    end
    if index == 1
        for l =1:T_max-1
            risk_factors_temp(:,j) = risk_factors_temp(:,j-1);
            j=j+1;
        end
    end
    risk_factors = risk_factors_temp(:,end-T_max+1:end);
end 
