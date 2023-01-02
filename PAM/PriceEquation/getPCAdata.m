
function [risk_factors,spot_rates,AE] = getPCAdata(forward_rates,forward_dates,currVec,T_max)
start_date = datetime(2022,8,15);
%end_date = datetime(2022,11,15);
%Get riskfactors by running create_riskfactors.m
for k=1:size(forward_rates)

    if ~istable(forward_dates{k,2})
        [dates] = forward_dates{k,2};
    else
        dates = table2array(forward_dates{k,2});
    end
    if ~isempty(find(dates==start_date))
        index = find(dates == start_date);
    else
        A=true;
        j=1;
        while A
            temp_date=start_date - caldays(j);
            if ~isempty(find(dates==temp_date))
                A = false;
                index = find(dates==temp_date);
            end
            j=j+1;
        end
    end

    fAll = create_F(flipud(cell2mat(forward_rates(k,2))));
    [risk_factors_temp, eigen_values, eigen_vectors,C] = create_riskfactor(fAll,flipud(dates(1:index)),T_max,index);
    risk_factors(:,k)={currVec(k,1);risk_factors_temp};

    %Convert forwardrates to spotrates
    forward_rates_temp = cell2mat(forward_rates(k,2));
    [spot_rates_temp,A] = calculate_spotrates(flipud(forward_rates_temp(1:index,:)),flipud(dates(1:index)),T_max);
    spot_rates(:,k) = {currVec(k,1);spot_rates_temp};
    
    %Calculation of the AE-matrix
    AE_temp = A*eigen_vectors;
    AE(:,k) = {currVec(k,1);AE_temp};

    fprintf('%d of %d iterations completed\n',k,size(currVec,1));
end


function [spot_rate_actual, A] = calculate_spotrates(forward_rate,dates,T_max)
    spot_rate = zeros(T_max,size(forward_rate,2));
    A = create_A(size(forward_rate,2));
    j=1;
    for i=1:size(forward_rate,1)
        if i==1
        spot_rate(j,:) = (A*forward_rate(i,:)')';
        j=j+1;

        else
        diff = daysact(dates(i-1),dates(i));
        for l =1:diff-1
            spot_rate(j,:)= spot_rate(j-1,:);
            j=j+1;
        end
        spot_rate(j,:)=(A*forward_rate(i,:)')';
        j=j+1;
        end
    end
    if size(forward_rate,1)==1
        spot_rate(j,:) = spot_rate(j-1,:);
        j=j+1;
    end
    spot_rate_actual = spot_rate(end-T_max+1:end,:);

end
%{
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
%}

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
    F = forward_rate(1:end-1,:)-forward_rate(2:end,:);
end

function A = create_A(n)
A = zeros(n,n);
    for i=1:n
        for j = 1:i
            A(i,j) = 1/i;
        end
    end
end 
end









