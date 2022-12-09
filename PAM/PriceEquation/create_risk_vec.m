function risk_vector = create_risk_vec(risk_factors,t)
T = size(risk_factors,2);
nRF = size(cell2mat(risk_factors(2,1)),1);
risk_vector = zeros(T*nRF,1);
for i=1:T
    risk_temp = cell2mat(risk_factors(2,i));
    size(risk_temp);
    risk_vector(1:2,1);
    risk_temp(:,t);
    risk_vector((i*6-5):(i*6),1) = risk_temp(:,t);
end