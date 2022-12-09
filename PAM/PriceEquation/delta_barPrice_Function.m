
function [dP,P_yesterday] = delta_barPrice_Function(risk_factors,spot_rates,AE,tau,t,c,currency,currVec)

% N= N assets
%T = t timesteps
%delta_barPrice = delta_priceT + 1'delta_priceXI + 1'_deltaPriceQ*1 + epsP
%+ epsA + epsI. The equation is implemented down below:
% the numbers,i.e (514) refers to equation numbers from paper
% interestRateInstruments.pdf
%risk_factor=cell2mat(risk_factors(2,32)); %Uses risk factors for SEK now, might change (Ask Jörgen)
risk_factor = create_risk_vec(risk_factors,t);
N=size(c,1);
Nc=size(currVec,1);


% (514) deltapriceT = "Passage of Time":
theoretical_price_xi_tilde = create_theoretical_price_xi_tilde(c,tau,spot_rates,N,t,currency);
theoretical_price_yesterday =  create_theoretical_price_xi_tilde_yesterday(c,tau,spot_rates,N,t,currency);

dividend_yesterday = zeros(N,1);
for i = 1:N
    tau_temp = cell2mat(tau(1,i));
    for j = 1:size(c,1)
        if(tau_temp(j,1) == -1/365)
            dividend_yesterday(i) = dividend_yesterday(i) + c(i,j);
        end
    end
end

passage_of_time = theoretical_price_xi_tilde - (theoretical_price_yesterday - dividend_yesterday);


% (515) delta_PriceXI = "Change in price with respect to riskfactors"
gradient = create_gradient(c,tau,AE,spot_rates,N,currency,t,Nc);
delta_price_xi = diag(risk_factor)*gradient; % gradient from PCA.


% (516)delta_price_Q = "quadratic term of the bar_price"
hessian = create_hessian(c,tau,AE,spot_rates,N,currency,t,Nc);
delta_price_q = zeros(6*Nc,6*Nc,N);
for i =1:N
    delta_price_q(:,:,i) = (1/2)*diag(risk_factor)*hessian(:,:,i)*diag(risk_factor); %hessian from PCA
end

% (517) delta_price_A = "the approximation that does not take into considiration for error terms:
[rowP_xi,~] = size(delta_price_xi);
[rowP_q, ~] = size(delta_price_q); % ska vara samma storlek som P_xi antagligen.
onevec_xi = ones(rowP_xi,1);
onevec_q = ones(rowP_q,1);
delta_price_a = zeros(N,1);
for i = 1:N
    delta_price_a(i) = passage_of_time(i) + transpose(onevec_xi)*delta_price_xi(:,i) + transpose(onevec_q)*delta_price_q(:,:,i)*onevec_q;
end

%calculating delta_price_A with respect to single risk factors
delta_price_a_riskfactors = zeros(N,size(risk_factor,1)/Nc+1);
for i = 1:size(risk_factor,1)/Nc
    for j = 1:N
        vec_risk = zeros(size(risk_factor,1),1);
        for k =1:size(currency(j,:),2)
            index = find(strcmp(string(spot_rates(1,:)),currency(j,k)));
            vec_risk((index-1)*6+i)=1;
        end

        delta_price_a_riskfactors(j,i) = transpose(vec_risk)*delta_price_xi(:,j) + transpose(vec_risk)*delta_price_q(:,:,j)*vec_risk;
    end
end
delta_price_a_riskfactors(:,end) = delta_price_a;

%(513)

theoretical_price_s = create_theoretical_price_s(c,tau,AE,spot_rates,N,currency,t,risk_factor);
theoretical_price = create_theoretical_price(c,tau,spot_rates,N,t,currency);
delta_epsilon_i = theoretical_price-theoretical_price_s;

%calculating delta_epsilon_i with respect to single risk factors.
theoretical_price_s_riskfactors = zeros(N,size(risk_factor,1)/Nc+1);
delta_epsilon_i_riskfactors = zeros(N,size(risk_factor,1)/Nc+1);
for i=1:size(risk_factor,1)/Nc
    risk_factor_temp = zeros(size(risk_factor,1),size(risk_factor,2));
    for j = 1:Nc
        risk_factor_temp((j-1)*6+i)=risk_factor((j-1)*6+i);
    end

    theoretical_price_s_riskfactors(:,i) = create_theoretical_price_s(c,tau,AE,spot_rates,N,currency,t,risk_factor_temp);
    delta_epsilon_i_riskfactors(:,i)=theoretical_price-theoretical_price_s_riskfactors(:,i);
end
delta_epsilon_i_riskfactors(:,end)=delta_epsilon_i;


%(518)
%delta_theoretical_price = theoretical_price; % dividend transponat och f, hur görs?
delta_epsilon_a = zeros(N,1);

dividend = zeros(N,1);
for i = 1:N
    tau_temp = cell2mat(tau(1,i));
    for j = 1:size(c,1)
        if(tau_temp(j,1) == 0)
            dividend(i) = dividend(i) + c(i,j);
        end
    end
end

for i =1:N
    delta_epsilon_a(i) = theoretical_price(i) + dividend(i)- theoretical_price_yesterday(i) -delta_price_a(i) -delta_epsilon_i(i); %Lägg till dividends
end
delta_epsilon_a_riskfactors = zeros(N,size(risk_factor,1)/Nc+1);
for i = 1:size(risk_factor,1)/Nc
    delta_epsilon_a_riskfactors(:,i) = theoretical_price + dividend -theoretical_price_yesterday -delta_price_a_riskfactors(:,i) -delta_epsilon_i_riskfactors(:,i);
end
delta_epsilon_a_riskfactors(:,end)=delta_epsilon_a;


% Complete un-observed pricechange equation;

delta_barPrice = delta_price_a + delta_epsilon_a + delta_epsilon_i; 
delta_barPrice_riskfactors = zeros(N,size(risk_factor,1)/Nc+1);
for i =1:size(risk_factor,1)/Nc
    delta_barPrice_riskfactors(:,i) = delta_price_a_riskfactors(:,i) + delta_epsilon_a_riskfactors(:,i) + delta_epsilon_i_riskfactors(:,i);
end
delta_barPrice_riskfactors(:,end) = delta_barPrice;

dP = format_dP(delta_barPrice_riskfactors,currency,currVec,N);
P_yesterday = format_P(theoretical_price_yesterday,currency,currVec,N);
end
