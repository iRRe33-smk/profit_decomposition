function [risk_factors, eigen_values, eigen_vectors,C] = create_riskfactor(fAll)
    C=cov(fAll);
    [eigen_vectors,eigen_values]=eigs(C,6);
    risk_factors = eigen_vectors'*fAll';
end 
