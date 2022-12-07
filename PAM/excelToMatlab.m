
function[numProductsRaw, numProductsFinished, numCurrencies, D, h_p_finished_matrix, h_p_raw_matrix,...
    h_c_matrix, xsProd_b_matrix, xsProd_s_matrix, xsCurr_b_matrix, FXMatrix, dFMatrix, P_raw_matrix, ...
    dP_raw_matrix, row] = excelToMatlab()

%% Read data

fileName = "Test_Case_Realistic.xlsx";
depositExcel = readtable(fileName,'sheet', 'deposits');
dates = readtable(fileName, 'sheet', 'hc');
FXExcel = readtable(fileName,'sheet', 'fx');
procurementExcel = readtable(fileName, 'sheet', 'procurement');
salesExcel = readtable(fileName, 'sheet', 'sales');
bomExcel = readtable(fileName, 'sheet', 'bom');
prodExcel = readtable(fileName, 'sheet','production');
P_raw_matrix =  xlsread(fileName,"Price List Valuta", 'B2:T94');
FXMatrix =  xlsread(fileName,"usedFXCurves");

%% Adding data
 currVec = ["AED"; "AUD"; "BHD"; "CAD"; "CHF"; "CNY"; "CZK"; "DKK"; "EUR"; "GBP"; "HKD";...
             "HUF"; "IDR"; "ILS"; "INR"; "ISK"; "JPY"; "KES"; "KRW"; "KWD"; "MXN"; "MYR";...
             "NOK"; "NZD"; "PHP"; "PKR"; "PLN"; "QAR"; "RON"; "RUB"; "SAR"; "SEK"; "SGD";...
             "THB"; "TRY"; "TWD"; "UGX"; "USD"; "ZAR"];
row = size(dates,1);
column = size(currVec,1) + 1;
h_c_matrix = zeros(row,column);

% Converting dates in to their numeric respresentation
% dd-mmm-yyyy --> xxxxxx
arrayDates  = datestr(table2array(dates));
formatIn = 'dd-mmm-yyyy';
datePeriod = datenum(arrayDates,formatIn);

% Adding the deposit to the FX holding-matrix
h_c_matrix(:,1) = datePeriod;
numberOfDeposit = size(depositExcel,1);

xsProd_b_matrix = zeros(row,column);
xsProd_b_matrix (:,1) = datePeriod;
xsProd_s_matrix = zeros(row,column);
xsProd_s_matrix (:,1) = datePeriod;

xsCurr_b_matrix = zeros(row,column);
xsCurr_b_matrix (:,1) = datePeriod;


for i = 1:numberOfDeposit
    if(ismember(datenum(datestr(table2array(depositExcel(i,1)))), h_c_matrix(:,1)));
        indexCurr = find(ismember(currVec,string(table2array(depositExcel(i,2))))) + 1;
        date = find(ismember(h_c_matrix(:,1),datenum(table2array(depositExcel(i,1)))));
        h_c_matrix(date:row,indexCurr) = h_c_matrix(date:row,indexCurr) + table2array(depositExcel(i,3)) - table2array(depositExcel(i,4));
        xsCurr_b_matrix(date,indexCurr) = xsCurr_b_matrix(date,indexCurr) + table2array(depositExcel(i,4));
    end
end

% Executing FX-trades
numberOfFXTrades = size(FXExcel,1);

for i = 1:numberOfFXTrades
    if(ismember(datenum(datestr(table2array(FXExcel(i,1)))), h_c_matrix(:,1)))
        date = find(ismember(h_c_matrix(:,1),datenum(table2array(FXExcel(i,1)))));
        indexCurrSell = find(ismember(currVec,string(table2array(FXExcel(i,2))))) + 1;
        h_c_matrix(date:row,indexCurrSell) = h_c_matrix(date:row,indexCurrSell) - table2array(FXExcel(i,3)) - table2array(FXExcel(i,4));
        xsCurr_b_matrix(date,indexCurrSell) = xsCurr_b_matrix(date,indexCurrSell) + table2array(FXExcel(i,4));
        indexCurrBuy = find(ismember(currVec,string(table2array(FXExcel(i,5))))) + 1;
        h_c_matrix(date:row,indexCurrBuy) = h_c_matrix(date:row,indexCurrBuy) + table2array(FXExcel(i,6));
    end
end

[~,itemVec] = xlsread(fileName,"Price List SEK",'B1:T1');
itemVec = string(itemVec)';

numProductsRaw = size(itemVec,1);


% dP Non final product
dP_raw_matrix = zeros(row,numProductsRaw);
for i = 1:row-1
   dP_raw_matrix(i+1,:) = P_raw_matrix(i+1,:) - P_raw_matrix(i,:);
end

%Changes in FX rate
numberOfCur = size(currVec,1);
dF = zeros(row, numberOfCur);
for i = 1:row-1
    dFMatrix(i+1,:) = FXMatrix(i+1,:) - FXMatrix(i,:);
end

h_p_raw_matrix = zeros(row,numProductsRaw + 1);
h_p_raw_matrix(:,1) = datePeriod;

numberOfProcurments = size(procurementExcel ,1);

for i = 1:numberOfProcurments
    if(ismember(datenum(datestr(table2array(procurementExcel(i,1)))), h_p_raw_matrix(:,1)))
        dateCost = find(ismember(h_p_raw_matrix(:,1),datenum(table2array(procurementExcel(i,5)))));
        indexCurr = find(ismember(currVec,string(table2array(procurementExcel(i,6))))) + 1;
        h_c_matrix(dateCost:row,indexCurr) = h_c_matrix(dateCost:row,indexCurr) - table2array(procurementExcel(i,7)) - table2array(procurementExcel(i,8));
        if("Labour" ~= string(table2array((procurementExcel(i,3)))))
            indexItem =  find(ismember(itemVec,string(table2array(procurementExcel(i,3))))) + 1;
            dateDelivery = find(ismember(h_p_raw_matrix(:,1),datenum(table2array(procurementExcel(i,2)))));
            h_p_raw_matrix(dateDelivery:row, indexItem) = h_p_raw_matrix(dateDelivery:row, indexItem) + table2array(procurementExcel(i,4));
        end
    end
end

finalItemVec = string(unique(table2array(prodExcel(:,2))));
numProductsFinished = size(finalItemVec,1);

h_p_finished_matrix = zeros(row,numProductsFinished + 1);
h_p_finished_matrix(:,1) = datePeriod;
numberOfProd = size(prodExcel,1);

for i = 1:numberOfProd
    if(ismember(datenum(datestr(table2array(prodExcel(i,1)))), h_p_finished_matrix(:,1)))
        date = find(ismember(h_p_finished_matrix(:,1),datenum(table2array(prodExcel(i,1)))));
        indexFinalItem = find(ismember(finalItemVec,string(table2array(prodExcel(i,2))))) + 1;
        h_p_finished_matrix(date:row, indexFinalItem) = h_p_finished_matrix(date:row,indexFinalItem) + table2array(prodExcel(i,3));
        indexCurr = find(ismember(currVec,string(table2array(prodExcel(i,4))))) + 1;
        h_c_matrix(date:row,indexCurr) = h_c_matrix(date:row,indexCurr) - table2array(prodExcel(i,5));
        prodName = string(table2array(prodExcel(i,2)));
        indexComponent = find(ismember(string(table2array(bomExcel(:,2))),prodName));
        indexDate = find(table2array(prodExcel(i,1)) == table2array(bomExcel(:,1)));
        indexBom = intersect(indexComponent,indexDate);
        for j = 1:size(indexBom,1)
            if (string(table2array(bomExcel(indexBom(j),4))) == "Labour")
               h_c_matrix(date:row, indexCurr) = h_c_matrix(date:row,indexCurr) - table2array(bomExcel(j,7));
               xsProd_b_matrix(date,indexCurr) = xsProd_b_matrix(date,indexCurr) + table2array(bomExcel(i,7));
            else
                indexCurr = find(ismember(currVec,string(table2array(bomExcel(j,6))))) + 1;
                itemName =  string(table2array(bomExcel(indexBom(j),4)));
                indexItem = find(ismember(itemVec,itemName)) + 1;
                quanItem = table2array(bomExcel(indexBom(j),5));
                h_p_raw_matrix(date:row, indexItem) = h_p_raw_matrix(date:row, indexItem) - quanItem;
                xsProd_b_matrix(date,indexCurr) = xsProd_b_matrix(date,indexCurr) + table2array(bomExcel(i,5));
            end
        end
    end
end


numberOfSales = size(salesExcel,1);
numCurrencies = size(currVec,1);
numberOfDates = size(arrayDates,1);
tempSalesMatrix = zeros(numProductsFinished,numCurrencies);

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
           h_c_matrix(salesDate:row,indexCurr+1) = h_c_matrix(salesDate:row,indexCurr+1) + table2array(salesExcel(salesDateIndex(j),6));
           h_p_finished_matrix(deliveryDate:row,indexItem+1) = h_p_finished_matrix(deliveryDate:row,indexItem+1) - table2array(salesExcel(salesDateIndex(j),3));
       end
   else
        tempSalesMatrix = zeros(numberOfProd,numCurrencies);
   end
   if (i == 1)
       D = tempSalesMatrix;
   else
       D =cat(3,D,tempSalesMatrix);
   end
end

%Cleaning data matrixes from datePeriod
h_c_matrix (:,1) = [];
h_p_raw_matrix(:,1) = [];
xsProd_b_matrix(:,1) = [];
xsProd_s_matrix(:,1) = [];
h_p_finished_matrix(:,1) = [];
xsCurr_b_matrix(:,1) = [];
end

