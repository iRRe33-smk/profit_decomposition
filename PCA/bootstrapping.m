function [r] = bootstrapping(F,T)
r = zeros(length(T),1);

for i=1:length(T)
    if T(i) <= 1
        r(i)=(1/T(i))*log(1+F(i)*T(i));
    else
        sum = 0;
        for j=1:(i-1)
            sum = sum + exp(-r(j)*T(j));
        end
        r(i)=(1/T(i))*log((1+F(i))/(1-F(i)*sum));
    end
end

end