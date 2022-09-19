global d_given indeces_m f_given delta_T n_points n_given
d_given = readmatrix('Data/DiscountCurves.xlsx','Range','C3:O3', 'Sheet', 'Sheet1');
f_given = -log(d_given);
%f_given = [13 12 11 10 9 8 7 8 9 10 11 12 13]; %V-shape
%f_given = [1 3 6 7 9 12 15 18 23 27 30 35 36]; %Linear ish

n_points = 30;
indeces_m = [1, 4, 6 ,8,10, 12,14,16,18,20,22,24,n_points];
n_given = max(size(f_given));
delta_T = 1/n_points;
optimize();

function f_answer = optimize()
    global indeces_m f_given delta_T n_points n_given
    %%% Startvektor
    f0 = zeros(1,n_points);
    
    %%%Nollvektor förutom där unika marknadspriser existerar
    f_C = zeros(1,n_points);
    for i = 1:n_given
        f_C(indeces_m(i)) = f_given(i);
    end
    
    %%%Nollvektor förutom där priser måste bevaras
    f_nallowed = zeros(1,n_points);
    for j = 1:n_given
        f_nallowed(indeces_m(j)) = 1;
    end
    
    fun = @objective;
    A = [];
    b = [];
    Aeq = diag(f_nallowed);
    beq = f_C;
    lb = zeros(1,n_points);
    ub = [];
 
    [f_answer] = fmincon(fun,f0,A,b,Aeq,beq,lb,ub);
    figure(1)
    plot(f_answer)
    
    %%% Cubic Spline Attempt %%%
    x = [1 2 7 14 30 60 90 120 150 360 720 1800 3600];
    y = f_given;
    xx = 1:1:3600;
    yy = spline(x,y,xx);
    figure(2)
    plot(x,y,'o',xx,yy)
    
    function obj = objective(f)
        obj = 0;
        for k = 2:max(size(f))-1
            obj = obj + (((f(k+1) - 2*f(k) + f(k-1))/(delta_T^2))^2)*delta_T;
        end
        for p = 1:max(size(f))-1
            obj = obj + (((f(p+1) - f(p))/(2*delta_T))^2)*delta_T;
        end
        obj = 0.5*obj;
    end 
end

