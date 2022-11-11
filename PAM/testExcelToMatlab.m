%% Read data
clc 
clear
T = readtable('caseTest.xlsx','sheet', 'deposits')
deposit_excell = readtable('caseTest.xlsx', 'sheet', 'hc');
%%
currVec = ["SEK"; "USD"; "CAD"];
row = size(T,1);
column = size(currVec,1) + 1;
h_deposit = zeros(row,column);

array_hc  = datestr(table2array(deposit_excell));
formatIn = 'dd-mmm-yyyy';
dateDeposit = datenum(array_hc,formatIn);

h_deposit(:,1) = dateDeposit

for i = 1:row
    if(ismember(datenum(datestr(table2array(T(i,1)))), h_deposit(:,1)))
        indexCurr = find(ismember(currVec,string(table2array(T(i,2))))) + 1;
        h_deposit(i,indexCurr) = h_deposit(i,indexCurr) + table2array(T(i,3))
    end
end