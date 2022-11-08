%%
forward_rate = zeros(100, 7300);
count = 1;
for day = 1:100
    forward_rate(count,:) = IRC(day);
    count = count + 1;
    count
end
%%
dfAll = zeros(99, 7300);
for i = 1:99
    dfAll(i,:) = forward_rate(i+1,:)-forward_rate(i,:);
end
dt = 1/365;
C = cov(dfAll);
[fV, D] = eigs(C,6);
fE = D;
deltaF = dfAll';
E = fV;
M = [1 2 7 14 30 60 90 180 270 1*365 2*365 3*365 4*365 5*365 6*365 7*365 ...
     8*365 9*365 10*365 11*365 12*365 13*365 14*365 15*365 20*365];

xi = E'*deltaF;

share = diag(fE)/sum(diag(C));
cshare = cumsum(share);
shift     = sprintf('Shift        %5.2f%% (%5.2f%%)\n',100*share(1), 100*cshare(1));
twist     = sprintf('Twist        %5.2f%% (%5.2f%%)\n',100*share(2), 100*cshare(2));
butterfly = sprintf('Butterfly    %5.2f%% (%5.2f%%)\n',100*share(3), 100*cshare(3));
PC4       = sprintf('Loadings PC4 %5.2f%% (%5.2f%%)\n',100*share(4), 100*cshare(4));
PC5       = sprintf('Loadings PC5 %5.2f%% (%5.2f%%)\n',100*share(5), 100*cshare(5));
PC6       = sprintf('Loadings PC6 %5.2f%% (%5.2f%%)\n',100*share(6), 100*cshare(6));
figure(2);
plot((0:M(end)-1)*dt, fV(:,1:3)', (0:M(end)-1)*dt, fV(:,4:6)', '--');
title('Eigenvectors');
legend(shift,twist,butterfly, PC4, PC5, PC6, 'Location', 'Best');

