function [Q] = extrapolateEigenvectors(E, m)

n = size(E,1);
A = zeros(m, size(E,2));
A(1:n,:) = E;

A(n+1:end,:) = repmat(E(end,:), m-n, 1);

% Use Gram-Schmidt to ensure that extrapolated eigenvectors are orthogonal

Q = zeros(size(A));
R = zeros(size(A));

for j=1:size(A,2)
  v = A(:,j);
  for i=1:j-1
    R(i,j) = Q(:,i)'*A(:,j);
    v = v-R(i,j)*Q(:,i);
  end
  R(j,j) = norm(v);
  Q(:,j) = v/R(j,j);
end

