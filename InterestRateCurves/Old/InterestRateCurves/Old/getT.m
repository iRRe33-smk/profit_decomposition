function axisT = getT(deltaT)
    axisT = [1 deltaT];
    for i = 1:max(size(axisT))-1
        axisT(i+1) = axisT(i) + axisT(i+1);
    end
    
end

