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
%%
[risk_factors, spot_rates, AE] = getPCAdata(forward_rates,currVec);



%%
% for j =1:2
%     T_start = 20+j;
%     T_tau = T_start-1;
%     tau = mat2cell(repmat(zeros(size(c,2),size(salesMatrix,3)-T_tau+1),1,size(c,1)),size(c,2),repmat(size(salesMatrix,3)-T_tau+1,1,size(c,1)));
%     for i=1:size(c,1)
%         tau(1,i) = mat2cell(calculate_tau(T_cashFlow(i,:),T_tau,size(salesMatrix,3)),size(c,2),size(salesMatrix,3)-T_tau+1);
%     end
%     t = T_start;
%     if j==1
%         [passage_of_time,gradient_delta_risk_factor,hessian_delta_risk_factor,delta_epsilon_i,delta_epsilon_a,dP1,P_yesterday, theoretical_price_s1] = delta_barPrice_Function(risk_factors,spot_rates,AE,tau,t,c,currency,currVec);
%     else
%         [passage_of_time,gradient_delta_risk_factor,hessian_delta_risk_factor,delta_epsilon_i,delta_epsilon_a,dP2,P_yesterday, theoretical_price_s2] = delta_barPrice_Function(risk_factors,spot_rates,AE,tau,t,c,currency,currVec);
% 
%     end
% end
% theoretical_price_s1(:,38)
% dP2(:,38,10)+theoretical_price_s1(:,38)
% theoretical_price_s2(:,38)
% price_vector=zeros(2,27);
% passage_time=zeros(2,27);
% delta_epsilon_a_vector=zeros(2,27);
% delta_epsilon_i_vector=zeros(2,27);
for t = 2:28
[passage_of_time,gradient_delta_risk_factor,hessian_delta_risk_factor,delta_epsilon_i,delta_epsilon_a,dP,P_yesterday,spot_rate_today] = getDP(risk_factors,spot_rates,AE,t,c,currency,currVec,T_cashFlow,salesMatrix);

% price_vector(:,t-1) = dP(:,38,10);
% passage_time(:,t-1) = passage_of_time(:,38);
% delta_epsilon_a_vector(:,t-1) = dP(:,38,8);
% delta_epsilon_i_vector(:,t-1)=delta_epsilon_i(:,38);
end

