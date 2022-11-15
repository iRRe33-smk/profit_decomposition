function [c,c2, tau,tau2]=read_from_excel()


%Import data for cash flows: size, tau and timestamp
c = readmatrix('PCA_test.xlsx', 'sheet', 'Cash Flows', 'Range', 'F6:F7');
c2 = readmatrix('PCA_test.xlsx', 'sheet', 'Cash Flows', 'Range', 'N6:N7');
T_cashflows = readmatrix('PCA_test.xlsx', 'sheet', 'Cash Flows', 'Range', 'E6:E7');
T_cashflows2 = readmatrix ('PCA_test.xlsx', 'sheet', 'Cash Flows', 'Range', 'M6:M7')
T_start= readmatrix('PCA_test.xlsx', 'sheet', 'Cash Flows', 'Range', 'G6:G6');
T_start2 = readmatrix('PCA_test.xlsx', 'sheet', 'Cash Flows', 'Range', 'O6:O6');
T_end= readmatrix('PCA_test.xlsx', 'sheet', 'Cash Flows', 'Range', 'H6:H6');
T_end2 = readmatrix('PCA_test.xlsx', 'sheet', 'Cash Flows', 'Range', 'P6:P6')

%Compute tau
n_days=datenum(T_end)-datenum(T_start)+1;
tau=zeros(length(c),n_days);

for i=1:length(c)
    for j=1:n_days
        tau(i,j)=(datenum(T_cashflows(i))-(datenum(T_start)+j-1))/365;
        tau2(i,j)=(datenum(T_cashflows2(i))-(datenum(T_start2)+j-1))/365;
    end
end

end