function h = h(f,deltaT,w)
    h = 0;
    for t = 2:max(size(f))-2
%         W1 = w(t)^2;
%         H1 = ((f(t+1) - f(t))/deltaT(t))^2;
%         T1 = deltaT(t);
        H2 = ((2/(deltaT(t-1) + deltaT(t))) * (  ((f(t+1) - f(t))/(deltaT(t))) - ((f(t) - f(t-1))/(deltaT(t-1)))  ))^2;
        T2 = (deltaT(t-1) + deltaT(t))/2;
        W = w(t)^2;
        H = ((2/(deltaT(t) + deltaT(t+1))) * (  ((f(t+1) - f(t))/(deltaT(t+1))) - ((f(t) - f(t-1))/(deltaT(t)))  ))^2;
        T = (deltaT(t) + deltaT(t+1))/2;
        h = h + W*H*T;
    end    
end

