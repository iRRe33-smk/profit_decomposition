clear
[forwardRates, spotRates, ~, deltaTdays] = getForwAndSpot();
forwardRates = forwardRates(1,:);
givenRates = forwardRates';
deltaT = 1/365;

T = [1 2 7 14 30 60 90 180 270 1*365 2*365 3*365 4*365 5*365 6*365 7*365 8*365 9*365 10*365];

fr = zeros(3650, 1);
ind = zeros(3650, 1);
for i = 1:length(T)
    fr(T(i)) = givenRates(i);
    ind(T(i)) = 1;
end

n_r = length(T);
n_f = length(fr);
givenRates = givenRates(1:n_r,:);
forwardRates= fr;
marketPriceIndeces = ind;

[A_n] = getA_n(deltaT, n_f);

V = 10; rho = 2; phi = 4;
w = getW(n_f, V, rho, phi);
W = diag(w);

h = @(f) f'*A_n'*W*A_n*f;

[A] = getA(marketPriceIndeces, n_f, n_r);

nonlcon = @(f) con(f, marketPriceIndeces, n_f, n_r, givenRates);

x0 = zeros(n_f,1);

obj = @(f) objective(f, w, deltaT, n_f, givenRates, A, T, n_r);

getHessFun = @(x, lambda) getHess(x, lambda, deltaT, w, n_f);

options = optimoptions('fmincon','Algorithm','interior-point',...
    "SpecifyConstraintGradient",true,"SpecifyObjectiveGradient",true,...
    'HessianFcn',getHessFun);

[x,fval,eflag,output] = fmincon(obj,x0,[],[],[],[],[],[],nonlcon,options);
figure(2)
plot(x)
A*x - givenRates
function [c, ceq, gradc, gradceq] = con(f, marketPriceIndeces, n_f, n_r, givenRates)
    c = [];
    A = zeros(n_r, n_f);
        for row = 1:n_r
            for column = 1:n_f
                if marketPriceIndeces(column) == 1
                    A(row, column) = 1;
                    marketPriceIndeces(column) = 0;
                    break;
                end
            end
        end 
    ceq = A*f  + (A*f - givenRates) - givenRates;
    if nargout > 2
        gradc = [];
        gradceq = 2*A';
    end
end

function [A] = getA(marketPriceIndeces, n_f, n_r)
    A = zeros(n_r, n_f);
    for row = 1:n_r
        for column = 1:n_f
            if marketPriceIndeces(column) == 1
                A(row, column) = 1;
                marketPriceIndeces(column) = 0;
                break;
            end
        end
    end 
end

function [h, gradh] = objective(f, w, deltaT, n_f, givenRates, A, T, n_r)
    h = 0;
    for t = 2:n_f-1
        h = h + w(t-1)*((f(t+1) - 2*f(t) + f(t-1))/deltaT^2)^2;
    end
    E = 10*ones(1,n_r);
    E = diag(E);
    h = h + (A*f - givenRates)'*E*(A*f - givenRates);
    if nargout > 1
        gradh = getGradH(f, w, deltaT, n_f, T, givenRates);
    end
end

function [gradh]= getGradH(f, w, deltaT, n_f, T, givenRates)
    t = 1/(deltaT^4);
    gradh = zeros(n_f, 1);
    gradh(1, 1) = 2*w(1)*(f(3) - 2*f(2) + f(1))*t;
    gradh(2, 1) = -4*w(1)*(f(3) - 2*f(2) + f(1))*t + 2*w(2)*(f(4) - 2*f(3) + f(2))*t;
    for row = 3:n_f-2
        gradh(row, 1) = 2*w(row-2)*(f(row) - 2*f(row-1) + f(row-2))*t + 2*w(row-1)*(f(row+1) - 2*f(row) + f(row-1))*t - 4*w(row)*(f(row+2) - 2*f(row+1) + f(row))*t;
    end
    gradh(n_f-1, 1) = -4*w(n_f-2)*(f(n_f) - 2*f(n_f-1) + f(n_f-2))*t + 2*w(n_f-3)*(f(n_f-1) - 2*f(n_f-2) + f(n_f-3))*t;
    gradh(n_f, 1) = 2*w(n_f-2)*(f(n_f) - 2*f(n_f-1) + f(n_f-2))*t;
    count = 1;
    for row = 1:n_f
        if row == T(count)
            gradh(row, 1) = gradh(row, 1) + 2*f(row) - 2*givenRates(count);
            count = count + 1;
        end
    end
end


function [Hess] = getHess(~, ~, deltaT, w, n_f)
    Hess = zeros(n_f, n_f);
    t = 1/(deltaT^4);
    Hess(1,:) = [2*w(1)*t, -4*w(1)*t, 2*w(1)*t, zeros(1,n_f - 3)];
    Hess(2,:) = [-4*w(1)*t,  (8*w(1)*t + 2*w(2)*t), (-4*w(1)*t -4*w(2)*t), 2*w(2)*t, zeros(1,n_f - 4)];
    for row = 3:n_f-2
       Hess(row, :) = [(zeros(1,row-3)) ...
                       (2*w(row-2)*t) ...
                       (-4*w(row-2)*t -4*w(row-1)*t) ...
                       (2*w(row-2)*t +8*w(row-1)*t + 2*w(row)*t) ...
                       (-4*w(row-1)*t -4*w(row)*t) ...
                       (2*w(row)*t) ...
                       (zeros(1,n_f - 2 - row)) ...
                       ];
    end
    Hess(n_f-1,:) = [zeros(1,n_f - 4), 2*w(n_f-3)*t,  (-4*w(n_f-3)*t -4*w(n_f-2)*t), (2*w(n_f-3)*t + 8*w(n_f-2)*t), -4*w(n_f-2)*t];
    Hess(n_f,:) = [zeros(1,n_f - 3), 2*w(n_f-2)*t, -4*w(n_f-2)*t, 2*w(n_f-2)*t];
    
    
end

function [A_n] = getA_n(deltaT, n_f)
    deltaTsq = 1/(deltaT^2);
    A_n = zeros(n_f-2, n_f);
    for i = 1:n_f-2
        A_n(i, :) = [zeros(1,i-1), deltaTsq, -2*deltaTsq, deltaTsq, zeros(1,n_f-2-i)];
    end
end

function [W] = getW(n_f, V, rho, phi)
   W = zeros(n_f-2,1);
   for t = 1:n_f-2
       if t <= 365
           W(t) = V*exp((t/365 - rho)*log(phi));
       else
           W(t) = V;
       end
   end
end



        
        