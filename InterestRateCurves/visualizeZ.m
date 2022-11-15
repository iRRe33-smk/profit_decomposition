[forwardRates, spotRates, discountFactors, ~,daysInBtw, dates] = getForwAndSpot();
T = [1 2 7 14 30 60 90 180 270 1*365 2*365 3*365 4*365 5*365 6*365 7*365 ...
         8*365 9*365 10*365 11*365 12*365 13*365 14*365 15*365 20*365 25*365 30*365];
discountFactors = discountFactors';
e = 1000/365;
[f, z] = curveGeneration(discountFactors, T, e);

subplot(4,4 ,[1,12]);
day = 56;
z = z/10000;
plot(f(:, day));
hold on
for i = 1:length(T)
    x = T(i);
    y = f(x, day);
    delta_y = z(i,day);
    quiver(x, y, 0, delta_y, 0, 'r');
    scatter(x, y+delta_y,'r');
end
axis([-100, max(T)*1.05, min(f(:,day))- abs(min(f(:,day))*2), max(f(:,day))*1.05])
subplot(4,4 ,[13,14]);
stem(z(:,day)*10000)
axis([0,length(T), min(z(:,day)*10000) - abs(min(z(:,day)*10000))*0.2, max(z(:,day)*10000)*1.2])
subplot(4,4 ,[15,16]);
plot(f(1:70,day))
hold on
for i = 1:6
    x = T(i);
    y = f(x, day);
    delta_y = z(i,day);
    quiver(x, y, 0, delta_y, 0, 'r');
    scatter(x, y+delta_y,'r');
end






