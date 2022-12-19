function [f, z, e, T, date, A_solve, B_solve, A, F, b] = eqSystemIRC(day, e)
    [forwardRates, spotRates, discountFactors, ~, ~, dates] = getForwAndSpot();

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %  Precalculate constant expressions  %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    date = datestr(x2mdate(dates(day)));
    T = [1 2 7 14 30 60 90 180 270 1*365 2*365 3*365 4*365 5*365 6*365 7*365 ...
         8*365 9*365 10*365 11*365 12*365 13*365 14*365 15*365 20*365];

    n_r = length(T);
    n_f = T(end);
    discountFactors = discountFactors(day, 1:n_r);
    forwardRates = forwardRates(day, 1:n_r);
    b = -log(discountFactors)';
    deltaT = 1/365;
    marketPriceIndeces = zeros(n_f, 1);
    for i = 1:length(T)
        marketPriceIndeces(T(i)) = 1;
    end
    A_n = getA_n(deltaT, n_f);
    V = 10; rho = 2; phi = 4;
    W = getW(n_f, V, rho, phi);
    E = e*eye(n_r);
    [A, F] = getAandF(marketPriceIndeces, n_f, n_r, deltaT);
    C = A_n'*W*A_n;
    A_solve = C + A'*inv(F)*E*inv(F)*A;
    B_solve = A'*inv(F)*E*inv(F)*b;
    R = chol(A_solve);
    f = R\(R'\B_solve);
    
    z = (-inv(F)*(A*f - b))*10000;
    f = 100*f;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %              Functions              %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    function  [A, F] = getAandF(marketPriceIndeces, n_f, n_r, deltaT)
        A = zeros(n_r, n_f);
        F = zeros(n_r, n_r);
        A(:,1) = deltaT;
        for row = 1:n_r
            for column = 1:n_f
                if marketPriceIndeces(column) == 1
                    A(row, 1:column-1) = deltaT;
                    F(row, row) = deltaT*column;
                    marketPriceIndeces(column) = 0;
                    break;
                end
            end
        end
    end

    function A_n = getA_n(deltaT, n_f)
        deltaTsq = 1/(deltaT^2);
        A_n = zeros(n_f-2, n_f);
        for i = 1:n_f-2
            A_n(i, :) = [zeros(1,i-1), deltaTsq, -2*deltaTsq, deltaTsq, zeros(1,n_f-2-i)];
        end
        A_n = A_n*deltaT;
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