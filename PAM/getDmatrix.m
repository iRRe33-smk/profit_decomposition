function [D] = getDmatrix(salesExcel,datePeriod, t, currVec)

currentDate = datePeriod(t);
arraysalesDates = datestr(table2array(salesExcel(:,1)));
allSalesDates = datenum(arraysalesDates);
closedSales = find(currentDate > allSalesDates);

numOfClosedSales = size(closedSales,1);
numOfSales = size(salesExcel,1);
numOfCurr = size(currVec,1);
numOfDates = size(datePeriod,1);


D = zeros(numOfCurr, numOfSales, numOfDates);

for i = 1:numOfClosedSales
    payDate = datenum(table2array(salesExcel(closedSales(i),4)));
    dateIndex = find( payDate == datePeriod);
    amount = table2array(salesExcel(closedSales(i),6));
    currIndex = find(currVec == table2array(salesExcel(closedSales(i),5)));
    D(currIndex, closedSales(i), dateIndex) = D(currIndex, closedSales(i), dateIndex) + amount;
end

end