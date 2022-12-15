currencies = ["AED", "AUD", "BHD", "CAD", "CHF", "CNY", "CZK", "DKK", ...
              "EUR", "GBP", "HKD", "HUF", "IDR", "ILS", "INR", "ISK", ...
              "JPY", "KES", "KRW", "KWD", "MXN", "MYR", "NOK", "NZD", ...
              "PHP", "PKR", "PLN", "QAR", "RON", "RUB", "SAR", "SEK", ...
              "SGD", "THB", "TRY", "TWD", "UGX", "USD", "ZAR"]';
i = 9;
curve = matfile('\\ad.liu.se\home\adaen534\Desktop\profit_decomposition\InterestRateCurves\120daysCurves\' + currencies(i) + '.mat');
curve = curve.f;
deviation = matfile('\\ad.liu.se\home\adaen534\Desktop\profit_decomposition\InterestRateCurves\120PriceDeviations\' + currencies(i) + 'dev.mat');
deviation = deviation.z;
dates = matfile('\\ad.liu.se\home\adaen534\Desktop\profit_decomposition\InterestRateCurves\CurveDates\' + currencies(i) + 'Dates.mat');
dates = dates.dates;
dates = dates(1:120, 1);
dates = datetime(dates{:,1});
days = 1:1:3650;

%dates = 1:1:120;
figure(1)
mesh(dates,days, curve)
figure(2)
x = 1:1:14;
%dates = 1:1:120;
%heatmap(dates, x, (abs(deviation)))

plot_mesh(curve, 'hej', 'hopp', dates)
function plot_mesh(data, title_string, z_string, dates)
    figure(3)
    set(gca,'TickLabelInterpreter','latex')
    d1 = datenum(dates(end))
    datestr(datenum(dates(end)))
    %d1 = dates(1);
    d2 = datenum(dates(1))
    datestr(datenum(dates(1)))
    %d2 = dates(end);
    daysT = d1:1:d2
    days_weekdays_only = daysT(and(weekday(daysT)~=1,weekday(daysT)~=7));
    h = mesh(data'); c=colorbar;
    %c.Label.Interpreter = 'latex';
    c.Ruler.TickLabelFormat='%g%%'; hold on;
    
    h.XData = h.XData/365;
    xlabel('Maturity [years]')
    ylabel('Date')
    N_dates = 5;
    days = zeros(N_dates,1);
    days(1) = days_weekdays_only(1);
    days(2) = days_weekdays_only(30);
    days(3) = days_weekdays_only(60);
    days(4) = days_weekdays_only(90);
    days(5) = days_weekdays_only(120);
    datestr(days(5))
    
    L = get(gca,'YLim');
    set(gca,'YTick',linspace(L(1),L(2),N_dates));
    
    yticklabels(datestr(days))
    zlabel(z_string)
    ztickformat('percentage')
    h.ZData = h.ZData*100;
    title(title_string)
end