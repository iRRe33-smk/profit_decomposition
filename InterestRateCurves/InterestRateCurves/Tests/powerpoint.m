function [f, z, e, T, date] = powerpoint(day, e)
    [forwardRates, spotRates, discountFactors, ~, ~, dates] = getForwAndSpot();
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    T = [1 2 7 14 30 60 90 180 270 1*365 2*365 3*365 4*365 5*365 6*365 7*365 8*365 9*365 10*365 11*365 12*365 13*365 14*365 15*365];   
    n_r = length(T);
    n_f = T(end);
    marketPriceIndeces = zeros(n_f, 1);
    for i = 1:length(T)
        marketPriceIndeces(T(i)) = 1;
    end
    forwardRates = forwardRates(day, 1:n_r)';
    discountFactors = discountFactors(day, 1:n_r)';
    spotRates = spotRates(day, 1:n_r)';
    date = datestr(x2mdate(dates(day)));
    
    dt = 1/365;
    b = -log(discountFactors);
    A_n = getA_n(dt, n_f);
    W = getW(n_f, 10, 2, 4);
    E = e*eye(n_r, n_r);
    x = zeros(n_f + n_r, 1);
    A = getA(marketPriceIndeces, n_f, n_r, dt);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    Hess = zeros(n_f + n_r, n_f + n_r);
    Hess(1:n_f,1:n_f) = A_n'*W*A_n;
    Hess(n_f+1:n_f + n_r, n_f+1:n_f + n_r) = E;
    objective = @(x) getObjective(x, n_r, n_f, A_n, W, E);
    HessFun = @(x, lambda) Hess;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    options = optimoptions('fmincon','Algorithm','interior-point',...
            "SpecifyConstraintGradient",false,"SpecifyObjectiveGradient",true,...
            'HessianFcn',HessFun);

    [x,fval,eflag,output] = fmincon(objective,x,[],[],A, b, [], [], [], options);
    f = x(1:n_f)*100*365;
    z = x(n_f+1:n_f+n_r)*10000;
    function [objective, objectiveGrad] = getObjective(x, n_r, n_f, A_n, W, E)
        f = x(1:n_f);
        z = x(n_f+1:n_f+n_r);
        objective = 0.5*f'*A_n'*W*A_n*f + 0.5*z'*E*z;
        if nargout > 1
            objectiveGrad = [(A_n'*W*A_n)'*f; E*z];
        end
    end



    function A_n = getA_n(deltaT, n_f)
        deltaTsq = 1/(deltaT^2);
        A_n = zeros(n_f-2, n_f);
        for i = 1:n_f-2
            A_n(i, :) = [zeros(1,i-1), deltaTsq, -2*deltaTsq, deltaTsq, zeros(1,n_f-2-i)];
        end
    end


    function A = getA(marketPriceIndeces, n_f, n_r, deltaT)
        A = zeros(n_r, n_f + n_r);
        for row = 1:n_r
            for column = 1:n_f
                if marketPriceIndeces(column) == 1
                    A(row, 1:column) = 1;
                    A(row, n_f + row) = 1;
                    marketPriceIndeces(column) = 0;
                    break;
                end
            end
        end
    end

    function W = getW(n_f, V, rho, phi)
       W = zeros(n_f-2,1);
       for t = 1:n_f-2
           if t <= 365
               W(t) = V*exp((t/365 - rho)*log(phi));
           else
               W(t) = V;
           end
       end
       W = diag(W);
    end
    end