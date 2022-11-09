
function [risk_factors, gradient, hessian] = get_PCA_data(c, tau,forward_rates)

%Get riskfactors by running create_riskfactors.m
fAll = create_F(forward_rates);
[risk_factors, eigen_values, eigen_vectors,C] = create_riskfactor(fAll);

%Convert forwardrates to spotrates
A_spot_rates = create_A(size(forward_rates,1)); %20x20 matrix
spot_rates = transpose(A_spot_rates)*forward_rates; %20x100 matrix

%Calculation of the AE-matrix
A_eigen_vectors = create_A(size(eigen_vectors,1));
AE = A_eigen_vectors*eigen_vectors;

%Get gradient and hessian
gradient = create_gradient(c,tau,AE,spot_rates);
hessian = create_hessian(c,tau,AE,spot_rates);

%Plot PCA
dt=1/365;
T = [1/12 ; 2/12 ; 3/12 ; 6/12 ; 9/12 ; 1 ; 2 ; 3 ; 4 ; 5 ; 6 ; 7 ; 8 ; 9 ; 10]; % Maturities
M = round(T*1/dt); % Maturities (measured in number of time periods)
share = diag(eigen_values)/sum(diag(C));
cshare = cumsum(share);
shift     = sprintf('Shift        %5.2f%% (%5.2f%%)\n',100*share(1), 100*cshare(1));
twist     = sprintf('Twist        %5.2f%% (%5.2f%%)\n',100*share(2), 100*cshare(2));
butterfly = sprintf('Butterfly    %5.2f%% (%5.2f%%)\n',100*share(3), 100*cshare(3));
PC4       = sprintf('Loadings PC4 %5.2f%% (%5.2f%%)\n',100*share(4), 100*cshare(4));
PC5       = sprintf('Loadings PC5 %5.2f%% (%5.2f%%)\n',100*share(5), 100*cshare(5));
PC6       = sprintf('Loadings PC6 %5.2f%% (%5.2f%%)\n',100*share(6), 100*cshare(6));
figure(2);
plot((0:M(end)-1)*dt, eigen_vectors(:,1:3)', (0:M(end)-1)*dt, eigen_vectors(:,4:6)', '--');
title('Eigenvectors');
legend(shift,twist,butterfly, PC4, PC5, PC6, 'Location', 'Best');

end

%Creating matrix F from forward rates
function F = create_F(forward_rate)
    T = size(forward_rate,1);
    n = size(forward_rate,2);
    F = zeros(T-1,n);
    for i=1:(T-1)
        for j=1:n
            F(i,j) = forward_rate(i+1,j)-forward_rate(i,j);
        end
    end
end

function A = create_A(n)
A = zeros(n,n);
    for i=1:n
        for j = 1:i
            A(i,j) = 1/i;
        end
    end
end 









