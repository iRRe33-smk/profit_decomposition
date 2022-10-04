delta_T = 1;
n_f = 10;
f_0 = rand(n_f);

A_n = zeros(n_f - 2, n_f);
W = diag(ones(1,n_f-2));
for i = 1:n_f - 2
    A_n(i, i:i+2) = [1/(delta_T^2) -2/(delta_T^2) 1/(delta_T^2)];
end
Q = A_n'*sqrt(W)*A_n;
fun = @(f) 0.5*f'*A_n'*W*A_n*f;

gradient(fun)

