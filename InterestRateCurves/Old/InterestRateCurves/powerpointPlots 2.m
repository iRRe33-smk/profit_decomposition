[f, z, e, T, date] = IRC(16, 1000000);


figure(1)
subplot(4,1,[1,3]);
plot(f);
title('Continously compunded forward rates, Constraint ex. 1')
xlabel('Days')
ylabel('%')
set(gca,'TickLength',[0 0])
legend('E = 1000000','Location','southeast')

subplot(4,1,4);
stem(abs(z));
title({'';'Deviation from market prices'})
ylabel('Basis points')
set(gca,'TickLength',[0 0])

figure(2)
e = [1, 100, 10000, 1000000, 100000000];
hold on
for i = 1:length(e)
    [f, z, E, T, date] = IRC(16, e(i));
    plot(f);
end
hold off
title('Continously compunded forward rates, Constraint ex. 1')
xlabel('Days')
ylabel('%')
legend('E = 1', 'E = 100', 'E = 10000', 'E = 1000000', 'E = 100000000','Location','southeast')




[f, z, e, T, date] = IRC2(16, 1000000);


figure(3)
subplot(4,1,[1,3]);
plot(f);
title('Continously compunded forward rates, Constraint ex. 2')
xlabel('Days')
ylabel('%')
set(gca,'TickLength',[0 0])
legend('E = 1000000','Location','southeast')

subplot(4,1,4);
stem(abs(z));
title({'';'Deviation from market prices'})
ylabel('Basis points')
set(gca,'TickLength',[0 0])

figure(4)
e = [1, 100, 10000, 1000000, 100000000];
hold on
for i = 1:length(e)
    [f, z, E, T, date] = IRC2(16, e(i));
    plot(f);
end
hold off
title('Continously compunded forward rates, Constraint ex. 2')
xlabel('Days')
ylabel('%')
legend('E = 1', 'E = 100', 'E = 10000', 'E = 1000000', 'E = 100000000','Location','southeast')

%%
[f, z, e, T, date] = IRC3(16, 1000000);
[f2, z2, e, T, date] = IRC3(16, 10);

figure(5)
subplot(5,1,[1,3]);
plot(f);
hold on 
plot(f2)
hold off
title('Continously compunded forward rates, Constraint ex. 3')
xlabel('Days')
ylabel('%')
set(gca,'TickLength',[0 0])
legend('E = 1000000', 'E = 10', 'Location','southeast')

subplot(5,1,4);
stem(abs(z));
title({'';'Deviation from market prices - E = 1000000'})
ylabel('Basis points')
set(gca,'TickLength',[0 0])
subplot(5,1,5);
stem(abs(z2));
title({'';'Deviation from market prices - E = 10'})
ylabel('Basis points')
set(gca,'TickLength',[0 0])

figure(6)
e = [0.01, 1, 10, 1000, 100000];
hold on
for i = 1:length(e)
    [f, z, E, T, date] = IRC3(16, e(i));
    plot(f);
end
hold off
title('Continously compunded forward rates, Constraint ex. 3')
xlabel('Days')
ylabel('%')
legend('E = 0.01', 'E = 1', 'E = 10', 'E = 1000', 'E = 100000', 'Location','southeast')


%%
[forwardRates, spotRates, discountFactors, T,daysInBtw, dates] = getForwAndSpot();

figure(7)
subplot(3,1,1)
plot(forwardRates(1:60, 10:19))
subplot(3,1,2)
plot(spotRates(1:60, 10:19))
subplot(3,1,3)
plot(discountFactors(1:60, 10:19))





