
clc 
clear

%% Read data

fileName = "Test_Case_Realistic.xlsx";
depositExcel = readtable(fileName,'sheet', 'deposits');
dates = readtable(fileName, 'sheet', 'hc');
FXExcel = readtable(fileName,'sheet', 'fx');
procurementExcel = readtable(fileName, 'sheet', 'procurement');
salesExcel = readtable(fileName, 'sheet', 'sales');
bomExcel = readtable(fileName, 'sheet', 'bom');
prodExcel = readtable(fileName, 'sheet','production');

%% Adding data
 currVec = ["AED"; "AUD"; "BHD"; "CAD"; "CHF"; "CNY"; "CZK"; "DKK"; "EUR"; "GBP"; "HKD";...
             "HUF"; "IDR"; "ILS"; "INR"; "ISK"; "JPY"; "KES"; "KRW"; "KWD"; "MXN"; "MYR";...
             "NOK"; "NZD"; "PHP"; "PKR"; "PLN"; "QAR"; "RON"; "RUB"; "SAR"; "SEK"; "SGD";...
             "THB"; "TRY"; "TWD"; "UGX"; "USD"; "ZAR"];
row = size(dates,1);
column = size(currVec,1) + 1;
hFX = zeros(row,column);

% Converting dates in to their numeric respresentation
% dd-mmm-yyyy --> xxxxxx
arrayDates  = datestr(table2array(dates));
formatIn = 'dd-mmm-yyyy';
datePeriod = datenum(arrayDates,formatIn);

% Adding the deposit to the FX holding-matrix
hFX(:,1) = datePeriod;
numberOfDeposit = size(depositExcel,1);

transCostB = zeros(row,column);
transCostB (:,1) = datePeriod;
transCostS = zeros(row,column);
transCostS (:,1) = datePeriod;

for i = 1:numberOfDeposit
    if(ismember(datenum(datestr(table2array(depositExcel(i,1)))), hFX(:,1)));
        indexCurr = find(ismember(currVec,string(table2array(depositExcel(i,2))))) + 1;
        date = find(ismember(hFX(:,1),datenum(table2array(depositExcel(i,1)))));
        hFX(date:row,indexCurr) = hFX(date,indexCurr) + table2array(depositExcel(i,3)) - table2array(depositExcel(i,4));
        transCostB(date,indexCurr) = transCostB(date,indexCurr) + table2array(depositExcel(i,4));
    end
end

% Executing FX-trades
numberOfFXTrades = size(FXExcel,1);

for i = 1:numberOfFXTrades
    if(ismember(datenum(datestr(table2array(FXExcel(i,1)))), hFX(:,1)))
        date = find(ismember(hFX(:,1),datenum(table2array(FXExcel(i,1)))));
        indexCurrSell = find(ismember(currVec,string(table2array(FXExcel(i,2))))) + 1;
        hFX(date:row,indexCurrSell) = hFX(date,indexCurrSell) - table2array(FXExcel(i,3)) - table2array(FXExcel(i,4));
        transCostS(date,indexCurrSell) = transCostS(date,indexCurrSell) + table2array(FXExcel(i,4));
        indexCurrBuy = find(ismember(currVec,string(table2array(FXExcel(i,5))))) + 1;
        hFX(date:row,indexCurrBuy) = hFX(date,indexCurrBuy) + table2array(FXExcel(i,6)) - table2array(FXExcel(i,7));
        transCostB(date,indexCurrBuy) = transCostB(date,indexCurrBuy) + table2array(FXExcel(i,7));
    end
end

itemVec = string(unique(table2array(procurementExcel(:,3))));
itemVec = setdiff(itemVec, "Labour");

numberOfItem = size(itemVec,1);

hItem = zeros(row,numberOfItem + 1);
hItem(:,1) = datePeriod;

numberOfProcurments = size(procurementExcel ,1);

for i = 1:numberOfProcurments
    if(ismember(datenum(datestr(table2array(procurementExcel(i,1)))), hItem(:,1)))
        dateCost = find(ismember(hItem(:,1),datenum(table2array(procurementExcel(i,5)))));
        indexCurr = find(ismember(currVec,string(table2array(procurementExcel(i,6))))) + 1;
        hFX(dateCost:row,indexCurr) = hFX(dateCost,indexCurr) - table2array(procurementExcel(i,7)) - table2array(procurementExcel(i,8));
        if("Labour" ~= string(table2array((procurementExcel(i,3)))))
            indexItem =  find(ismember(itemVec,string(table2array(procurementExcel(i,3))))) + 1;
            dateDelivery = find(ismember(hItem(:,1),datenum(table2array(procurementExcel(i,2)))));
            hItem(dateDelivery:row, indexItem) = hItem(dateDelivery, indexItem) + table2array(procurementExcel(i,4));
        end
    end
end

finalItemVec = string(unique(table2array(prodExcel(:,2))));
numberOfFinalItem = size(finalItemVec,1);

hFinalItem = zeros(row,numberOfFinalItem + 1);
hFinalItem(:,1) = datePeriod;
numberOfProd = size(prodExcel,1);

for i = 1:numberOfProd
    if(ismember(datenum(datestr(table2array(prodExcel(i,1)))), hFinalItem(:,1)))
        date = find(ismember(hFinalItem(:,1),datenum(table2array(prodExcel(i,1)))));
        indexFinalItem = find(ismember(finalItemVec,string(table2array(prodExcel(i,2))))) + 1;
        hFinalItem(date:row, indexFinalItem) = hFinalItem(date,indexFinalItem) + table2array(prodExcel(i,3));
        indexCurr = find(ismember(currVec,string(table2array(prodExcel(i,4))))) + 1;
        hFX(date:row,indexCurr) = hFX(date,indexCurr) - table2array(prodExcel(i,5));
        prodName = string(table2array(prodExcel(i,2)));
        indexBom = find(ismember(string(table2array(bomExcel(:,2))),prodName));
        for j = 1:size(indexBom,1)
            indexCurr = find(ismember(currVec,string(table2array(bomExcel(j,6))))) + 1;
            hFX(date:row, indexCurr) = hFX(date,indexCurr) - table2array(bomExcel(j,7));
            if (string(table2array(bomExcel(indexBom(j),4))) ~= "Labour")
               itemName =  string(table2array(bomExcel(indexBom(j),4)));
               indexItem = find(ismember(itemVec,itemName)) + 1;
               quanItem = table2array(bomExcel(indexBom(j),5));
               hItem(date:row, indexItem) = hItem(date, indexItem) - quanItem;
            end
        end
    end
end


numberOfSales = size(salesExcel,1);
numberOfCurr = size(currVec,1);
numberOfDates = size(arrayDates,1);
tempSalesMatrix = zeros(numberOfFinalItem,numberOfCurr);

for i = 1:numberOfDates
   if (ismember(datePeriod(i), datenum(table2array(salesExcel(:,4)))))
       salesPerDay =  sum(datenum(table2array(salesExcel(:,4))) == datePeriod(i));
       salesDate = i;
       salesDateIndex = find(ismember(datenum(table2array(salesExcel(:,4))), datePeriod(i)));
       for j = 1:salesPerDay
           indexCurr = find(ismember(currVec,string(table2array(salesExcel(salesDateIndex(j),5)))));
           itemName =  string(table2array(salesExcel(salesDateIndex(j),2)));
           indexItem = find(ismember(finalItemVec,itemName));
           deliveryDate = find(ismember(datePeriod,datenum(table2array(salesExcel(salesDateIndex(j),1)))));
           tempSalesMatrix(indexItem,indexCurr) = tempSalesMatrix(indexItem,indexCurr) + table2array(salesExcel(salesDateIndex(j),6));
           hFX(salesDate:row,indexCurr+1) = hFX(salesDate,indexCurr+1) + table2array(salesExcel(salesDateIndex(j),6));
           hFinalItem(deliveryDate:row,indexItem+1) = hFinalItem(deliveryDate,indexItem+1) - table2array(salesExcel(salesDateIndex(j),3));
       end
   else
        tempSalesMatrix = zeros(numberOfProd,numberOfCurr);
   end
   if (i == 1)
       salesMatrix = tempSalesMatrix;
   else
       salesMatrix =cat(3,salesMatrix,tempSalesMatrix);
   end
end


