

%Dates = readmatrix('currency.xlsx', 'Sheet', 'SEKCurrency', 'Range', 'A3:A7909');

[num, txt, raw] = xlsread('currency.xlsx','SEKCurrency','A2:AN7908');
%%

[r, c] = size(num); 


nanArray = isnan(num); 
isnanVector = sum(nanArray, 2); 
cRates = zeros(sum(isnanVector(:) == 0), c);
counter = 1; 

for i = 1:r
    if isnanVector(i) == 0
       cRates(counter,:) = num(i,:); 
       counter = counter +1;
    end
end

%%
filename = 'currencyCurves.xlsx';
writecell(txt,filename,'Sheet',1,'Range','A1')
writematrix(cRates,filename,'Sheet',1,'Range','A2')

