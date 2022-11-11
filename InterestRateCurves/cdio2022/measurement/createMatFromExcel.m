% function createMatFromExcel(fileName)
% fileName = 'CHF.xlsx';
fileName = 'EUR.xlsx';
% fileName = 'GBP.xlsx';
% fileName = 'JPY.xlsx';
% fileName = 'KRW.xlsx';
% fileName = 'SEK.xlsx';
% fileName = 'USD.xlsx';
% fileName = 'USDSEK.xlsx';
% fileName = 'EURSEK.xlsx';
% fileName = 'EURUSD.xlsx';
% fileName = 'GBPUSD.xlsx';
% fileName = 'AUDUSD.xlsx';

[type, sheetNames]=xlsfinfo(fileName);

i = 1; % Counter to deal with AFOSHEET

for k = 1:length(sheetNames)
  if (strcmp(sheetNames(k), 'settings'))
    continue;
  end
  [data{i},txt{i}] = xlsread(fileName, char(sheetNames(k)));
  sheet{i} = sheetNames(k);
  ric{i} = txt{i}(1,2:end);

  dates{i} = txt{i}(2:end,1);

  if (length(dates{i}) == 0)
    dates{i} = datenum('30-Dec-1899') + data{i}(:,1);
    size(dates{i})
    data{i} = data{i}(:,2:end);
  else
    dates{i} = datenum(dates{i});
  end

  if (length(dates{i}) > 1)
    if (dates{i}(2) < dates{i}(1)) % Dates are sorted in decreasing order, change to increasing order
      n = size(data{i},1);
      indData = n:-1:1;
      data{i} = data{i}(indData,:);
      dates{i} = dates{i}(indData,1);
    end
  end
  i = i+1;
end

k = strfind(fileName, '.');
fileNameMatlab = fileName(1:k(end)-1);

save(fileNameMatlab, 'sheet', 'ric', 'dates', 'data');

