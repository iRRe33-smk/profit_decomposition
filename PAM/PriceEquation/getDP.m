function [passage_of_time,gradient_delta_risk_factor,hessian_delta_risk_factor,delta_epsilon_i,delta_epsilon_a,dP,P_yesterday,spot_rate_today, spot_rate_yesterday] = getDP(risk_factors,spot_rates,AE,t,c,currency,currVec,T_cashFlow,salesMatrix)
T_start = t;
T_tau = t-1;
tau = mat2cell(repmat(zeros(size(c,2),size(salesMatrix,3)-T_tau+1),1,size(c,1)),size(c,2),repmat(size(salesMatrix,3)-T_tau+1,1,size(c,1)));
for i=1:size(c,1)
    tau(1,i) = mat2cell(calculate_tau(T_cashFlow(i,:),T_tau,size(salesMatrix,3)),size(c,2),size(salesMatrix,3)-T_tau+1);
end
t = T_start;
[passage_of_time,gradient_delta_risk_factor,hessian_delta_risk_factor,delta_epsilon_i,delta_epsilon_a,dP,P_yesterday] = delta_barPrice_Function(risk_factors,spot_rates,AE,tau,t,c,currency,currVec,T_cashFlow);
%dP har formen [Number of Assets,Number of currencies, Olika faktorer (riskfaktorer och feltermer) 10 djup]
%Olika faktorer har strukturen:
%1.Riskfaktor 1 (shift)
%2.Riskfaktor 2 (twist)
%...
%6.Riskfaktor 6
%7.Passage of time (epsilon_carry)
%8.delta_epsilon_a
%9.delta_epsilon_i
%10.Alla riskfaktorer och fel

spot_rate_today=zeros(size(currVec,1),1);
for i=1:size(currVec,1)
    spot_rates_temp = cell2mat(spot_rates(2,i));
    spot_rate_today(i) = spot_rates_temp(t,1);
    spot_rate_yesterday(i) = spot_rates_temp(t-1,1);
end
end