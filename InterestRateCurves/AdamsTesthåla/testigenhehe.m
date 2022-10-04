given = [1, 2, 3,4,5,6,10, 30, 50, 45,44,43,41,40,39,40,42,41,40,39,40,43,44,45,42];
n_points = 28;
n_given = max(size(given));
delta_T = 1/365;
mid = round(n_points/2);
con = zeros(n_points, n_points);

%%%%
options = optimoptions(@fmincon, 'MaxFunctionEvaluations',100000, 'MaxIterations', 10000);

A_n = zeros(n_points - 2, n_points);
W = diag(ones(1,n_points-2));
for i = 1:n_points - 2
    A_n(i, i:i+2) = [1/(delta_T^2) -2/(delta_T^2) 1/(delta_T^2)];
end
Q = A_n'*sqrt(W)*A_n;
fun = @(f) 0.5*f'*A_n'*W*A_n*f;
%Use cubic spline to generate initial conditions very close to correct
%solution
beq = zeros(1,n_points);

for i = 1:n_given
    factor = n_points/n_given;
    beq(round(factor*i)) = given(i);
    con(round(factor*i),round(factor*i)) = 1;
end

    
    f0 = zeros(n_points,1);

    %fun = @objective;
    A = [];
    b = [];
    Aeq = con;
    
    
    
    lb = ones(1,n_points)*min(beq);
    ub = ones(1,n_points)*max(beq);
    nonlcon = [];
    [f_answer] = fmincon(fun,f0,A,b,Aeq,beq,lb,ub, nonlcon,options);
    figure(1)
    plot(f_answer)
