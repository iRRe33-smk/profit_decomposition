
function [passage_of_time,gradient_delta_risk_factor,hessian_delta_risk_factor,delta_epsilon_i,delta_epsilon_a,dP,P_yesterday] = delta_barPrice_Function(risk_factors,spot_rates,AE,tau,t,c,currency,currVec,T_cashFlow,prevD,newSalesIndex,prevC,prevCurrency,prevT_cashflow,prevTau)
%Initiating variables
risk_factor = create_risk_vec(risk_factors,t);
N=size(prevC,1); %Number of Assets
Nc=size(currVec,1); %Number of Currencies
NrF=size(risk_factor,1)/Nc; %Number of Risk Factors

% (514) passage_of_time = "Passage of Time":
theoretical_price_xi_tilde = create_theoretical_price_xi_tilde(prevC,prevTau,spot_rates,N,t,prevCurrency,Nc,prevT_cashflow);
theoretical_price_yesterday =  create_theoretical_price_xi_tilde_yesterday(prevC,prevTau,spot_rates,N,t,prevCurrency,Nc,prevT_cashflow);

dividend_yesterday = zeros(N,Nc);
for i = 1:N
    tau_temp = cell2mat(prevTau(1,i));
    for j = 1:size(prevC,2)
        index = find(strcmp(string(spot_rates(1,:)),prevCurrency(i,j)));
        if(tau_temp(j,2) == 0)
            dividend_yesterday(i,index) = dividend_yesterday(i,index) + prevC(i,j);
        end
    end
end
passage_of_time = theoretical_price_xi_tilde - (theoretical_price_yesterday - dividend_yesterday);

% (515) delta_price_xi = "Change in price with respect to riskfactors"
gradient = create_gradient(prevC,tau,AE,spot_rates,N,prevCurrency,t,Nc,prevT_cashflow);
delta_price_xi = diag(risk_factor)*gradient; 


% (516) delta_price_q = "quadratic term of the bar_price"
hessian = create_hessian(prevC,prevTau,AE,spot_rates,N,prevCurrency,t,Nc,prevT_cashflow);
delta_price_q = zeros(6*Nc,6*Nc,N);
for i =1:N
    delta_price_q(:,:,i) = (1/2)*diag(risk_factor)*hessian(:,:,i)*diag(risk_factor); %hessian from PCA
end


% (517) delta_price_a = "the approximation that does not take into considiration for error terms:
onevec = ones(size(delta_price_xi,1)/Nc,1);
delta_price_a = zeros(N,Nc);
gradient_delta_risk_factor = zeros(N,Nc);
hessian_delta_risk_factor = zeros(N,Nc);
for i = 1:N
    index_hist = zeros(1,size(prevC,2));
    for j = 1:size(prevC,2)
        if (prevC(i,j)~=0)
            index = find(strcmp(string(spot_rates(1,:)),prevCurrency(i,j)));
            index_hist(j) = index;
            if j==1 
                delta_price_a(i,index) = passage_of_time(i,index) + transpose(onevec)*delta_price_xi((index*6-5):(index*6),i) + transpose(onevec)*delta_price_q((index*6-5):(index*6),(index*6-5):(index*6),i)*onevec;
                gradient_delta_risk_factor(i,index) = transpose(onevec)*delta_price_xi((index*6-5):(index*6),i);
                hessian_delta_risk_factor(i,index)= transpose(onevec)*delta_price_q((index*6-5):(index*6),(index*6-5):(index*6),i)*onevec;
            elseif ~find(index_hist(1:j-1),index)
                delta_price_a(i,index) = delta_price_a(i,index) + passage_of_time(i,index) + transpose(onevec)*delta_price_xi((index*6-5):(index*6),i) + transpose(onevec)*delta_price_q((index*6-5):(index*6),(index*6-5):(index*6),i)*onevec;
                gradient_delta_risk_factor(i,index) = gradient_delta_risk_factor(i,index) + transpose(onevec)*delta_price_xi((index*6-5):(index*6),i);
                hessian_delta_risk_factor(i,index)= hessian_delta_risk_factor(i,index) + transpose(onevec)*delta_price_q((index*6-5):(index*6),(index*6-5):(index*6),i)*onevec;
            end
        end
    end
end

%Calculating delta_price_A with respect to single risk factors
delta_price_a_riskfactors = zeros(N,Nc,NrF+1);
for i = 1:NrF
    for j = 1:N
        index_hist = zeros(1,size(prevC,2));
        vec_risk = zeros(NrF,1);
        vec_risk(i) = 1;
        for k =1:size(prevCurrency(j,:),2)
            if prevC(j,k) ~=0
                index = find(strcmp(string(spot_rates(1,:)),prevCurrency(j,k)));
                index_hist(j) = index;
                if k==1
                    delta_price_a_riskfactors(j,index,i) = vec_risk'*delta_price_xi((index*6-5):(index*6),j) + vec_risk'*delta_price_q((index*6-5):(index*6),(index*6-5):(index*6),j)*vec_risk;
                elseif ~find(index_hist(1:j-1),index)
                    delta_price_a_riskfactors(j,index,i) = delta_price_a_riskfactors(j,index,i) + vec_risk'*delta_price_xi((index*6-5):(index*6),j) + vec_risk'*delta_price_q((index*6-5):(index*6),(index*6-5):(index*6),j)*vec_risk;
                end
            end
        end
    end
end
delta_price_a_riskfactors(:,:,end) = delta_price_a;

%(513) delta_epsilon_i = "Error for not including all risk factors"
theoretical_price_s = create_theoretical_price_s(prevC,prevTau,AE,spot_rates,N,prevCurrency,t,risk_factor,Nc,prevT_cashflow);
theoretical_price = create_theoretical_price(prevC,prevTau,spot_rates,N,t,prevCurrency,Nc,prevT_cashflow);
delta_epsilon_i = theoretical_price-theoretical_price_s;

%calculating delta_epsilon_i with respect to single risk factors.
theoretical_price_s_riskfactors = zeros(N,Nc,NrF+1); 
delta_epsilon_i_riskfactors = zeros(N,Nc,NrF+1);
for i=1:NrF
    risk_factor_temp = zeros(size(risk_factor,1),size(risk_factor,2));
    for j = 1:Nc
        risk_factor_temp((j-1)*6+i) = risk_factor((j-1)*6+i);
    end

    theoretical_price_s_riskfactors(:,:,i) = create_theoretical_price_s(prevC,prevTau,AE,spot_rates,N,prevCurrency,t,risk_factor_temp,Nc,prevT_cashflow);
    delta_epsilon_i_riskfactors(:,:,i)=theoretical_price-theoretical_price_s_riskfactors(:,:,i);
end
delta_epsilon_i_riskfactors(:,:,end)=delta_epsilon_i;


%(518) delta_epsilon_a = "Error from not including higher order terms of the taylor expansion
dividend = zeros(N,Nc);
for i = 1:N
    tau_temp = cell2mat(prevTau(1,i));
    for j = 1:size(prevC,2) 
        index = find(strcmp(string(spot_rates(1,:)),prevCurrency(i,j)));
        if(tau_temp(j,2) == 0)
            dividend(i,index) = dividend(i,index) + prevC(i,j);
        end
    end
end

delta_epsilon_a = theoretical_price + dividend- theoretical_price_yesterday -delta_price_a -delta_epsilon_i;

delta_epsilon_a_riskfactors = zeros(N,Nc,NrF+1);
for i = 1:NrF
    delta_epsilon_a_riskfactors(:,:,i) = theoretical_price + dividend -theoretical_price_yesterday -delta_price_a_riskfactors(:,:,i) -delta_epsilon_i_riskfactors(:,:,i);
end
delta_epsilon_a_riskfactors(:,:,end)=delta_epsilon_a;

% Complete un-observed pricechange equation;
delta_barPrice = delta_price_a + delta_epsilon_a + delta_epsilon_i;
delta_barPrice_riskfactors = zeros(N,Nc,NrF+4);
for i =1:NrF
    delta_barPrice_riskfactors(:,:,i) = delta_price_a_riskfactors(:,:,i); %+ delta_epsilon_a_riskfactors(:,:,i) + delta_epsilon_i_riskfactors(:,:,i);
end
delta_barPrice_riskfactors(:,:,end-3) = passage_of_time;
delta_barPrice_riskfactors(:,:,end-2) = delta_epsilon_a;
delta_barPrice_riskfactors(:,:,end-1) = delta_epsilon_i;
Discounted_today = create_theoretical_price_xi_tilde(c,tau,spot_rates,N,t,currency,Nc,T_cashFlow)-create_theoretical_price_xi_tilde(prevC,prevTau,spot_rates,N,t,prevCurrency,Nc,prevT_cashflow);
delta_barPrice_riskfactors(:,:,end) = delta_barPrice + Discounted_today;

dP = delta_barPrice_riskfactors;

P_yesterday = theoretical_price_yesterday;
end
