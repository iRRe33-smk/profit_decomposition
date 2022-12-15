function [deltaT, indeces, f0, T] = expandForwardRates(forwardRates, daysToAddBtw, daysInBtw)
    n_given = max(size(forwardRates));
    start = 1;
    deltaT = [];
    for i = 1:n_given - 1
        move = daysToAddBtw(i); 
        pad = zeros(1,move);
        forwardRates = [forwardRates(1:start) pad forwardRates(start+1:end)];
        deltaT = [deltaT (ones(1,1 + move).*daysInBtw(i))./(1+move)];
        start = start + move + 1; 
    end
    f0 = forwardRates;
    indeces = zeros(1,max(size(f0)));
    for p = 1:max(size(f0))
        if f0(p) ~= 0
            indeces(p) = 1;
        end
    end
    T = getT(deltaT);
    deltaT = deltaT.*(1/365);

end

