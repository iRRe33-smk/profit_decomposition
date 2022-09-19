
global d_given
d_given = readmatrix('Data/DiscountCurves.xlsx','Range','C3:O3' 'Sheet', 'Sheet1');
optimize()
function f_answer = optimize()
    n_f = 26;
    n_g = 13;
    f0 = zeros(1,n_f);
    
    f_given = [1 3 4 6 7 8];
    fun = @objective;
    nonlcon = @constraint;
    A = [];
    b = [];
    Aeq = [];
    beq = [];
    lb = zeros(1,n_f);
    ub = [];
    
    %options = optimoptions(@fmincon,'Algorithm','sqp','MaxIterations',1500);
    %options = optimoptions('fmincon')
    %options = optimoptions(@fmincon,'Algorithm','interior-point','MaxFunctionEvaluations',3000,'ConstraintTolerance', 1.0000e-10);
    [f_answer] = fmincon(fun,f0,A,b,Aeq,beq,lb,ub,nonlcon);
    plot(f_answer)
    function obj = objective(f)
        global d_given
        f_given_o = -log(d_given);
        %f_given_o = [1 3 4 6 7 8 10 11 12 14 16 19 20];
        delta_T_o = 1/5;
        obj1 = 0;
        indeces = [1, 2, 3 ,4,5, 8,9,10,11,12,13,14,15];
        E_e = 10*diag(ones(1,n_g));
        for i = 2:max(size(f))-1
            obj1 = obj1 + (((f(i+1) - 2*f(i) + f(i-1))/(delta_T_o^2))^2)*delta_T_o;
        end
        z = zeros(1,n_g);
        for i = 1:n_g
            z(1, i) = abs(f_given_o(i) - f(indeces(i)));
        end
        obj2 = 0.5*z*E_e*z';
        obj = obj1 + obj2;
    end

    function [c, ceq] = constraint(f)
        global d_given
        f_given_c = -log(d_given);
        %f_given_c = [1 3 4 6 7 8 10 11 12 14 16 19 20];
        indeces = [1, 2, 3 ,4,5, 8,9,10,11,12,13,14,15];
        z = zeros(1,n_g);
        F_e = ones(1,n_g);
        F_e(1) = 0;
        F_e(n_g) = 0;
        F_e = diag(F_e);
        for i = 1:n_g
            z(1, i) = abs(f_given_c(i) - f(indeces(i)));
        end
        for i = 1:n_g
            c1(i) = exp(-f(indeces(i)));
        end
        c = c1 + F_e*z' - exp(-f_given_c);
        ceq = [];  
    end
end


