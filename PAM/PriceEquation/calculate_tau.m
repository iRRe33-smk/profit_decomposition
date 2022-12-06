function tau = calculate_tau(T,T_start,T_max)
    tau=zeros(size(T,2),T_max-T_start+1);


    for i=1:size(T,2)
        for j = 1:(T_max-T_start+1)
            tau(i,j) = (T(i)-(T_start+j-1))/365;
        end
    end
end