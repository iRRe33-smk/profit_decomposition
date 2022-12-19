function [D] = getDmatrix(salesExcel,datePeriod, t, currVec, finalItemVec)

currentDate = datePeriod(t);
arraysalesDates = datestr(table2array(salesExcel(:,1)));
allSalesDates = datenum(arraysalesDates);
closedSales = find(currentDate > allSalesDates);

numOfClosedSales = size(closedSales,1);
numOfCurr = size(currVec,1);
numOfDates = size(datePeriod,1);
numOfFinalItems = size(finalItemVec,1);


D = zeros(numOfCurr, numOfFinalItems, numOfDates);

for i = 1:numOfClosedSales
    payDate = datenum(table2array(salesExcel(closedSales(i),4)));
    dateIndex = find(payDate == datePeriod);
    amount = table2array(salesExcel(closedSales(i),6));
    currIndex = find(currVec == table2array(salesExcel(closedSales(i),5)));
    finalItemIndex = find(finalItemVec == table2array(salesExcel(closedSales(i), 2)));
    D(currIndex, finalItemIndex, dateIndex) = D(currIndex, finalItemIndex, dateIndex) + amount;
end

end