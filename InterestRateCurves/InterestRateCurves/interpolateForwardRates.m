function [Xi] = interpolateForwardRates(forwardRates)
    Xnz = forwardRates(forwardRates ~= 0);                                % Non-Zero Elements
    vnz = find(forwardRates ~= 0);                                        % Indices Of Non-Zero Elements
    iv = 1:length(forwardRates);                                          % Interpolation Vector
    Xi = interp1(vnz, Xnz, iv, 'linear');  
end

