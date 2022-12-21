function [r1,r2,r3,r4,r5,r6,term6_calc,term6] = term6_results(passage_of_time,gradient_delta_risk_factor,hessian_delta_risk_factor,delta_epsilon_i,delta_epsilon_a,dP_finished,f)
N = size(passage_of_time,1);
Nc = size(passage_of_time,2);
r1=0;
r2=0;
r3=0;
r4=0;
r5=0;
r6=0;
for i = 1:N
    for j=1:Nc
        r1 = r1 + passage_of_time(i,j)*f(j);
        r2 = r2 + gradient_delta_risk_factor(i,j)*f(j);
        r3 = r3 + hessian_delta_risk_factor(i,j)*f(j);
        r4 = r4 + delta_epsilon_i(i,j)*f(j);
        r5 = r5 + delta_epsilon_a(i,j)*f(j);
        r6 = r6 + dP_finished(i,j,10)*f(j);
    end
end
term6 = r1+r2+r3+r4+r5;
term6_calc = r6;

end