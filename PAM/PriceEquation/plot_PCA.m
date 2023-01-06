function plot_PCA(eigen_vectors,eigen_values,C,T,currency)

dt=1/365;

M = round(T*1/dt); % Maturities (measured in number of time periods)
share = diag(eigen_values)/sum(diag(C));
cshare = cumsum(share);
shift     = sprintf('Shift        %5.2f%% (%5.2f%%)\n',100*share(1), 100*cshare(1));
twist     = sprintf('Twist        %5.2f%% (%5.2f%%)\n',100*share(2), 100*cshare(2));
butterfly = sprintf('Butterfly    %5.2f%% (%5.2f%%)\n',100*share(3), 100*cshare(3));
PC4       = sprintf('Loadings PC4 %5.2f%% (%5.2f%%)\n',100*share(4), 100*cshare(4));
PC5       = sprintf('Loadings PC5 %5.2f%% (%5.2f%%)\n',100*share(5), 100*cshare(5));
PC6       = sprintf('Loadings PC6 %5.2f%% (%5.2f%%)\n',100*share(6), 100*cshare(6));
figure("name", currency);
plot((0:M(end)-1)*dt, eigen_vectors(:,1:3)', (0:M(end)-1)*dt, eigen_vectors(:,4:6)', '--');
title('Eigenvectors');
legend(shift,twist,butterfly, PC4, PC5, PC6, 'Location', 'Best');

end