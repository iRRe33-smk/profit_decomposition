[currVec,salesMatrix]=testExcelToMatlab();

%c(assets, size)
maxCashFlows = 2; %TODO: calculate max cashflows
c=zeros(size(salesMatrix,1),maxCashFlows);
T_cashFlow = zeros(size(salesMatrix,1),maxCashFlows);
currency = strings([size(salesMatrix,1),maxCashFlows]);
n=1;
for i=1:size(salesMatrix,1)
    for t=1:size(salesMatrix,3)
        for j=1:size(salesMatrix,2)
            if salesMatrix(i,j,t) ~= 0
                c(i,n)=salesMatrix(i,j,t);
                currency(i,n)=currVec(j);
                T_cashFlow(i,n) = t;
                n=n+1;
            end
        end
    end
    n=1;
end

if (~exist('forward_rates','var'))
    forward_rates = getForwardRate();
end

[risk_factors, spot_rates, AE] = getPCAdata(forward_rates,currVec);
%%
T_start = 2;
tau = mat2cell(repmat(zeros(size(c,2),size(salesMatrix,3)-T_start+1),1,size(c,1)),size(c,2),repmat(size(salesMatrix,3)-T_start+1,1,size(c,1)));
for i=1:size(c,1)
    tau(1,i) = mat2cell(calculate_tau(T_cashFlow(i,:),T_start,size(salesMatrix,3)),size(c,2),size(salesMatrix,3)-T_start+1);
end
t = T_start;
dP = delta_barPrice_Function(risk_factors,spot_rates,AE,tau,t,c,currency,currVec);
