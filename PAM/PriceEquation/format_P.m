function [P] = format_P(P_yesterday,currency,currVec,N)
    nC =size(currVec,1);
    P = zeros(N,nC);
    
    for i = 1:N
        if strlength(currency(i,1)) == 3
            index = find(strcmp(currVec,currency(i,1)));
            P(i,index)=P_yesterday(i);
        end
    end

end