function [rSpot]=forw2spot(f,T)   

rSpot = zeros(min(length(f)+1,length(T)),1);
rSpot(1)=f(1);
for i=2:length(rSpot)
  rSpot(i)=(f(i-1)*(T(i)-T(i-1))+rSpot(i-1)*T(i-1))/(T(i));
end


end
