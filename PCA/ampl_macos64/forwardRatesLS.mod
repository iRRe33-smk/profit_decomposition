problem forwardRatesLS;

param p;                 # Weight for price error
param dt;                # Discretization of forward rates
param n;                 # The number of forward rates
param m;                 # The number of continuously compounded spot rates

param M{1..m};           # The maturity for each continuously compounded spot rates
param r{1..m};	         # The continuously compounded spot rates

var f{0..n-1};           # Forward rates
var z{1..m};             # Price error

minimize obj: 
minimize obj:   sum{t in 1..n-2}   ((f[t+1]-2*f[t]+f[t-1])/(dt*dt))^2+ p*sum{j in 1..m} z[j]^2

subject to con  sum{j in 1..m}: sum{t in 0..(M[j]-1))}f[t]*dt=(r[j]-z[j])*M[j]*dt

