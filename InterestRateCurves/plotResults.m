clear all
% This script changes all interpreters from tex to latex. 
list_factory = fieldnames(get(groot,'factory'));
index_interpreter = find(contains(list_factory,'Interpreter'));
for i = 1:length(index_interpreter)
    default_name = strrep(list_factory{index_interpreter(i)},'factory','default');
    set(groot, default_name,'latex');
end


currencies = ["AED", "AUD", "BHD", "CAD", "CHF", "CNY", "CZK", "DKK", ...
              "EUR", "GBP", "HKD", "HUF", "IDR", "ILS", "INR", "ISK", ...
              "JPY", "KES", "KRW", "KWD", "MXN", "MYR", "NOK", "NZD", ...
              "PHP", "PKR", "PLN", "QAR", "RON", "RUB", "SAR", "SEK", ...
              "SGD", "THB", "TRY", "TWD", "UGX", "USD", "ZAR"]';

%%
i = 9;
curve = matfile('C:\Users\adame\Desktop\profit_decomposition\InterestRateCurves\120daysCurves\' + currencies(i) + '.mat');
curve = curve.f;
curve = 100*curve;
deviation = matfile('C:\Users\adame\Desktop\profit_decomposition\InterestRateCurves\120PriceDeviations\' + currencies(i) + 'dev.mat');
deviation = deviation.z;
T = [30,60,90,180,270,365,455,545,635,730,820,910,1000,1095,1185,1275,1365,1460,1550,1640,1730,1825,1915,2005,2095,2190,2280,2370,2460,2555,2645,2735,2825,2920,3010,3100,3190,3285,3375,3465,3555,3650]./365;
dates = matfile('C:\Users\adame\Desktop\profit_decomposition\InterestRateCurves\CurveDates\' + currencies(i) + 'Dates.mat');
dates = dates.dates;
dates = dates(1:120, 1);
dates = datetime(dates{:,1});
days = linspace(1,10,3650);
figure(1)
mesh(dates,days, curve)
colorbar
ylabel('Time to Maturity (years)')
xlabel('Date')
zlabel('Forward Rate ($\%$)')
%c = colorbar;
%c.Label.String = '($\%$)';
%c.Label.Interpreter = 'latex';
title('Continously compounded forward rate for EUR')
set(findall(gcf,'-property','FontSize'),'FontSize',26)
view([-50.5792 16.0551])
figure(2)
subplot(2,1,1)
stem(T, mean(deviation,2))
set(gca,'TickLength',[0 0])
ylim([(min(mean(deviation, 2)) - 5), (max(mean(deviation, 2)) + 5)]) 
xlim([0, max(T) + 0.1])
ylabel('$\mathbf{mean}(z)$', 'interpreter', 'latex', 'Fontsize', 26)
title('Deviation from Market Prices for EUR')
subplot(2,1,2)
stem(T, mean(abs(deviation),2))
set(gca,'TickLength',[0 0])
ylim([-5, max(mean(abs(deviation),2)) + 5]) 
xlim([0, max(T) + 0.1])
ylabel('$\vert  \mathbf{mean}(z) \vert$', 'interpreter', 'latex', 'Fontsize', 26)
xlabel('Time to Maturity (years)')
set(findall(gcf,'-property','FontSize'),'FontSize',26)
%%
i = 38;
curve = matfile('C:\Users\adame\Desktop\profit_decomposition\InterestRateCurves\120daysCurves\' + currencies(i) + '.mat');
curve = curve.f;
curve = 100*curve;
deviation = matfile('C:\Users\adame\Desktop\profit_decomposition\InterestRateCurves\120PriceDeviations\' + currencies(i) + 'dev.mat');
deviation = deviation.z;
T = [30,60,90,180,270,365,455,545,635,730,820,910,1000,1095]./365;
dates = matfile('C:\Users\adame\Desktop\profit_decomposition\InterestRateCurves\CurveDates\' + currencies(i) + 'Dates.mat');
dates = dates.dates;
dates = dates(1:120, 1);
dates = datetime(dates{:,1});
days = linspace(1,10,3650);
figure(3)
mesh(dates,days, curve)
colorbar
ylabel('Time to Maturity (years)')
xlabel('Date')
zlabel('Forward Rate ($\%$)')
%c = colorbar;
%c.Label.String = '($\%$)';
%c.Label.Interpreter = 'latex';
title('Continously compounded forward rate for USD')
set(findall(gcf,'-property','FontSize'),'FontSize',26)
view([-50.5792 16.0551])
figure(4)
subplot(2,1,1)
stem(T, mean(deviation,2))
set(gca,'TickLength',[0 0])
ylim([(min(mean(deviation, 2)) - 5), (max(mean(deviation, 2)) + 5)]) 
xlim([0, max(T) + 0.1])
ylabel('$\mathbf{mean}(z)$', 'interpreter', 'latex', 'Fontsize', 26)
title('Deviation from Market Prices for USD')
subplot(2,1,2)
stem(T, mean(abs(deviation),2))
set(gca,'TickLength',[0 0])
ylim([-5, max(mean(abs(deviation),2)) + 5]) 
xlim([0, max(T) + 0.1])
ylabel('$\vert  \mathbf{mean}(z) \vert$', 'interpreter', 'latex', 'Fontsize', 26)
xlabel('Time to Maturity (years)')
set(findall(gcf,'-property','FontSize'),'FontSize',26)

%%
i = 32;
curve = matfile('C:\Users\adame\Desktop\profit_decomposition\InterestRateCurves\120daysCurves\' + currencies(i) + '.mat');
curve = curve.f;
curve = 100*curve;
deviation = matfile('C:\Users\adame\Desktop\profit_decomposition\InterestRateCurves\120PriceDeviations\' + currencies(i) + 'dev.mat');
deviation = deviation.z;
T = [30,60,90,120,150,180,210,240,270,365,455,545,635,730,820,910,1000,1095,1185,1275,1365,1460,1550,1640,1730,1825,1915,2005,2095,2190,2280,2370,2460,2555,2645,2735,2825,2920,3010,3100,3190,3285,3375,3465,3555,3650]./365;
dates = matfile('C:\Users\adame\Desktop\profit_decomposition\InterestRateCurves\CurveDates\' + currencies(i) + 'Dates.mat');
dates = dates.dates;
dates = dates(1:120, 1);
dates = datetime(dates{:,1});
days = linspace(1,10,3650);
figure(5)
mesh(dates,days, curve)
colorbar
ylabel('Time to Maturity (years)')
xlabel('Date')
zlabel('Forward Rate ($\%$)')
%c = colorbar;
%c.Label.String = '($\%$)';
%c.Label.Interpreter = 'latex';
title('Continously compounded forward rate for SEK')
set(findall(gcf,'-property','FontSize'),'FontSize',26)
view([-50.5792 16.0551])
figure(6)
subplot(2,1,1)
stem(T, mean(deviation,2))
set(gca,'TickLength',[0 0])
ylim([(min(mean(deviation, 2)) - 5), (max(mean(deviation, 2)) + 5)]) 
xlim([0, max(T) + 0.1])
ylabel('$\mathbf{mean}(z)$', 'interpreter', 'latex', 'Fontsize', 26)
title('Deviation from Market Prices for SEK')
subplot(2,1,2)
stem(T, mean(abs(deviation),2))
set(gca,'TickLength',[0 0])
ylim([-5, max(mean(abs(deviation),2)) + 5]) 
xlim([0, max(T) + 0.1])
ylabel('$\vert  \mathbf{mean}(z) \vert$', 'interpreter', 'latex', 'Fontsize', 26)
xlabel('Time to Maturity (years)')
set(findall(gcf,'-property','FontSize'),'FontSize',26)

