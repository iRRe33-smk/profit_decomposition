function [dP] = format_dP(dPRF,currency,currVec,N)
    nC =size(currVec,1);
    nRF = size(dPRF,2);
    dP = zeros(N,nC,nRF);

    for i = 1:N
        
        if strlength(currency(i,1)) == 3
            index = find(strcmp(currVec,currency(i,1)));
            dP(i,index,:)=dPRF(i,:);
        end
    end

end