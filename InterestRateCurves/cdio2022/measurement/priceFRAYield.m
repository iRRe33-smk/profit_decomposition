function [yield] = priceFRAYield(t1, t2, dt, rSpot, T)

nFRA = length(t1);
price = zeros(size(t1));
yield = zeros(size(t1));
for i = 1:nFRA
  discount = exp(-(rSpot(t1(i)+1)*T(t1(i)+1) ...
                   -rSpot(t2(i)+1)*T(t2(i)+1) ));
yield(i) = (discount-1)/dt(i);
end
