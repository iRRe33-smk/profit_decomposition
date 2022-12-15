clear
[forwardRates, spotRates, T, daysInBtw] = getForwAndSpot();
forwardRates = forwardRates(5,:);
daysToAddBtw = [0 2 2 5 5 5 5 5 5 5 5 5 5 5 5 5 5 5 5 5 5 5 5 10 10];
%daysToAddBtw = [0 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1];
[deltaT, indeces, f0, T1] = expandForwardRates(forwardRates, daysToAddBtw, daysInBtw);
w = ones(max(size(f0)));
options = optimoptions(@fmincon, 'MaxFunctionEvaluations',100, 'MaxIterations', 1000000);

[A_n, n_f] = createA_nMatrix(deltaT);
W = diag(ones(1,n_f-2));
objective = @(f) f*A_n'*W*A_n*f';
objective2 = @(f) h(f, deltaT, w);


Aeq = diag(indeces);
beq = Aeq*f0';
A = [];
b = [];
lb = zeros(1, max(size(f0)));
ub = ones(1, max(size(f0)))*(max(f0) + 0.001);
nonlcon = [];

[f_answer] = fmincon(objective,f0,A,b,Aeq,beq,lb,ub, nonlcon, options);

plot(T1, f_answer)
hold on
scatter(T,forwardRates)
objective(f_answer)
objective2(f_answer)