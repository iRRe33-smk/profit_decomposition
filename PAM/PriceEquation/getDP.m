function [passage_of_time,gradient_delta_risk_factor,hessian_delta_risk_factor,delta_epsilon_i,delta_epsilon_a,dP,P_yesterday] = getDP(risk_factors,spot_rates,AE,t,c,currency,currVec,T_cashFlow,salesMatrix)
T_start = t;
T_tau = t-1;
tau = mat2cell(repmat(zeros(size(c,2),size(salesMatrix,3)-T_tau+1),1,size(c,1)),size(c,2),repmat(size(salesMatrix,3)-T_tau+1,1,size(c,1)));
for i=1:size(c,1)
    tau(1,i) = mat2cell(calculate_tau(T_cashFlow(i,:),T_tau,size(salesMatrix,3)),size(c,2),size(salesMatrix,3)-T_tau+1);
end
t = T_start;
[passage_of_time,gradient_delta_risk_factor,hessian_delta_risk_factor,delta_epsilon_i,delta_epsilon_a,dP,P_yesterday] = delta_barPrice_Function(risk_factors,spot_rates,AE,tau,t,c,currency,currVec);

end