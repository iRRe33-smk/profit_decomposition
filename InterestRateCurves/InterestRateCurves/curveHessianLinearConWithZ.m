clear
[forwardRates, spotRates, discountFactors, ~, ~] = getForwAndSpot();

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Precalculate constant expressions  %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
T = [1 2 7 14 30 60 90 180 270 1*365 2*365 3*365 4*365 5*365 6*365 7*365 ...
     8*365 9*365 10*365 11*365 12*365 13*365 14*365 15*365 20*365 25*365];
n_r = length(T);
n_f = T(end);
discountFactors = discountFactors(16,1:n_r);
spotRates = spotRates(16,1:n_r);
logDiscountFactors = -log(discountFactors)';
deltaT = 1/365;
marketPriceIndeces = zeros(n_f, 1);
for i = 1:length(T)
    marketPriceIndeces(T(i)) = 1;
end
A_n = getA_n(deltaT, n_f);
V = 10; rho = 2; phi = 4;
w = getW(n_f, V, rho, phi);
W = diag(w);
E = 10e4*eye(n_r);
A = getA(marketPriceIndeces, n_f, n_r, deltaT);
Hess = zeros(n_f + n_r, n_f + n_r);
Hess(1:n_f,1:n_f) = A_n'*W*A_n;
Hess(n_f+1:n_f + n_r, n_f+1:n_f + n_r) = E;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%        Perform optimization         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
HessFun = @(x, lambda) Hess;
obj = @(x) objective(x, W, A_n, n_f, n_r, E);
x0 = zeros(n_f + n_r, 1);
options = optimoptions('fmincon','Algorithm','interior-point',...
    "SpecifyConstraintGradient",false,"SpecifyObjectiveGradient",true,...
    'HessianFcn',HessFun);

[x,fval,eflag,output] = fmincon(obj,x0,[],[],A, logDiscountFactors, [], [], [], options);
curve = x(1:n_f);
plot(curve)
hold on
scatter(T, spotRates)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%              Functions              %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [obj, gradObj] = objective(x, W, A_n, n_f, n_r, E)
    f = x(1:n_f);
    z = x(n_f+1:n_f+n_r);
    obj = 0.5*f'*A_n'*W*A_n*f + 0.5*z'*E*z;
    if nargout > 1
        gradObj = [A_n'*W*A_n*f; E*z];
    end
end


function A = getA(marketPriceIndeces, n_f, n_r, deltaT)
    A = zeros(n_r, n_f + n_r);
    for row = 1:n_r
        for column = 1:n_f
            if marketPriceIndeces(column) == 1
                A(row, 1:column) = deltaT;
                A(row, n_f + row) = column*deltaT;
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
end


