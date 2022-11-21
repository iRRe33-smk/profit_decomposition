%% Read data
clc 
clear
depositExcel = readtable('caseTest.xlsx','sheet', 'deposits');
dates = readtable('caseTest.xlsx', 'sheet', 'hc');
FXExcel = readtable('caseTest.xlsx','sheet', 'fx');
transactionExcel = readtable('casetest.xlsx', 'sheet', 'transaction');
salesExcel = readtable('casetest.xlsx', 'sheet', 'sales')
bomExcel = readtable('casetest.xlsx', 'sheet', 'bom')

%% Adding data
currVec = ["SEK"; "USD"; "CAD"];
row = size(dates,1);
column = size(currVec,1) + 1;
hFX = zeros(row,column);

% Converting dates in to their numeric respresentation
% dd-mmm-yyyy --> xxxxxx
array_dates  = datestr(table2array(dates));
formatIn = 'dd-mmm-yyyy';
datePeriod = datenum(array_dates,formatIn);

% Adding the deposit to the FX holding-matrix
hFX(:,1) = datePeriod;
numberOfDeposit = size(depositExcel,1);

%Kolla på datum
for i = 1:numberOfDeposit
    if(ismember(datenum(datestr(table2array(depositExcel(i,1)))), hFX(:,1)));
        indexCurr = find(ismember(currVec,string(table2array(depositExcel(i,2))))) + 1;
        date = find(ismember(hFX(:,1),datenum(table2array(depositExcel(i,1)))));
        hFX(date:row,indexCurr) = hFX(i,indexCurr) - table2array(depositExcel(i,3));
    end
end

% Adding the transaction cost for the deposits
transCostB = zeros(row,column);
transCostB (:,1) = datePeriod;
transCostS = zeros(row,column);
transCostS (:,1) = datePeriod;

for i = 1:numberOfDeposit
    if(ismember(datenum(datestr(table2array(depositExcel(i,1)))), transCostB(:,1)));
        indexCurr = find(ismember(currVec,string(table2array(depositExcel(i,2))))) + 1;
        date = find(ismember(hFX(:,1),datenum(table2array(depositExcel(i,1)))));
        transCostB(date,indexCurr) = transCostB(date,indexCurr) + table2array(depositExcel(i,4));
        hFX(date,indexCurr) = hFX(date,indexCurr) - table2array(depositExcel(i,4));
    end
end

% Executing FX-trades
numberOfFXTrades = size(FXExcel,1);

for i = 1:numberOfFXTrades
    if(ismember(datenum(datestr(table2array(FXExcel(i,1)))), hFX(:,1)))
        date = find(ismember(hFX(:,1),datenum(table2array(FXExcel(i,1)))));
        indexCurrSell = find(ismember(currVec,string(table2array(FXExcel(i,2))))) + 1;
        hFX(date:row,indexCurrSell) = hFX(i,indexCurrSell) + table2array(FXExcel(i,3)) - table2array(FXExcel(i,4));
        transCostS(i,indexCurrSell) = transCostS(i,indexCurrSell) + table2array(FXExcel(i,4));
        indexCurrBuy = find(ismember(currVec,string(table2array(FXExcel(i,5))))) + 1;
        hFX(date:row,indexCurrBuy) = hFX(i,indexCurrBuy) + table2array(FXExcel(i,6)) - table2array(FXExcel(i,7));
        transCostB(i,indexCurrBuy) = transCostB(i,indexCurrBuy) + table2array(FXExcel(i,7));
    end
end

itemVec = string(unique(table2array(transactionExcel(:,3))));
itemVec = setdiff(itemVec, "Labour");

numberOfItem = size(itemVec,1);

hItem = zeros(row,numberOfItem + 1);
hItem(:,1) = datePeriod;

numberOfTransactions = size(transactionExcel ,1);

for i = 1:numberOfTransactions
    if(ismember(datenum(datestr(table2array(transactionExcel(i,1)))), hItem(:,1)))
        dateCost= find(ismember(hItem(:,1),datenum(table2array(transactionExcel(i,5)))));
        indexCurr = find(ismember(currVec,string(table2array(transactionExcel(i,6))))) + 1;
        hFX(dateCost:row,indexCurr) = hFX(dateCost,indexCurr) - table2array(transactionExcel(i,7));
        if("Labour" == string(table2array((transactionExcel(i,3)))))
            transCostB(dateCost,indexCurr) = transCostB(dateCost,indexCurr) + table2array(transactionExcel(i,7));
        else
            indexItem =  find(ismember(itemVec,string(table2array(transactionExcel(i,3))))) + 1;
            dateDelivery = find(ismember(hItem(:,1),datenum(table2array(transactionExcel(i,2)))));
            hItem(dateDelivery:row, indexItem) = hItem(dateDelivery, indexItem) + table2array(transactionExcel(i,4));
        end
    end
end





