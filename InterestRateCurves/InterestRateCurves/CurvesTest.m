[forwardRates, spotRates, T, daysInBtw] = getForwAndSpot();
forwardRates = forwardRates(1,:);
marketPriceIndeces = ones(size(forwardRates));
nBetween = max(size(forwardRates)) - 4;
options = optimoptions(@fmincon, 'MaxFunctionEvaluations',1000000, 'MaxIterations', 1000000, 'StepTolerance', 1e-30);
for pad = 0:0
     [forwardRates, marketPriceIndeces, daysInBtw] = padForwardRates(forwardRates, marketPriceIndeces, pad, nBetween);
end

forwardRates = interpolateForwardRates(forwardRates);


for daysInBtw = 1:1
    [forwardRates, marketPriceIndeces, daysInBtw] = padForwardRates(forwardRates, marketPriceIndeces, daysInBtw, nBetween);
    deltaT = ones(size((forwardRates)))*(1/365);
    deltaT = deltaT(1:end-1);
    [A_n, n_f] = createA_nMatrix(deltaT);
    W = diag(ones(1,n_f-2));
    Aeq = diag(marketPriceIndeces);
    beq = forwardRates;
    A = [];
    b = [];
    f0 = interpolateForwardRates(forwardRates)';
    %lb = f0 - 0.05;
    %ub = f0 + 0.05;
    lb = [];
    ub = [];
    nonlcon = [];
    fun = @(f) 0.5*f'*A_n'*W*A_n*f;
    [f_answer] = fmincon(fun,f0,A,b,Aeq,beq,lb,ub, nonlcon, options);

end
plot(f_answer)
hold on 
plot(ub)
plot(lb)

