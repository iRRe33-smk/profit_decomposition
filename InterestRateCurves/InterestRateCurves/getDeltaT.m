function deltaT = getDeltaT(deltaTdays, daysInBtw)
    deltaT = repelem(deltaTdays,1,daysInBtw+1)/(daysInBtw+1);
    %deltaT = deltaT*(1/365);
end

