[discountFactors, dates, maturity, n_size, ...
 n_dates, n_datapoints, x, x_tick, maturity_tick] = ...
 PreliminaryCurvesConstants();

%Enkla räntor
simpleRates = zeros(size(discountFactors));
for day = 1:n_dates
    for i = 1:n_datapoints
        simpleRates(day, i) = (1/discountFactors(day,i) - 1)/(x(i)/360);
    end
end

%Forward-räntor
forwardRates = zeros(size(discountFactors));
for day = 1:n_dates
    for i = 1:n_datapoints
        forwardRates(day, i) = -log(discountFactors(day,i))/(x(i)/360);
    end
end

curves = zeros(n_dates, 10800);
xx = 1:1:10800;
%Kurvor ligger i curves, nehä
for day = 1:n_dates
    %curves(day, :) = spline(x, simpleRates(day, :), xx);
    curves(day, :) = spline(x, forwardRates(day, :), xx);
end


day = 25; %Dag att plotta
days = 10800; %Antal dagar att plotta, dag 1 till och med days
plot(curves(day,:))
set(gca,'xtick',x_tick,'xticklabel',maturity_tick)
axis([-100 days (min(curves(day,1:days)) - 0.1*range(curves(day,1:days))) ...
             (max(curves(day,1:days)) + 0.1*range(curves(day,1:days)))])

