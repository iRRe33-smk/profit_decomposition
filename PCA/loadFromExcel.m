function [dates, ric, data] = loadFromExcel(fileName)

[type, sheetNames]=xlsfinfo(fileName);

for i = 1:2
  [data{i},txt{i}] = xlsread(fileName, char(sheetNames(i)));
  sheet{i} = sheetNames(i);
  ric{i} = txt{i}(1,2:end);

  dates{i} = txt{i}(2:end,1);

  if (length(dates{i}) == 0)
    dates{i} = datenum('30-Dec-1899') + data{i}(:,1);
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
end

