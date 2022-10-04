clear
[forwardRates, spotRates, T, deltaTdays] = getForwAndSpot();
forwardRates = forwardRates(1,:);
marketPriceIndeces = ones(size(forwardRates));
nBetween = max(size(forwardRates)) - 4;
options = optimoptions(@fmincon, 'MaxFunctionEvaluations',10000, 'MaxIterations', 10000);




for daysInBtw = 0:5
    [forwardRates, marketPriceIndeces, ~] = padForwardRates(forwardRates, marketPriceIndeces, daysInBtw, nBetween);
    deltaT = getDeltaT(deltaTdays, daysInBtw+1);
    
    [A_n, n_f] = createA_nMatrix(deltaT);
    W = diag(ones(1,n_f-2));
    Aeq = diag(marketPriceIndeces);
    beq = Aeq*forwardRates';
    A = [];
    b = [];
    f0 = interpolateForwardRates(forwardRates)';
    lb = interpolateForwardRates(forwardRates)' - 0.01/(2*daysInBtw + 1);
    ub = interpolateForwardRates(forwardRates)' + 0.01/(2*daysInBtw + 1);

    nonlcon = [];
    fun = @(f) 0.5*f'*A_n'*W*A_n*f;
    [f_answer] = fmincon(fun,f0,A,b,Aeq,beq,lb,ub, nonlcon, options);
    forwardRates = f_answer';
end
axisT = getT(deltaT);

plot(axisT,f_answer)

