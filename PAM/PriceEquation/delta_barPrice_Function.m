
function [passage_of_time,gradient_delta_risk_factor,hessian_delta_risk_factor,delta_epsilon_i,delta_epsilon_a,dP,P_yesterday] = delta_barPrice_Function(risk_factors,spot_rates,AE,tau,t,c,currency,currVec)

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
NrF=size(risk_factor,1)/Nc;


% (514) deltapriceT = "Passage of Time":
theoretical_price_xi_tilde = create_theoretical_price_xi_tilde(c,tau,spot_rates,N,t,currency,Nc);
theoretical_price_yesterday =  create_theoretical_price_xi_tilde_yesterday(c,tau,spot_rates,N,t,currency,Nc);

dividend_yesterday = zeros(N,Nc);
for i = 1:N
    tau_temp = cell2mat(tau(1,i));
    %disp(size(tau_temp))
    %disp(tau_temp)
    for j = 1:size(c,2) %HÄR ÄNDRADE Isak från size(c,1) 7/12
        %disp(j)
        index = find(strcmp(string(spot_rates(1,:)),currency(i,j)));
        if(tau_temp(j,1) == -1/365)
            dividend_yesterday(i,index) = dividend_yesterday(i,index) + c(i,j);
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
% [rowP_xi,~] = size(delta_price_xi);
% [rowP_q, ~] = size(delta_price_q); % ska vara samma storlek som P_xi antagligen.
onevec = ones(size(delta_price_xi,1)/Nc,1);
% onevec_q = ones(rowP_q,1)
delta_price_a = zeros(N,Nc);
gradient_delta_risk_factor = zeros(N,Nc);
hessian_delta_risk_factor = zeros(N,Nc);
for i = 1:N
    index_hist = zeros(1,size(c,2));
    for j = 1:size(c,2)
        if (c(i,j)~=0)
            index = find(strcmp(string(spot_rates(1,:)),currency(i,j)));
            index_hist(j) = index;
            if j==1 
                delta_price_a(i,index) = passage_of_time(i,j) + transpose(onevec)*delta_price_xi((index*6-5):(index*6),i) + transpose(onevec)*delta_price_q((index*6-5):(index*6),(index*6-5):(index*6),i)*onevec;
                gradient_delta_risk_factor(i,index) = transpose(onevec)*delta_price_xi((index*6-5):(index*6),i);
                hessian_delta_risk_factor(i,index)= transpose(onevec)*delta_price_q((index*6-5):(index*6),(index*6-5):(index*6),i)*onevec;
            elseif ~find(index_hist(1:j-1),index)
                delta_price_a(i,index) = delta_price_a(i,index) + passage_of_time(i,j) + transpose(onevec)*delta_price_xi((index*6-5):(index*6),i) + transpose(onevec)*delta_price_q((index*6-5):(index*6),(index*6-5):(index*6),i)*onevec;
                gradient_delta_risk_factor(i,index) = gradient_delta_risk_factor(i,index) + transpose(onevec)*delta_price_xi((index*6-5):(index*6),i);
                hessian_delta_risk_factor(i,index)= hessian_delta_risk_factor(i,index) + transpose(onevec)*delta_price_q((index*6-5):(index*6),(index*6-5):(index*6),i)*onevec;
            end
        end
    end
end

%calculating delta_price_A with respect to single risk factors
delta_price_a_riskfactors = zeros(N,Nc,NrF+1);
for i = 1:NrF
    for j = 1:N
        index_hist = zeros(1,size(c,2));
        vec_risk = zeros(NrF,1);
        vec_risk(i) = 1;
        for k =1:size(currency(j,:),2)
            if c(j,k) ~=0
                index = find(strcmp(string(spot_rates(1,:)),currency(j,k)));
                index_hist(j) = index;
                %vec_risk((index-1)*6+i)=1;
                if k==1
                    delta_price_a_riskfactors(j,index,i) = transpose(vec_risk)*delta_price_xi((index*6-5):(index*6),j) + transpose(vec_risk)*delta_price_q((index*6-5):(index*6),(index*6-5):(index*6),j)*vec_risk;
                elseif ~find(index_hist(1:j-1),index)
                    delta_price_a_riskfactors(j,index,i) = delta_price_a_riskfactors(j,index,i) + transpose(vec_risk)*delta_price_xi((index*6-5):(index*6),j) + transpose(vec_risk)*delta_price_q((index*6-5):(index*6),(index*6-5):(index*6),j)*vec_risk;
                end
            end
        end
    end
end
delta_price_a_riskfactors(:,:,end) = delta_price_a;

%(513)

theoretical_price_s = create_theoretical_price_s(c,tau,AE,spot_rates,N,currency,t,risk_factor,Nc);
theoretical_price = create_theoretical_price(c,tau,spot_rates,N,t,currency,Nc);
delta_epsilon_i = theoretical_price-theoretical_price_s;

%calculating delta_epsilon_i with respect to single risk factors.
theoretical_price_s_riskfactors = zeros(N,Nc,NrF+1); 
delta_epsilon_i_riskfactors = zeros(N,Nc,NrF+1);
for i=1:NrF
    risk_factor_temp = zeros(size(risk_factor,1),size(risk_factor,2));
    for j = 1:Nc
        risk_factor_temp((j-1)*6+i)=risk_factor((j-1)*6+i);
    end

    theoretical_price_s_riskfactors(:,:,i) = create_theoretical_price_s(c,tau,AE,spot_rates,N,currency,t,risk_factor_temp,Nc);
    delta_epsilon_i_riskfactors(:,:,i)=theoretical_price-theoretical_price_s_riskfactors(:,:,i);
end
delta_epsilon_i_riskfactors(:,:,end)=delta_epsilon_i;


%(518)
%delta_theoretical_price = theoretical_price; % dividend transponat och f, hur görs?
delta_epsilon_a = zeros(N,Nc);

dividend = zeros(N,Nc);
for i = 1:N
    tau_temp = cell2mat(tau(1,i));
    for j = 1:size(c,2) %HÄR ÄNDRADE Isak från size(c,1) 7/12
        index = find(strcmp(string(spot_rates(1,:)),currency(i,j)));
        if(tau_temp(j,1) == 0)
            dividend(i,index) = dividend(i,index) + c(i,j);
        end
    end
end

%for i =1:N
    delta_epsilon_a = theoretical_price + dividend- theoretical_price_yesterday -delta_price_a -delta_epsilon_i;
%end
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
delta_barPrice_riskfactors(:,:,end) = delta_barPrice;

%dP = format_dP(delta_barPrice_riskfactors,currency,currVec,N);
dP = delta_barPrice_riskfactors;
%P_yesterday = format_P(theoretical_price_yesterday,currency,currVec,N);
P_yesterday = theoretical_price_yesterday;
end
