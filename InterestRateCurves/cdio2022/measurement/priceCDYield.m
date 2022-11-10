function [yield] = priceCDYield(t0, t1, dt, rSpot, T)

nCD = length(t0);
yield = zeros(size(t0));
for i = 1:nCD
  discount = exp(-(rSpot(t1(i)+1)*T(t1(i)+1) ...
                  -rSpot(t0(i)+1)*T(t0(i)+1) ));
  yield(i) = (1/discount-1)/dt(i);
end
