given = [3, 6, 20];
n_points = 400;
n_given = max(size(given));
delta_T = 1;
mid = round(n_points/2);
con = zeros(n_points, n_points);
con(1,1) = 1; con(mid,mid) = 1; con(n_points,n_points) = 1;

%Use cubic spline to generate initial conditions very close to correct
%solution
x = [1 mid n_points];
    y = given;
    xx = 1:1:n_points;
    yy = spline(x,y,xx);
    f0 = yy;

    fun = @objective;
    A = [];
    b = [];
    Aeq = con;
    
    beq = zeros(1,n_points);
    beq(1) = given(1); 
    beq(mid) = given(2); 
    beq(n_points) = given(3);
    
    lb = zeros(1,n_points);
    ub = [];
 
    [f_answer] = fmincon(fun,f0,A,b,Aeq,beq,lb,ub);
    figure(1)
    plot(f_answer)

function obj = objective(f)
    obj = 0;
    for k = 2:max(size(f))-1
        obj = obj + (f(k+1) - 2*f(k) + f(k-1))^2;
    end
end