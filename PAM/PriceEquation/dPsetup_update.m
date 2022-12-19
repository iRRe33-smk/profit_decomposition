function [c, currency, T_cashFlow] = dPsetup_update(currVec, salesMatrix)

maxCashFlows = 32; %TODO: calculate max cashflows
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


end