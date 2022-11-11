function [e,re, yield, marketYield] = yieldError(instr,rSpot,T)

yield = yieldSpot(instr, rSpot, T);

marketYield = zeros(length(instr.data),1);
for i=1:length(instr.data)
  marketYield(i) = instr.data{i}.price(3);
end

e = yield - marketYield;

re=e./marketYield;

