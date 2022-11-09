%Import data for cash flows: size, tau and timestamp

c = readmatrix('PCA_test.xlsx', 'sheet', 'Cash Flows', 'Range', 'F6:F7');
tau = readmatrix('PCA_test.xlsx', 'sheet', 'Cash Flows', 'Range', 'G6:Z7');

%Get forwardrate curves by running create_curve.m
if (~exist('forward_rates','var'))
    forward_rates = create_curve();
    
end

%Run get_PCA_data.m and receive gradient, hessian and riskfactors and plot for shift, twist and butterfly
[risk_factors, gradient, hessian] = get_PCA_data(c, tau,forward_rates);


