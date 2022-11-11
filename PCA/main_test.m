%Get data from excel
[c, tau] = read_from_excel()


%Get forwardrate curves by running create_curve.m
if (~exist('forward_rates','var'))
    forward_rates = create_curve();
    
end

%Run get_PCA_data.m and receive gradient, hessian and riskfactors and plot for shift, twist and butterfly
[risk_factors, gradient, hessian] = get_PCA_data(c, tau,forward_rates);


