function [risk_factors, eigen_values, eigen_vectors,C] = create_riskfactor(fAll)

    f_diff=create_fS_diff(fAll);
    C=cov(f_diff);
    [eigen_vectors,eigen_values]=eigs(C,6);
    
    risk_factors = eigen_vectors'*f_diff';
end 

function f_diff = create_fS_diff(fAll)

    f_diff=zeros(size(fAll,1)-1,size(fAll,2));

    for i=1:size(fAll,1)-1
        f_diff(i,:)=fAll(i+1,:)-fAll(i,:);
    end

end