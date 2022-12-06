function [dP,P_yesterday] = getDP(risk_factors,spot_rates,AE,t,c,currency,currVec,T_cashFlow,salesMatrix)
T_start = t;
tau = mat2cell(repmat(zeros(size(c,2),size(salesMatrix,3)-T_start+1),1,size(c,1)),size(c,2),repmat(size(salesMatrix,3)-T_start+1,1,size(c,1)));
for i=1:size(c,1)
    tau(1,i) = mat2cell(calculate_tau(T_cashFlow(i,:),T_start,size(salesMatrix,3)),size(c,2),size(salesMatrix,3)-T_start+1);
end
t = T_start;
[dP, P_yesterday] = delta_barPrice_Function(risk_factors,spot_rates,AE,tau,t,c,currency,currVec);

end