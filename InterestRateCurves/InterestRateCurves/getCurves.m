%%
T = [1 2 7 14 30 60 90 180 270 1*365 2*365 3*365 4*365 5*365 6*365 7*365 ...
         8*365 9*365 10*365 11*365 12*365 13*365 14*365 15*365 20*365];
n_r = length(T); n_f = T(end);
dt = 1/365; e = 10;
[A_s, B_s, C_s] = eqSystemIRCcopy(e, T , n_f, n_r, dt);
[~, ~, discountFactors, ~, ~, ~] = getForwAndSpot();
f = zeros(n_f, 123);
z = zeros(n_r, 123);


%%
for day = 1:123
    p = -log(discountFactors(day, 1:n_r))';
    f(:,day) = 100*A_s*p;
    z(:,day) = 10000*(B_s*(f(:,day)/100) + C_s*p);
end
    
