function [term6_result] = term6_results(passage_of_time,gradient_delta_risk_factor,hessian_delta_risk_factor,delta_epsilon_i,delta_epsilon_a,f)
N = size(passage_of_time,1);
Nc = size(passage_of_time,2);
term6_result = zeros(1,6);
for i = 1:N
    for j=1:Nc
        term6_result(1) = term6_result(1) + passage_of_time(i,j)*f(j);
        term6_result(2) = term6_result(2) + gradient_delta_risk_factor(i,j)*f(j);
        term6_result(3) = term6_result(3) + hessian_delta_risk_factor(i,j)*f(j);
        term6_result(4) = term6_result(4) + delta_epsilon_i(i,j)*f(j);
        term6_result(5) = term6_result(5) + delta_epsilon_a(i,j)*f(j);
    end
end
term6_result(6) = sum(term6_result(1,1:5));


end