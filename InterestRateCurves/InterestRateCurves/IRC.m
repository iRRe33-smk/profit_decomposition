clear
[forwardRates, spotRates, discountFactors, ~, ~, dates] = getForwAndSpot();

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Precalculate constant expressions  %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
day = 16;
date = datestr(x2mdate(dates(day)));
T = [1 2 7 14 30 60 90 180 270 1*365 2*365 3*365 4*365 5*365 6*365 7*365 ...
     8*365 9*365 10*365 11*365 12*365 13*365 14*365 15*365 20*365];
n_r = length(T);
n_f = T(end);
discountFactors = discountFactors(day,1:n_r);
b = -log(discountFactors)';
deltaT = 1/365;
marketPriceIndeces = zeros(n_f, 1);
for i = 1:length(T)
    marketPriceIndeces(T(i)) = 1;
end
A_n = getA_n(deltaT, n_f);
V = 10; rho = 2; phi = 4;
W = getW(n_f, V, rho, phi);
E = 100*eye(n_r);
A = getA(marketPriceIndeces, n_f, n_r, deltaT);
hessLagrangian = zeros(n_r + n_f);
hessLagrangian(1:n_f, 1:n_f) = 2*A_n'*W*A_n;
hessLagrangian(n_f + 1:end, n_f + 1:end) = 2*E;
A_s = zeros(n_f + 2*n_r);
A_s(1:n_f + n_r, 1:n_f + n_r) = hessLagrangian;
A_s(n_f + n_r + 1:end, 1:n_f + n_r) = -1*A;
A_s(1:n_f + n_r, n_f + n_r + 1:end) = -1*A';

B = zeros(n_f + 2*n_r, 1);
B(n_f + n_r + 1:end) = -b;
[L,U,P] = lu(A_s);
y = L\(P*B);
X = U\y;
f = X(1:n_f);
z = X(n_f+1:n_f + n_r);
lambda = X(n_f + n_r:end);
plot(f)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%              Functions              %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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
   W = diag(W);
end
