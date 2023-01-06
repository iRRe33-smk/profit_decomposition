
function [risk_factors,spot_rates,AE] = getPCAdata(forward_rates,forward_dates,currVec,T_max)
start_date = datetime(2022,8,15);
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

    T = [30; 60; 90; 180; 270; 365; 455; 545; 635; 730; 820; 910; 1000; 1095; 1185; 1275; 1365; 1460; 1550; 1640; 1730; 1825; 1915; 2005; 2095; 2190; 2280; 2370; 2460; 2555; 2645; 2735; 2825; 2920; 3010; 3100; 3190; 3285; 3375; 3465; 3555; 3650]/365;
    % Add below lines if you want to plot PCA data
%     if(k==9 || k==32 || k==38)
%         plot_PCA(eigen_vectors,eigen_values,C,T,currVec(k,1))
%     end
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

%Creating matrix F from forward rates
function F = create_F(forward_rate)
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









