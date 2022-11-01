
%forward_rate = randi(10,20,100);
%% Simlulation of forward rates
forward_rate = monte_carlo(20,100);

%% Importing data from excel file named PCA_test.xlsx
Cash_flows = readmatrix('PCA_test.xlsx', 'sheet', 'Cash Flows', 'Range', 'F6:F7')
Cash_flows_tau = readmatrix('PCA_test.xlsx', 'sheet', 'Cash Flows', 'Range', 'G6:Z7')
%Cash_flows_timestamp = readmatrix('PCA_test.xlsx', 'sheet', 'Cash Flows', 'Range', 'E6:E7')

%%Calulation part 

%Ploting the simlulated forward rates
close all
figure(1);
plot(forward_rate(1,:))
figure(2);
plot(forward_rate(2,:))

%Calculation of covariance matrix and eigen-values/vectors
F = create_F(forward_rate); % 19x100 matrix
size(F);
covariance_F = cov(F);
size(covariance_F); %100x100 matrix
[eigenvectors_F, eigenvalues_F] = eigs(covariance_F);
size(eigenvectors_F); %100x6 matrix


%Calculation of riskfactors
F=transpose(F);
riskfactors = transpose(eigenvectors_F)*F; %6x19 matrix
size(riskfactors);

%Plots of shift, twist, butterfly
figure;
plot(riskfactors(1,:))
hold on
plot(riskfactors(2,:))
hold on
plot(riskfactors(3,:))
%{
hold on
plot(riskfactors(:,4))
hold on
plot(riskfactors(:,5))
hold on
plot(riskfactors(:,6))
%}
legend('shift', 'twist', 'butterfly', '4', '5', '6')
hold off

%Calculation of spot rates
A_spotrate = create_A(size(forward_rate,1)); %20x20 matrix
size(A_spotrate);
spot_rate = transpose(A_spotrate)*forward_rate; %20x100 matrix
size(spot_rate);

%Calculation of the AE-matrix
A_eigenvector = create_A(size(eigenvectors_F,1));
size (eigenvectors_F);
size(A_eigenvector);
AE = A_eigenvector*eigenvectors_F
size(AE);

%Calculation of the gradient
Gradient = calc_gradient(Cash_flows, Cash_flows_tau, AE, spot_rate)


%Calculation of the Hessian
Hessian = calc_hessian(Cash_flows, Cash_flows_tau, AE, spot_rate)

%-----------%
% Functions %
%-----------%

%Simulating forward rate curve (poorly)
function forward_rate = monte_carlo(days, time) 
forward_rate_temp = zeros(days, time);
forward_rate = zeros(days, time);
sim_size = 10000;
sum = 0;
    for i = 1:days
        forward_rate_temp(i,1) = 0.01;
        forward_rate(i,1) = 0.01;
        for j = 1:(time-1)
            for k = 1:sim_size
                forward_rate_temp(i,j+1) = forward_rate_temp(i,j) + forward_rate_temp(i,j)*randi([-7,10],1,1)*0.01;
                sum = forward_rate_temp(i,j+1)+sum;
            end
            forward_rate(i,j+1) = sum/sim_size;
            sum = 0;
        end
    end
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

%Creating matrix A for converting forward rates to spot rates.
function A = create_A(n)
    A = zeros(n,n);
    for i=1:n
        for j = 1:i
            A(i,j) = 1/i;
        end
    end
end

%Calculating gradient
function Gradient = calc_gradient(Cash_flows, tau, AE, spot_rate)
    Gradient = zeros(size(AE,2),size(tau,2));
    for i=1:size(tau,2)
        for j=1:size(Cash_flows)
            Gradient(:,i) = Gradient(:,i) + transpose(-AE(round(tau(j,i)*365),:)*tau(j,i)*Cash_flows(j)*exp(-(spot_rate(i,round(tau(j,i)*365))*tau(j,i))));
        end
    end
end

%Calculating hessian
function Hessian = calc_hessian(Cash_flows, tau, AE, spot_rate)
Hessian = zeros(1,size(tau,2));
    for i=1:size(tau,2)
        for j=1:size(Cash_flows)
            Hessian(:,i) = Hessian(:,i) + AE(round(tau(j,i)*365),:)*transpose(AE(round(tau(j,i)*365),:)*(tau(j,i)^2)*Cash_flows(j)*exp(-(spot_rate(i,round(tau(j,i)*365))*tau(j,i))));
        end
    end
end


