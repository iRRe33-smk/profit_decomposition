function [yield] = yieldSpot(instr,rSpot,T)

yield = zeros(length(instr.data),1);
for i=1:length(instr.data)

  if (strcmp(instr.assetType{i}, 'Bill'))
    p = priceBillSpot(instr.data{i}, instr.firstDate, rSpot, T);
    yield(i) = p2yBill(p, instr.data{i}.dt);
  elseif (strcmp(instr.assetType{i}, 'Bond'))
    p = priceBondSpot(instr.data{i}, instr.firstDate, rSpot, T);
    yield(i) = p2yBondDirty(p, instr.data{i});
  elseif (strcmp(instr.assetType{i}, 'CD') || strcmp(instr.assetType{i}, 'IBOR'))
    t0 = instr.data{i}.settlementDate-instr.firstDate;
    t1 = instr.data{i}.maturityDate-instr.firstDate;
    dt = instr.data{i}.dt;
    yield(i) = priceCDYield(t0, t1,dt,rSpot,T);
  elseif (strcmp(instr.assetType{i}, 'FRA'))
    t1 = instr.data{i}.valueDate-instr.firstDate;
    t2 = instr.data{i}.maturityDate-instr.firstDate;
    dt = instr.data{i}.dt;
    yield(i) = priceFRAYield(t1, t2, dt, rSpot, T);
  elseif (strcmp(instr.assetType{i}, 'IRS') || strcmp(instr.assetType{i}, 'OIS'))
    t0 = instr.data{i}.settlementDate-instr.firstDate;
    n = instr.data{i}.nFix;
    dt = zeros(1,n);
    dt(1,:) = instr.data{i}.dtFix;
    t = zeros(1,n);
    t(1,:) = instr.data{i}.cfDatesFix-instr.firstDate;
    yield(i) = priceIRSYield(t0, n, dt, t, rSpot, T);
  elseif (strcmp(instr.assetType{i}, 'TenorFRA'))
    t1 = instr.data{i}.valueDate-instr.firstDate;
    d1 = instr.data{i}.dValueDate;
    t2 = instr.data{i}.maturityDate-instr.firstDate;
    d2 = instr.data{i}.dMaturityDate;
    dt = instr.data{i}.dt;
    yield(i) = priceTenorFRAYield(t1, d1, t2, d2, dt, yield, rSpot, T);
  elseif (strcmp(instr.assetType{i}, 'TenorIRS'))
    t0 = instr.data{i}.settlementDate-instr.firstDate;
    d0 = instr.data{i}.dSettlementDate;
    nFix = instr.data{i}.nFix;
    tFix = zeros(1,nFix);
    tFix(1,:) = instr.data{i}.cfDatesFix-instr.firstDate;
    dtFix = zeros(1,nFix);
    dtFix(1,:) = instr.data{i}.dtFix;
    dFix = zeros(1,nFix);
    dFix(1,:) = instr.data{i}.dFix;
    nFlt = instr.data{i}.nFlt;
    tFlt = zeros(1,nFlt);
    tFlt(1,:) = instr.data{i}.cfDatesFlt-instr.firstDate;
    dtFlt = zeros(1,nFlt);
    dtFlt(1,:) = instr.data{i}.dtFlt;
    dFlt = zeros(1,nFlt);
    dFlt(1,:) = instr.data{i}.dFlt;
    yield(i) = priceTenorIRSYield(t0, d0, nFix, tFix, dtFix, dFix, nFlt, tFlt, dtFlt, dFlt,yield,rSpot,T);
  elseif (strcmp(instr.assetType{i}, 'TS'))
    yield(i) = priceTSYield(instr.data{i}, instr.firstDate, yield,rSpot,T);
  else
    error('Unknown asset');
  end
end
